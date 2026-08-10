# ASL Classifier Training Pipeline

Python scripts to retrain `asl_classifier.tflite` using landmark samples collected on the same phone/camera as the Flutter app.

## Feature format (must match native code)

Each sample is a **42-dimensional** vector from 21 hand landmarks:

- For landmark `i` in `0..20`: `x[i] - min(xs)`, then `y[i] - min(ys)`
- Same normalization as `HandLandmarkerBridge.kt` in the Android app

Labels are the **37 classes** in `assets/models/labels.json`: A–Z, 0–9, and space.

## Setup

```bash
cd ml
python -m venv .venv
.venv\Scripts\activate        # Windows
pip install -r requirements.txt
```

## 1. Collect samples on the phone

1. Open the app **Practice** screen and enable **Collect Training Data** (when available).
2. Select a target letter (start with **A**, **B**, **C**).
3. When hand quality is good, tap **Capture** (~150–300 samples per letter).
4. Tap **Export** to write `training_samples.json` to app documents.

### Pull export via adb

**PowerShell** (UTF-8, no BOM — required on Windows):

```powershell
adb shell run-as com.example.mobile_offline cat app_flutter/training_samples.json | Out-File -FilePath ml/data/training_samples.json -Encoding utf8NoBOM
```

**bash / cmd:**

```bash
adb shell run-as com.example.mobile_offline cat app_flutter/training_samples.json > ml/data/training_samples.json
```

If `run-as` fails on your device, use the app’s share/export path or:

```bash
adb pull /storage/emulated/0/Android/data/com.example.mobile_offline/files/training_samples.json ml/data/
```

Adjust the path to match where the Flutter app saves the file.

## 2. Validate export format

```bash
python collect_landmarks_mobile.py --validate-format
python collect_landmarks_mobile.py --input data/training_samples.json
```

Example JSON shape: see `data/sample_format.json`.

## 3. Build dataset

```bash
python create_dataset.py
python create_dataset.py --example   # smoke test with sample_format.json only
```

Writes `data/X.npy`, `data/y.npy`, and `data/dataset_meta.json`.

## 4. Train and export TFLite

```bash
python train_tflite_classifier.py
```

Architecture: `Input(42) → Dense(128, relu) → Dense(64, relu) → Dense(37, softmax)`

Outputs:

- `output/asl_classifier.keras`
- `output/asl_classifier.tflite`
- `output/train_report.json`

## 5. Parity check (Keras vs TFLite)

```bash
python test_tflite_parity.py
```

Target: **≥ 99%** label agreement on the saved dataset.

## 6. Deploy to Flutter

```bash
python prepare_mobile_assets.py
cd ..
flutter build apk --release
```

## Optional: webcam collection (desktop)

Uses the same 42-feature extraction for quick experiments (not a substitute for phone data):

```bash
python collect_landmarks_mobile.py --webcam --label A --count 30
```

Requires OpenCV (`pip install opencv-python`, not in requirements by default).

## Current status

Until `data/training_samples.json` exists with real phone captures, training will not produce a deployable model. Use `--example` only to verify the pipeline wiring:

```bash
python create_dataset.py --example
python train_tflite_classifier.py --example
python test_tflite_parity.py
python prepare_mobile_assets.py
```

Replace example data with exported phone samples before deploying to the device.
