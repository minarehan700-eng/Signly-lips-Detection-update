"""Shared helpers for the ASL classifier training pipeline."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

FEATURE_DIM = 42
NUM_LANDMARKS = 21
NUM_CLASSES = 37

ML_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = ML_DIR.parent
DATA_DIR = ML_DIR / "data"
OUTPUT_DIR = ML_DIR / "output"
LABELS_PATH = PROJECT_ROOT / "assets" / "models" / "labels.json"
TRAINING_SAMPLES_PATH = DATA_DIR / "training_samples.json"
SAMPLE_FORMAT_PATH = DATA_DIR / "sample_format.json"
X_PATH = DATA_DIR / "X.npy"
Y_PATH = DATA_DIR / "y.npy"
KERAS_MODEL_PATH = OUTPUT_DIR / "asl_classifier.keras"
TFLITE_MODEL_PATH = OUTPUT_DIR / "asl_classifier.tflite"
MOBILE_TFLITE_PATH = PROJECT_ROOT / "assets" / "models" / "asl_classifier.tflite"


def load_labels(labels_path: Path = LABELS_PATH) -> tuple[dict[str, int], dict[int, str]]:
    with labels_path.open(encoding="utf-8") as handle:
        raw = json.load(handle)
    label_to_idx = {value: int(key) for key, value in raw.items()}
    idx_to_label = {int(key): value for key, value in raw.items()}
    if len(label_to_idx) != NUM_CLASSES:
        raise ValueError(f"Expected {NUM_CLASSES} labels, found {len(label_to_idx)}")
    return label_to_idx, idx_to_label


def extract_features42(landmarks: list[Any]) -> list[float]:
    """Match HandLandmarkerBridge.kt: x[i]-minX, y[i]-minY for 21 landmarks."""
    xs = [float(lm.x) for lm in landmarks]
    ys = [float(lm.y) for lm in landmarks]
    if len(xs) < NUM_LANDMARKS or len(ys) < NUM_LANDMARKS:
        raise ValueError(f"Expected {NUM_LANDMARKS} landmarks, got {len(xs)}")

    min_x = min(xs)
    min_y = min(ys)
    features: list[float] = []
    for index in range(NUM_LANDMARKS):
        features.append(xs[index] - min_x)
        features.append(ys[index] - min_y)
    return features


def validate_features42(features: list[float]) -> None:
    if len(features) != FEATURE_DIM:
        raise ValueError(f"Expected {FEATURE_DIM} features, got {len(features)}")
    if any(not isinstance(value, (int, float)) for value in features):
        raise ValueError("features42 must be numeric")
    if any(value != value for value in features):  # NaN check
        raise ValueError("features42 contains NaN")


def load_training_samples(path: Path | None = None) -> list[dict[str, Any]]:
    samples_path = path or TRAINING_SAMPLES_PATH
    if not samples_path.exists():
        return []

    with samples_path.open(encoding="utf-8") as handle:
        payload = json.load(handle)

    if isinstance(payload, list):
        return payload
    if isinstance(payload, dict):
        samples = payload.get("samples")
        if samples is None:
            raise ValueError(f"{samples_path} must contain a top-level 'samples' array")
        return samples
    raise ValueError(f"Unsupported JSON structure in {samples_path}")


def normalize_sample(raw: dict[str, Any]) -> dict[str, Any]:
    label = raw.get("label")
    features = raw.get("features42", raw.get("features"))
    if label is None:
        raise ValueError("Sample missing 'label'")
    if features is None:
        raise ValueError(f"Sample for label {label!r} missing 'features42'")

    features = [float(value) for value in features]
    validate_features42(features)
    return {
        "label": str(label),
        "features42": features,
        "handScore": float(raw.get("handScore", raw.get("hand_score", 0.0))),
        "span": float(raw.get("span", max(features) if features else 0.0)),
        "timestamp": raw.get("timestamp", raw.get("ts")),
    }
