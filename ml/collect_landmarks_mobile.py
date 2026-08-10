#!/usr/bin/env python3
"""Load training samples exported from the Flutter app (or collect via webcam)."""

from __future__ import annotations

import argparse
import json
import sys
from collections import Counter
from pathlib import Path

from common import (
    DATA_DIR,
    SAMPLE_FORMAT_PATH,
    TRAINING_SAMPLES_PATH,
    extract_features42,
    load_training_samples,
    normalize_sample,
)


def summarize_samples(samples: list[dict]) -> None:
    counts = Counter(sample["label"] for sample in samples)
    print(f"Loaded {len(samples)} samples across {len(counts)} classes.")
    for label, count in sorted(counts.items()):
        print(f"  {label!r}: {count}")


def load_from_export(path: Path) -> list[dict]:
    raw_samples = load_training_samples(path)
    if not raw_samples:
        print(f"No samples found in {path}")
        return []

    normalized = [normalize_sample(sample) for sample in raw_samples]
    summarize_samples(normalized)
    return normalized


def collect_webcam(output_path: Path, label: str, count: int) -> None:
    import cv2
    import mediapipe as mp

    mp_hands = mp.solutions.hands
    samples: list[dict] = []
    if output_path.exists():
        samples = load_training_samples(output_path)
        samples = [normalize_sample(sample) for sample in samples]

    print(f"Collecting {count} samples for label {label!r}. Press SPACE to capture, ESC to finish.")
    with mp_hands.Hands(
        static_image_mode=False,
        max_num_hands=1,
        min_detection_confidence=0.6,
        min_tracking_confidence=0.6,
    ) as hands:
        capture = cv2.VideoCapture(0)
        if not capture.isOpened():
            raise RuntimeError("Could not open webcam")

        captured = 0
        try:
            while captured < count:
                ok, frame = capture.read()
                if not ok:
                    break

                rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                result = hands.process(rgb)
                preview = frame.copy()
                if result.multi_hand_landmarks:
                    for hand_landmarks in result.multi_hand_landmarks:
                        mp.solutions.drawing_utils.draw_landmarks(
                            preview,
                            hand_landmarks,
                            mp_hands.HAND_CONNECTIONS,
                        )

                cv2.putText(
                    preview,
                    f"{label}: {captured}/{count}  SPACE=capture ESC=done",
                    (10, 30),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.7,
                    (0, 255, 0),
                    2,
                )
                cv2.imshow("collect_landmarks_mobile", preview)
                key = cv2.waitKey(1) & 0xFF
                if key == 27:
                    break
                if key == 32 and result.multi_hand_landmarks:
                    features = extract_features42(result.multi_hand_landmarks[0].landmark)
                    samples.append(
                        {
                            "label": label,
                            "features42": features,
                            "handScore": 1.0,
                            "span": max(features),
                            "timestamp": None,
                        }
                    )
                    captured += 1
                    print(f"Captured {captured}/{count}")
        finally:
            capture.release()
            cv2.destroyAllWindows()

    output_path.parent.mkdir(parents=True, exist_ok=True)
    payload = {"version": 1, "samples": samples}
    with output_path.open("w", encoding="utf-8") as handle:
        json.dump(payload, handle, indent=2)
    print(f"Wrote {len(samples)} total samples to {output_path}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--input",
        type=Path,
        default=TRAINING_SAMPLES_PATH,
        help="Path to training_samples.json exported from the phone",
    )
    parser.add_argument(
        "--validate-format",
        action="store_true",
        help="Validate sample_format.json structure only",
    )
    parser.add_argument("--webcam", action="store_true", help="Collect samples from webcam")
    parser.add_argument("--label", type=str, help="Target label for webcam capture")
    parser.add_argument("--count", type=int, default=20, help="Webcam captures to take")
    parser.add_argument(
        "--output",
        type=Path,
        default=TRAINING_SAMPLES_PATH,
        help="Output JSON path for webcam collection",
    )
    args = parser.parse_args()

    if args.validate_format:
        if not SAMPLE_FORMAT_PATH.exists():
            print(f"Missing example file: {SAMPLE_FORMAT_PATH}", file=sys.stderr)
            return 1
        samples = load_from_export(SAMPLE_FORMAT_PATH)
        print(f"Format validation OK ({len(samples)} example samples).")
        return 0

    if args.webcam:
        if not args.label:
            print("--label is required with --webcam", file=sys.stderr)
            return 1
        collect_webcam(args.output, args.label.upper(), args.count)
        return 0

    if not args.input.exists():
        print(f"No export found at {args.input}")
        print(f"See example format: {SAMPLE_FORMAT_PATH}")
        print("Collect on phone, export training_samples.json, then copy to ml/data/.")
        return 0

    load_from_export(args.input)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
