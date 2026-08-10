# Signly — Offline ASL & Lips Detection App

**Signly** is a Flutter mobile app that helps people learn and use **American Sign Language (ASL)** without needing an internet connection.

It combines on-device hand recognition, text/voice translation into signs, and lips (mouth-movement) detection so learners, Deaf and hard-of-hearing users, and anyone practicing ASL can communicate and study anywhere — even offline.

## How Signly Helps

| Who it helps | How |
|---|---|
| ASL learners | Practice letters and words with live camera feedback and a dictionary |
| Deaf / hard-of-hearing users | Convert typed or spoken text into visual signs (GIFs and finger-spelling) |
| Anyone practicing mouth cues | Lips detection shows whether mouth movement / lipsing is happening |
| Users with weak connectivity | All recognition runs **on the phone** (MediaPipe + TFLite) — no cloud required |

## What The App Does

- **Splash & onboarding** — introduce the product and guide first-time users  
- **Login / signup** — simple local auth flow  
- **ASL recognition** — camera reads hand landmarks and classifies letters/digits offline  
- **Translate hub**
  - **Text to Sign** — type words; known words play GIFs, others are finger-spelled  
  - **Voice to Sign** — speak into the mic; speech becomes signs  
  - **Letters & Numbers** — browse A–Z and 0–9 with reference images  
  - **Lips Detection** — front camera tracks mouth open / lipsing and related letter cues  
- **Dictionary & practice** — look up signs and practice with feedback  
- **Profile / settings** — account and app preferences  

## Project Diagrams

Diagrams live in [`diagrams/`](diagrams/). PlantUML sources (`.puml`) and PNG exports are included so you can read them on GitHub or edit them later.

### 1. Use Cases

Shows what a user can do in Signly: login, recognize ASL, text/voice to sign, letters & numbers, lips detection, dictionary, and profile. Recognition and lips features use the camera; voice-to-sign uses the microphone.

![Use Cases](diagrams/UseCase.png)

### 2. System Architecture

Shows the layered design: Flutter screens → application controllers/engines → infrastructure (MediaPipe extractors, TFLite) → native Android/iOS bridges → on-device model files.

![System Architecture](diagrams/system%20architecture%20diagram.png)

### 3. Lips Detection Sequence

Step-by-step flow for one camera frame: JPEG encode → Face Landmarker → blendshapes → lipsing / lip-letter detectors → UI update.

![Lips Detection Sequence](diagrams/lips_detection_sequence.png)

### 4. Hand Recognition Sequence

Step-by-step flow for ASL recognition: camera frame → Hand Landmarker → 21 landmarks → TFLite classifier → smoothed prediction on screen.

![Hand Recognition Sequence](diagrams/hand_recognition_sequence.png)

### 5. App Navigation

Screen map from splash → login → home tabs, including the Translate sub-screens (text, voice, letters/numbers, lips).

![App Navigation](diagrams/app_navigation.png)

### 6. Lips Detection Classes

Main classes involved in lips detection (face extractors, detectors, and how they connect to the UI).

![Lips Classes](diagrams/lips_classes.png)

### 7. On-Device AI Components

Explains the three on-device models and the two AI paths:

- **Hand path:** MediaPipe Hand Landmarker → TFLite ASL classifier → sign label (37 classes)  
- **Face path:** MediaPipe Face Landmarker → rule-based `LipsingDetector` / `LipLetterDetector` → lipsing status + letter cues  

Source: [`diagrams/07_ai_components.puml`](diagrams/07_ai_components.puml)  
*(Open in [PlantUML Online](https://www.plantuml.com/plantuml/uml/) or a PlantUML IDE extension to render.)*

## Run The App

From the project root:

1. `flutter pub get`
2. Ensure these files exist:
   - `assets/models/asl_classifier.tflite`
   - `assets/models/labels.json`
   - `assets/sign_language/letters/` (37 PNGs: a–z, 0–9, space)
   - `assets/sign_language/gifs/` (hello, you, good, morning GIFs)
3. Add MediaPipe models:
   - `android/app/src/main/assets/hand_landmarker.task`
   - `android/app/src/main/assets/face_landmarker.task`
   - iOS: copy both `.task` files into `ios/Runner/` and add to Xcode bundle
4. Run:
   - `flutter run`

To prepare TFLite + sign assets:

```bash
python prepare_mobile_assets.py
```

Face landmarker download:  
https://storage.googleapis.com/mediapipe-models/face_landmarker/face_landmarker/float16/1/face_landmarker.task

## Technical Notes

- Method channel `asl/offline/landmarks` — hand landmarker init + frame processing  
- Method channel `asl/offline/face` — face landmarker init + frame processing  
- Hand pipeline: camera → JPEG → MediaPipe landmarks → 42 features → TFLite → smoothing → text  
- Lips pipeline: camera → Face Landmarker blendshapes → `LipsingDetector` → UI  
- Translation: `SignTranslationEngine` plays letter PNGs and word GIFs  

## Important

- Missing `hand_landmarker.task` → ASL recognition fails to initialize  
- Missing `face_landmarker.task` → Lips Detection fails with a clear error  
- Voice-to-sign needs mic permission (Android `RECORD_AUDIO`, iOS mic + speech recognition)  
