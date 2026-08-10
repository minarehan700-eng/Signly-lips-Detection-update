#!/usr/bin/env python3
"""Train MLP classifier and export asl_classifier.tflite."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import numpy as np
import tensorflow as tf
from sklearn.model_selection import train_test_split

from common import (
    DATA_DIR,
    FEATURE_DIM,
    KERAS_MODEL_PATH,
    NUM_CLASSES,
    OUTPUT_DIR,
    SAMPLE_FORMAT_PATH,
    TFLITE_MODEL_PATH,
    TRAINING_SAMPLES_PATH,
    X_PATH,
    Y_PATH,
    load_labels,
)
from create_dataset import build_dataset
from common import load_training_samples


def build_model() -> tf.keras.Model:
    inputs = tf.keras.Input(shape=(FEATURE_DIM,), name="features42")
    x = tf.keras.layers.Dense(128, activation="relu")(inputs)
    x = tf.keras.layers.Dense(64, activation="relu")(x)
    outputs = tf.keras.layers.Dense(NUM_CLASSES, activation="softmax")(x)
    model = tf.keras.Model(inputs=inputs, outputs=outputs, name="asl_classifier")
    model.compile(
        optimizer="adam",
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"],
    )
    return model


def export_tflite(model: tf.keras.Model, output_path: Path) -> None:
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = []
    tflite_model = converter.convert()
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_bytes(tflite_model)


def ensure_dataset(input_path: Path, *, use_example: bool) -> tuple[np.ndarray, np.ndarray]:
    if use_example:
        input_path = SAMPLE_FORMAT_PATH

    has_real_export = input_path.exists() and input_path != SAMPLE_FORMAT_PATH
    if (
        X_PATH.exists()
        and Y_PATH.exists()
        and not use_example
        and has_real_export
        and input_path == TRAINING_SAMPLES_PATH
    ):
        x = np.load(X_PATH)
        y = np.load(Y_PATH)
        if len(x) > 0:
            return x, y

    if not input_path.exists():
        raise FileNotFoundError(
            f"No training data at {input_path}. Collect samples on the phone first."
        )

    raw_samples = load_training_samples(input_path)
    if not raw_samples:
        raise ValueError(f"{input_path} contains no samples")

    x, y, _ = build_dataset(raw_samples, balance=True)
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    np.save(X_PATH, x)
    np.save(Y_PATH, y)
    return x, y


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--input",
        type=Path,
        default=TRAINING_SAMPLES_PATH,
        help="training_samples.json path",
    )
    parser.add_argument(
        "--example",
        action="store_true",
        help="Train on sample_format.json (smoke test only)",
    )
    parser.add_argument("--epochs", type=int, default=50)
    parser.add_argument("--batch-size", type=int, default=32)
    args = parser.parse_args()

    label_to_idx, idx_to_label = load_labels()

    try:
        x, y = ensure_dataset(args.input, use_example=args.example)
    except (FileNotFoundError, ValueError) as exc:
        print(str(exc))
        print("Export training_samples.json from the app, copy to ml/data/, then rerun.")
        return 1

    unique_classes = len(set(y.tolist()))
    if unique_classes < 2:
        print("Need samples from at least 2 classes to train.")
        return 1

    min_samples = 2 if args.example else 4
    if len(x) < min_samples:
        print(
            f"Only {len(x)} samples available (need at least {min_samples} for training)."
        )
        print("Collect more data on the phone before training a deployable model.")
        return 1

    if args.example:
        x_train, x_test, y_train, y_test = x, x, y, y
        callbacks: list[tf.keras.callbacks.Callback] = []
        fit_epochs = min(args.epochs, 5)
    else:
        test_size = 0.2 if len(x) >= 10 else max(1 / len(x), 0.1)
        stratify = y if unique_classes > 1 and min(np.bincount(y)) >= 2 else None
        x_train, x_test, y_train, y_test = train_test_split(
            x,
            y,
            test_size=test_size,
            random_state=42,
            stratify=stratify,
        )
        callbacks = [
            tf.keras.callbacks.EarlyStopping(
                monitor="val_loss",
                patience=8,
                restore_best_weights=True,
            )
        ]
        fit_epochs = args.epochs

    model = build_model()
    history = model.fit(
        x_train,
        y_train,
        validation_data=(x_test, y_test) if not args.example else None,
        epochs=fit_epochs,
        batch_size=min(args.batch_size, len(x_train)),
        callbacks=callbacks,
        verbose=1,
    )

    _, accuracy = model.evaluate(x_test, y_test, verbose=0)
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    model.save(KERAS_MODEL_PATH)
    export_tflite(model, TFLITE_MODEL_PATH)

    report = {
        "samples": int(len(x)),
        "classes": unique_classes,
        "test_accuracy": float(accuracy),
        "epochs_ran": len(history.history["loss"]),
        "keras_model": str(KERAS_MODEL_PATH),
        "tflite_model": str(TFLITE_MODEL_PATH),
        "label_map": {str(idx): label for idx, label in sorted(idx_to_label.items())},
    }
    report_path = OUTPUT_DIR / "train_report.json"
    with report_path.open("w", encoding="utf-8") as handle:
        json.dump(report, handle, indent=2)

    print(f"Test accuracy: {accuracy:.4f}")
    print(f"Saved Keras model: {KERAS_MODEL_PATH}")
    print(f"Saved TFLite model: {TFLITE_MODEL_PATH}")
    print(f"Report: {report_path}")
    if args.example:
        print("Smoke test complete. Replace sample data with real phone captures before deploying.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
