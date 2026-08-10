#!/usr/bin/env python3
"""Validate 42-dim feature vectors, balance classes, and save X.npy / y.npy."""

from __future__ import annotations

import argparse
import json
import sys
from collections import Counter
from pathlib import Path

import numpy as np
from sklearn.utils import resample

from common import (
    DATA_DIR,
    FEATURE_DIM,
    SAMPLE_FORMAT_PATH,
    TRAINING_SAMPLES_PATH,
    X_PATH,
    Y_PATH,
    load_labels,
    load_training_samples,
    normalize_sample,
)


def build_dataset(
    samples: list[dict],
    *,
    balance: bool = True,
    min_per_class: int = 1,
) -> tuple[np.ndarray, np.ndarray, dict]:
    label_to_idx, _ = load_labels()
    rows: list[list[float]] = []
    labels: list[int] = []
    skipped = 0

    for raw in samples:
        try:
            sample = normalize_sample(raw)
        except ValueError as exc:
            print(f"Skipping invalid sample: {exc}")
            skipped += 1
            continue

        label = sample["label"]
        if label not in label_to_idx:
            print(f"Skipping unknown label {label!r}")
            skipped += 1
            continue

        rows.append(sample["features42"])
        labels.append(label_to_idx[label])

    if not rows:
        raise ValueError("No valid samples available to build a dataset")

    x = np.asarray(rows, dtype=np.float32)
    y = np.asarray(labels, dtype=np.int64)
    if x.shape[1] != FEATURE_DIM:
        raise ValueError(f"Expected feature width {FEATURE_DIM}, got {x.shape[1]}")

    counts = Counter(y.tolist())
    meta = {
        "total_samples": int(len(y)),
        "skipped_samples": skipped,
        "classes_before_balance": {str(k): v for k, v in sorted(counts.items())},
        "balanced": balance,
    }

    if balance and len(counts) > 1:
        target = max(min(counts.values()), min_per_class)
        balanced_x: list[np.ndarray] = []
        balanced_y: list[np.ndarray] = []
        rng = np.random.default_rng(42)
        for class_idx in sorted(counts):
            mask = y == class_idx
            class_x = x[mask]
            class_y = y[mask]
            if len(class_x) >= target:
                indices = rng.choice(len(class_x), size=target, replace=False)
                class_x = class_x[indices]
                class_y = class_y[indices]
            else:
                class_x, class_y = resample(
                    class_x,
                    class_y,
                    replace=True,
                    n_samples=target,
                    random_state=42,
                )
            balanced_x.append(class_x)
            balanced_y.append(class_y)
        x = np.vstack(balanced_x)
        y = np.concatenate(balanced_y)
        meta["classes_after_balance"] = {
            str(class_idx): int((y == class_idx).sum()) for class_idx in sorted(set(y.tolist()))
        }
        meta["total_samples"] = int(len(y))

    return x, y, meta


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
        help="Build dataset from sample_format.json for structure validation",
    )
    parser.add_argument("--no-balance", action="store_true", help="Disable class balancing")
    args = parser.parse_args()

    input_path = SAMPLE_FORMAT_PATH if args.example else args.input
    if not input_path.exists():
        print(f"No input file at {input_path}")
        print("Collect samples on the phone and copy training_samples.json to ml/data/.")
        return 1

    raw_samples = load_training_samples(input_path)
    if not raw_samples:
        print(f"{input_path} contains no samples.")
        return 1

    try:
        x, y, meta = build_dataset(raw_samples, balance=not args.no_balance)
    except ValueError as exc:
        print(f"Dataset build failed: {exc}", file=sys.stderr)
        return 1

    DATA_DIR.mkdir(parents=True, exist_ok=True)
    np.save(X_PATH, x)
    np.save(Y_PATH, y)
    meta_path = DATA_DIR / "dataset_meta.json"
    with meta_path.open("w", encoding="utf-8") as handle:
        json.dump(meta, handle, indent=2)

    print(f"Saved {x.shape[0]} samples to {X_PATH} and {Y_PATH}")
    print(f"Feature shape: {x.shape}, labels shape: {y.shape}")
    print(f"Metadata: {meta_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
