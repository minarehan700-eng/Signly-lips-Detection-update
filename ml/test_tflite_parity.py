#!/usr/bin/env python3
"""Verify Keras and TFLite models agree on predictions."""

from __future__ import annotations

import argparse
import sys

import numpy as np
import tensorflow as tf

from common import (
    FEATURE_DIM,
    KERAS_MODEL_PATH,
    NUM_CLASSES,
    TFLITE_MODEL_PATH,
    X_PATH,
    Y_PATH,
    load_labels,
)


def load_tflite_interpreter(model_path):
    interpreter = tf.lite.Interpreter(model_path=str(model_path))
    interpreter.allocate_tensors()
    return interpreter


def tflite_predict(interpreter: tf.lite.Interpreter, batch: np.ndarray) -> np.ndarray:
    input_details = interpreter.get_input_details()[0]
    output_details = interpreter.get_output_details()[0]
    predictions = np.zeros((len(batch), NUM_CLASSES), dtype=np.float32)
    for index, features in enumerate(batch):
        interpreter.set_tensor(input_details["index"], features.reshape(1, FEATURE_DIM))
        interpreter.invoke()
        predictions[index] = interpreter.get_tensor(output_details["index"])[0]
    return predictions


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--min-agreement", type=float, default=0.99)
    args = parser.parse_args()

    if not KERAS_MODEL_PATH.exists() or not TFLITE_MODEL_PATH.exists():
        print("Train a model first: python train_tflite_classifier.py")
        return 1
    if not X_PATH.exists() or not Y_PATH.exists():
        print("Missing X.npy / y.npy. Run create_dataset.py first.")
        return 1

    _, idx_to_label = load_labels()
    x = np.load(X_PATH).astype(np.float32)
    y = np.load(Y_PATH)

    keras_model = tf.keras.models.load_model(KERAS_MODEL_PATH)
    interpreter = load_tflite_interpreter(TFLITE_MODEL_PATH)

    keras_probs = keras_model.predict(x, verbose=0)
    tflite_probs = tflite_predict(interpreter, x)

    keras_labels = np.argmax(keras_probs, axis=1)
    tflite_labels = np.argmax(tflite_probs, axis=1)
    agreement = float(np.mean(keras_labels == tflite_labels))
    max_prob_diff = float(np.max(np.abs(keras_probs - tflite_probs)))

    mismatches = np.where(keras_labels != tflite_labels)[0]
    print(f"Samples checked: {len(x)}")
    print(f"Label agreement: {agreement * 100:.2f}%")
    print(f"Max probability delta: {max_prob_diff:.6f}")

    if mismatches.size:
        print("First mismatches:")
        for index in mismatches[:5]:
            true_label = idx_to_label[int(y[index])]
            keras_label = idx_to_label[int(keras_labels[index])]
            tflite_label = idx_to_label[int(tflite_labels[index])]
            print(
                f"  idx={index} true={true_label} keras={keras_label} tflite={tflite_label}"
            )

    if agreement < args.min_agreement:
        print(f"FAIL: agreement below {args.min_agreement * 100:.0f}% threshold")
        return 1

    print("PASS: Keras and TFLite predictions match.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
