#!/usr/bin/env python3
"""Copy trained TFLite model (and labels) into Flutter assets/models/."""

from __future__ import annotations

import argparse
import shutil
import sys
from pathlib import Path

from common import LABELS_PATH, MOBILE_TFLITE_PATH, PROJECT_ROOT, TFLITE_MODEL_PATH


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--tflite",
        type=Path,
        default=TFLITE_MODEL_PATH,
        help="Source TFLite model path",
    )
    parser.add_argument(
        "--labels",
        type=Path,
        default=LABELS_PATH,
        help="labels.json to copy (defaults to existing assets/models/labels.json)",
    )
    parser.add_argument(
        "--skip-labels",
        action="store_true",
        help="Only copy the TFLite model",
    )
    args = parser.parse_args()

    if not args.tflite.exists():
        print(f"Missing trained model: {args.tflite}")
        print("Run: python train_tflite_classifier.py")
        return 1

    dest_dir = PROJECT_ROOT / "assets" / "models"
    dest_dir.mkdir(parents=True, exist_ok=True)

    shutil.copy2(args.tflite, MOBILE_TFLITE_PATH)
    print(f"Copied {args.tflite} -> {MOBILE_TFLITE_PATH}")

    if not args.skip_labels:
        if not args.labels.exists():
            print(f"labels.json not found at {args.labels}", file=sys.stderr)
            return 1
        labels_dest = dest_dir / "labels.json"
        if args.labels.resolve() != labels_dest.resolve():
            shutil.copy2(args.labels, labels_dest)
            print(f"Copied {args.labels} -> {labels_dest}")
        else:
            print(f"Using existing {labels_dest}")

    print("Rebuild the app: flutter build apk --release")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
