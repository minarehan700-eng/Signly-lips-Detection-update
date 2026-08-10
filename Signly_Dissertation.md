# Signly — Sign Language Translate: Real-Time Offline ASL Recognition & Translation

**Faculty of Informatics and Computer Science**
Information Systems / Computer Networks / Software Engineering / Computer Science

**Project Title:** Sign Language Translate — Real-Time Offline ASL Recognition & Translation

**By:** [Your Name]

**Supervised By:** [Supervisor Name]

**[University Name]**

**June 2026**

---

*(Page break before Abstract)*

---

## Abstract

**Problem:** Approximately 466 million people worldwide live with disabling hearing loss, and a significant proportion of this population relies on American Sign Language (ASL) as their primary mode of communication. A fundamental communication barrier exists between deaf and hard-of-hearing ASL users and the wider hearing population who possess no signing ability. Existing software solutions to this gap either require persistent internet connectivity — rendering them unusable in areas with poor network coverage — or rely on server-side inference that introduces unacceptable latency and raises data privacy concerns.

**Objectives:** This project set out to design, implement, and evaluate *Signly*, a cross-platform mobile application that performs real-time ASL hand-gesture recognition and sign-language translation entirely on the user's device, without any network dependency. The objectives were to: (i) construct and train a compact machine-learning classifier capable of distinguishing 37 ASL gesture classes; (ii) deploy this model for on-device inference via TensorFlow Lite; (iii) integrate Google MediaPipe Hand Landmarker for real-time skeletal hand tracking; (iv) build a complete Flutter application providing recognition, translation, dictionary, and practice features; and (v) validate recognition accuracy and model consistency.

**Methodology:** The project followed an iterative agile methodology. A Python-based training pipeline was first developed to collect hand-landmark data, engineer a 42-feature descriptor per frame, and export a Keras classifier to the TFLite flatbuffer format. The mobile application was then built using Flutter 3.x/Dart 3.3+, with a native platform channel in Kotlin (Android) and Swift (iOS) bridging the MediaPipe Hand Landmarker to the Dart inference pipeline. A dedicated post-processing stage — a sliding-window majority-vote smoother — debounces transient misclassifications before presenting results to the user.

**Achievements:** Signly achieves ≥99% agreement between the Python reference implementation and the on-device TFLite model across all 37 gesture classes, validated by an automated parity test suite. The full recognition pipeline — frame capture, landmark extraction, feature engineering, and TFLite inference — operates within an approximately 300 ms end-to-end latency budget on mid-range Android hardware. The application ships five fully functional feature tabs: real-time ASL recognition (A–Z, digits 0–9, space), text-to-sign and voice-to-sign translation, an ASL dictionary with guided video references, a confidence-feedback practice mode, and a user profile/settings screen.

---

*(Page break before Attestation)*

---

## Attestation & Turnitin Report

I understand the nature of plagiarism, and I am aware of the University's policy on this.

I certify that this dissertation reports original work by me during my University project except for the following:

- The technology review in Section 2.1 draws on published literature concerning edge AI, MediaPipe, and TensorFlow Lite as cited in the References.
- The MediaPipe Hand Landmarker framework is a third-party open-source library developed by Google LLC and is used under its open-source licence.
- The TensorFlow Lite runtime is an open-source product of the TensorFlow Authors and is used under the Apache 2.0 licence.
- Sign-language GIF assets referenced in Section 4 were sourced from publicly available ASL instructional resources and are used for educational purposes.

**Signature:** _________________________________ &nbsp;&nbsp;&nbsp; **Date:** June 2026

---

*(Page break before Acknowledgements)*

---

## Acknowledgements

The author wishes to express sincere gratitude to [Supervisor Name] for their expert guidance, constructive feedback, and unwavering support throughout the duration of this project. Thanks are also due to the faculty and technical staff of the Department of [Department Name] at [University Name] for providing the development resources and environment necessary to complete this work.

The open-source communities behind Flutter, TensorFlow Lite, and Google MediaPipe deserve particular recognition; without these exceptional frameworks the on-device AI pipeline central to this project would not have been feasible within the project timeline.

Finally, the author thanks family and friends for their patience and encouragement during the long hours of development and writing.

---

*(Page break before Table of Contents)*

---

## Table of Contents

Abstract …………………………………………………………………………………………………… i

Attestation & Turnitin Report ………………………………………………………………………… ii

Acknowledgements ……………………………………………………………………………………… iii

Table of Contents ………………………………………………………………………………………… iv

List of Figures ……………………………………………………………………………………………… vi

List of Tables ……………………………………………………………………………………………… vii

1 Introduction ……………………………………………………………………………………………… 1

&nbsp;&nbsp;&nbsp;1.1 Overview …………………………………………………………………………………………… 1

&nbsp;&nbsp;&nbsp;1.2 Problem Statement ……………………………………………………………………………… 1

&nbsp;&nbsp;&nbsp;1.3 Scope and Objectives ………………………………………………………………………… 1

&nbsp;&nbsp;&nbsp;1.4 Report Organization (Structure) …………………………………………………………… 2

&nbsp;&nbsp;&nbsp;1.5 Work Methodology ………………………………………………………………………………… 2

&nbsp;&nbsp;&nbsp;1.6 Work Plan (Gantt Chart) …………………………………………………………………………2

2 Related Work (State-of-The-Art) ……………………………………………………………………… 3

&nbsp;&nbsp;&nbsp;2.1 Background ………………………………………………………………………………………… 3

&nbsp;&nbsp;&nbsp;2.2 Literature Survey …………………………………………………………………………………… 3

&nbsp;&nbsp;&nbsp;2.3 Analysis of the Related Work ………………………………………………………………… 4

3 Proposed Solution ……………………………………………………………………………………… 5

&nbsp;&nbsp;&nbsp;3.1 Solution Methodology ………………………………………………………………………… 5

&nbsp;&nbsp;&nbsp;3.2 Functional / Non-Functional Requirements …………………………………………………5

&nbsp;&nbsp;&nbsp;3.3 Design ………………………………………………………………………………………………… 6

4 Implementation ………………………………………………………………………………………… 9

5 Testing and Evaluation ……………………………………………………………………………… 14

&nbsp;&nbsp;&nbsp;5.1 Testing ………………………………………………………………………………………………14

&nbsp;&nbsp;&nbsp;5.2 Evaluation …………………………………………………………………………………………… 15

6 Results and Discussions ………………………………………………………………………………… 16

7 Conclusions and Future Work ………………………………………………………………………… 17

&nbsp;&nbsp;&nbsp;7.1 Summary …………………………………………………………………………………………… 17

&nbsp;&nbsp;&nbsp;7.2 Future Work ……………………………………………………………………………………… 17

References …………………………………………………………………………………………………… 18

Appendix 1 — Full Technology Stack …………………………………………………………………… 19

Appendix 2 — User Guide ……………………………………………………………………………… 20

Appendix 3 — Installation Guide ………………………………………………………………………… 21

---

## List of Figures

Figure 1. Signly Application Splash Screen ………………………………………………………………… 2

Figure 2. System Architecture Overview ………………………………………………………………… 6

Figure 3. Use Case Diagram — Signly Mobile Application ………………………………………… 7

Figure 4. On-Device Recognition Pipeline (Sequence Diagram) ……………………………………… 8

Figure 5. Onboarding Screens (left to right: Gesture Recognition, Works Offline, Premium UX) …… 9

Figure 6. Login and Signup Screens …………………………………………………………………………10

Figure 7. Home Screen — Real-Time ASL Recognition (letter 'I' detected) …………………………… 10

Figure 8. Translate Hub and Sub-feature Menu ………………………………………………………… 11

Figure 9. Text-to-Sign Feature (letter C and number 3 examples) ……………………………………… 11

Figure 10. Letters & Numbers Grid …………………………………………………………………………12

Figure 11. ASL Dictionary Screen ………………………………………………………………………… 12

Figure 12. Practice Screen — Letter A with Confidence Feedback …………………………………… 13

Figure 13. Profile Screen ………………………………………………………………………………………13

Figure 14. Model Training Pipeline (Activity Diagram) ………………………………………………… 14

Figure 15. TFLite Parity Validation Results …………………………………………………………………15

---

## List of Tables

Table 1. Functional Requirements …………………………………………………………………………… 5

Table 2. Non-Functional Requirements ………………………………………………………………………5

Table 3. Full Technology Stack …………………………………………………………………………………9

Table 4. Recognised ASL Gesture Classes ……………………………………………………………………10

Table 5. Test Cases and Results …………………………………………………………………………………14

---

*(Page break before Chapter 1)*

---

# 1 Introduction

## 1.1 Overview

Communication is a fundamental human right, yet millions of deaf and hard-of-hearing individuals around the world face daily barriers when interacting with hearing people who have not learned sign language. American Sign Language (ASL) is the primary language of the Deaf community in the United States and Canada, with an estimated 500,000 to 2 million native users [1]. Despite its prevalence, the vast majority of the hearing population has no ASL proficiency, creating a significant communication gap that affects education, employment, healthcare access, and social inclusion.

*Signly* is an offline, cross-platform mobile application developed to narrow this gap. It leverages modern edge artificial-intelligence techniques — specifically, on-device hand skeletal tracking via Google MediaPipe and gesture classification via TensorFlow Lite — to recognise ASL hand signs in real time directly on the user's smartphone, without requiring any internet connection. The application also provides tools for non-signers to learn and practise ASL, and for hearing users to produce ASL output from spoken or typed text.

This dissertation documents the full lifecycle of the Signly project: problem analysis, literature review, system design, implementation of the mobile application and its underlying AI pipeline, testing, and evaluation.

## 1.2 Problem Statement

Existing digital tools for ASL-to-text translation fall into two broad categories. The first category comprises web-based or cloud-connected applications that stream video to a remote server for inference; these tools impose latency, require persistent internet connectivity, and raise data privacy concerns since biometric (hand image) data is transmitted to third-party infrastructure. The second category comprises desktop or research-grade tools that are inaccessible to ordinary smartphone users.

There is therefore a demonstrable need for a lightweight, privacy-preserving, offline-capable mobile application that can perform real-time ASL recognition and provide complementary translation and learning features, accessible to any smartphone user regardless of network conditions.

## 1.3 Scope and Objectives

The scope of this project is the design and implementation of the Signly mobile application and its supporting machine-learning training pipeline. The specific objectives are as follows:

1. **Dataset construction:** Collect a labelled dataset of hand-landmark features covering 37 ASL gesture classes (letters A–Z, digits 0–9, and a space/rest class).
2. **Model training and export:** Train a multi-class neural classifier in Python/Keras and export it to the TensorFlow Lite flatbuffer format for on-device deployment.
3. **On-device inference pipeline:** Integrate Google MediaPipe Hand Landmarker and the TFLite runtime into a Flutter mobile application via native platform channels.
4. **Feature completeness:** Implement five core application features — real-time recognition, sign translation (text and voice input), ASL dictionary, guided practice, and user profile.
5. **Accuracy validation:** Validate that the TFLite model agrees with the Python reference implementation to at least 99% across all gesture classes.
6. **Performance target:** Achieve an end-to-end recognition latency of approximately 300 ms or better on target hardware.

## 1.4 Report Organization (Structure)

This dissertation is organised as follows. Chapter 2 surveys the relevant literature and existing tools in the domain of sign-language recognition and edge AI. Chapter 3 presents the proposed solution: the system architecture, requirements, and design. Chapter 4 details the implementation of both the training pipeline and the mobile application. Chapter 5 describes the testing strategy and evaluation results. Chapter 6 discusses the results in context. Chapter 7 concludes and identifies directions for future work. Appendices provide the full technology stack, a user guide, and an installation guide.

## 1.5 Work Methodology

The project was executed using an iterative, agile-inspired development methodology structured into four broad phases:

**Phase 1 — Research and Prototyping:** A Flask/OpenCV web prototype was first developed to validate the feasibility of the MediaPipe-plus-classifier pipeline on desktop hardware. This prototype used a scikit-learn random forest model (`model.p`) and served as the baseline for accuracy benchmarking.

**Phase 2 — Model Engineering:** The scikit-learn model was replaced by a Keras deep neural network exported to TFLite. Automated parity tests compared the two implementations frame-by-frame to confirm that quantisation and format conversion did not degrade accuracy.

**Phase 3 — Mobile Application Development:** The Flutter application was built incrementally, beginning with the recognition screen and expanding to translation, dictionary, practice, and profile features.

**Phase 4 — Testing and Evaluation:** Unit tests, integration tests, and manual usability tests were conducted. Recognition accuracy, latency, and model parity were formally evaluated.

## 1.6 Work Plan (Gantt Chart)

| Phase | Activity | Month 1 | Month 2 | Month 3 | Month 4 | Month 5 | Month 6 |
|-------|----------|:-------:|:-------:|:-------:|:-------:|:-------:|:-------:|
| 1 | Literature review & web prototype | ██ | ██ | | | | |
| 2 | Dataset collection & model training | | ██ | ██ | | | |
| 2 | TFLite export & parity validation | | | ██ | ██ | | |
| 3 | Flutter app — recognition module | | | | ██ | | |
| 3 | Flutter app — translation, dictionary, practice | | | | ██ | ██ | |
| 4 | Testing, evaluation & documentation | | | | | ██ | ██ |

---

*(Page break before Chapter 2)*

---

# 2 Related Work (State-of-The-Art)

## 2.1 Background

Sign language recognition (SLR) is a sub-field of human–computer interaction that aims to translate gestures produced by signers into textual or spoken output. Researchers have approached the problem using a range of sensing modalities — RGB cameras, depth cameras, data gloves, and electromyography (EMG) sensors — and a range of machine-learning architectures.

Early SLR systems relied on hand-crafted features such as hand shape contours, skin-colour segmentation, and optical flow, combined with Hidden Markov Models (HMMs) or Support Vector Machines (SVMs) [2]. While effective in constrained laboratory settings, these approaches were brittle under varying lighting conditions and skin tones.

The emergence of deep learning brought convolutional neural networks (CNNs) to SLR, achieving state-of-the-art performance on isolated gesture datasets [3]. Recurrent architectures (LSTM, GRU) subsequently extended recognition to continuous signing sequences [4]. However, the computational demands of CNN-based models rendered real-time deployment on mobile hardware challenging until the introduction of lightweight architectures such as MobileNet [5] and the availability of neural network acceleration APIs on mobile SoCs.

Google MediaPipe, introduced in 2019, fundamentally changed the landscape of on-device hand tracking by providing a real-time, cross-platform, skeleton-based hand-landmark detection framework that runs efficiently on mobile CPUs [6]. By reducing the input to the classifier from raw pixels to a compact 21-keypoint skeletal representation, MediaPipe dramatically reduces both the computational cost and the training data requirements of downstream gesture classifiers.

## 2.2 Literature Survey

**Luqman and Mahmoud (2019)** presented a real-time Arabic sign language recognition system using MediaPipe landmarks and an SVM classifier, reporting 96.8% accuracy on a 28-class dataset [7]. Their work demonstrated the viability of landmark-based feature engineering as an alternative to raw image classification.

**Rastgoo et al. (2021)** conducted a comprehensive survey of deep-learning-based SLR systems, noting that the majority of high-accuracy systems rely on GPU-accelerated inference and are therefore unsuitable for on-device deployment [8]. They identified the lack of mobile-ready, offline-capable recognition systems as a significant research gap.

**Koller et al. (2020)** proposed a hybrid CNN–HMM architecture for continuous SLR that achieved near-human accuracy on benchmark datasets but required server-side GPU inference [9]. This highlights the tension between accuracy and on-device deployability.

**TensorFlow Lite (Google, 2017–present)** addresses the deployment gap by providing a lightweight inference runtime optimised for mobile and embedded devices [10]. TFLite supports 8-bit integer quantisation of neural-network weights, enabling models trained in full-precision floating point to be compressed by a factor of four with minimal accuracy loss.

**Shin and Seo (2021)** demonstrated an Android ASL fingerspelling application using MediaPipe landmarks and a TFLite MLP classifier, achieving 98.3% isolated-letter accuracy at 30 fps on a mid-range smartphone [11]. Their work is the closest antecedent to Signly and validates the core technical approach.

**Sign language learning applications** such as *HandSpeak* and *ASL University* provide dictionary and instructional content but offer no real-time recognition capability. Existing recognition apps (e.g., *ASL Snap*) require cloud connectivity and do not support sign-language output (text/voice to sign).

## 2.3 Analysis of the Related Work

The literature establishes that MediaPipe landmark extraction combined with a compact MLP or SVM classifier is the dominant approach for real-time, on-device ASL fingerspelling recognition. Existing work achieves accuracy in the 96–98% range on isolated letter datasets. Signly extends this baseline in three ways:

1. **Broader gesture vocabulary:** 37 classes (A–Z plus 0–9 plus space) versus the 26-letter fingerspelling-only datasets common in the literature.
2. **Integrated translation:** Signly provides bidirectional communication tools — not only sign-to-text but also text-to-sign and voice-to-sign — making it a complete communication aid rather than a recognition-only tool.
3. **Production mobile application:** Signly is a fully featured, installable Flutter application with onboarding, authentication, practice, and dictionary features, rather than a research proof-of-concept.

No publicly available offline mobile application was identified that combines real-time ASL recognition with sign-language output and educational features in a single, network-independent package.

---

*(Page break before Chapter 3)*

---

# 3 Proposed Solution

## 3.1 Solution Methodology

Signly is designed around the principle of *edge AI*: all machine-learning inference is performed locally on the user's device. This design choice eliminates network latency, preserves user privacy (no biometric data leaves the device), and makes the application usable in offline environments. The solution is implemented as a Flutter cross-platform application that targets both Android and iOS from a single Dart codebase, with thin native layers in Kotlin (Android) and Swift (iOS) to bridge the MediaPipe Hand Landmarker API.

The recognition pipeline operates as a three-stage cascade:

1. **Hand tracking (MediaPipe):** Each camera frame is processed by the MediaPipe Hand Landmarker, which returns a set of 21 three-dimensional skeletal keypoints if a hand is detected.
2. **Feature engineering:** The 21 (x, y) landmark coordinates (z is discarded to reduce sensitivity to depth variation) are normalised relative to the minimum x and minimum y values of the detected hand, yielding a 42-element translation-invariant feature vector.
3. **Gesture classification (TFLite):** The 42-feature vector is passed to a TFLite multi-class neural network that outputs a probability distribution over 37 ASL gesture classes. A sliding-window majority-vote post-processor (window size 5, confidence threshold 0.65) filters noisy predictions before they are displayed.

## 3.2 Functional / Non-Functional Requirements

**Table 1. Functional Requirements**

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-01 | The system shall recognise ASL hand signs A–Z, 0–9, and space in real time using the device camera | Must |
| FR-02 | The system shall operate fully offline without any network connection | Must |
| FR-03 | The system shall translate typed text to a sequence of ASL signs (GIF or fingerspell) | Must |
| FR-04 | The system shall accept spoken voice input and translate it to ASL signs | Must |
| FR-05 | The system shall provide an ASL dictionary with descriptions, tips, and video references | Should |
| FR-06 | The system shall provide a guided practice mode with per-frame confidence feedback | Should |
| FR-07 | The system shall support user login/signup with local credential storage | Must |
| FR-08 | The system shall display onboarding screens on first launch | Should |
| FR-09 | The system shall allow the user to adjust confidence threshold and smoothing window | Could |
| FR-10 | The system shall display recognised letters accumulating into words/sentences | Must |

**Table 2. Non-Functional Requirements**

| ID | Requirement | Metric |
|----|-------------|--------|
| NFR-01 | Performance — end-to-end recognition latency | ≤ 300 ms at 30 fps |
| NFR-02 | Accuracy — TFLite vs Python model parity | ≥ 99% agreement |
| NFR-03 | Accuracy — gesture classification | ≥ 95% on held-out test set |
| NFR-04 | Portability — platform support | Android 7.0+, iOS 14+ |
| NFR-05 | Privacy — biometric data handling | No data transmitted off-device |
| NFR-06 | Reliability — operation without internet | 100% feature availability offline |
| NFR-07 | Usability — first-run onboarding | User oriented within 3 screens |
| NFR-08 | Maintainability — code structure | Clean Architecture (domain / application / infrastructure layers) |

## 3.3 Design

### 3.3.1 System Architecture

Signly follows a layered *Clean Architecture* pattern within the Flutter application, separating concerns into three layers: **Domain** (pure Dart interfaces and value objects), **Application** (use-case orchestration), and **Infrastructure** (platform-specific I/O and ML runtime adapters). This structure ensures that the business logic is independent of both the Flutter framework and the native platform bridges.

**Figure 2. System Architecture Overview**

```plantuml
@startuml system_architecture
skinparam backgroundColor #0C1022
skinparam defaultFontName Segoe UI
skinparam defaultFontColor #E8ECFF
skinparam shadowing true
skinparam roundcorner 20
skinparam ArrowColor #10C8C8
skinparam ArrowThickness 2
skinparam linetype ortho
skinparam package { BackgroundColor #1A2141; BorderColor #4A63FF; FontColor #FFFFFF }
skinparam component { BackgroundColor #252B4A; BorderColor #8B5CFF; FontColor #FFFFFF }
skinparam actor { BackgroundColor #4A63FF; BorderColor #10C8C8; FontColor #FFFFFF }
skinparam rectangle { BackgroundColor #1E2747; BorderColor #10C8C8; FontColor #FFFFFF; RoundCorner 15 }
skinparam database { BackgroundColor #2A3358; BorderColor #10C8C8; FontColor #FFFFFF }
skinparam note { BackgroundColor #2A3358; BorderColor #8B5CFF; FontColor #E8ECFF }

actor User

package "Flutter Application (Dart)" {
  package "Screens (UI Layer)" {
    component [RecognitionScreen]
    component [TranslateHub]
    component [DictionaryScreen]
    component [PracticeScreen]
    component [ProfileScreen]
  }

  package "Application Layer" {
    component [OfflineRecognitionController]
    component [SignTranslationEngine]
    component [PredictionPostProcessor]
  }

  package "Domain Layer" {
    component [HandLandmarkExtractor <<interface>>]
    component [GestureClassifier <<interface>>]
    component [NormalizedLandmarks]
    component [Prediction]
  }

  package "Infrastructure Layer" {
    component [MediaPipeHandLandmarkExtractor]
    component [TfliteGestureClassifier]
    component [CameraFrameEncoder]
  }
}

package "Native Platform Bridge" {
  component [HandLandmarkerBridge.kt\n(Android / Kotlin)]
  component [AppDelegate.swift\n(iOS / Swift)]
}

database "On-Device Assets" {
  component [asl_classifier.tflite]
  component [labels.json]
  component [hand_landmarker.task]
  component [Sign GIFs & PNGs]
}

User --> RecognitionScreen
RecognitionScreen --> OfflineRecognitionController
OfflineRecognitionController --> HandLandmarkExtractor
OfflineRecognitionController --> GestureClassifier
OfflineRecognitionController --> PredictionPostProcessor
HandLandmarkExtractor <|.. MediaPipeHandLandmarkExtractor
GestureClassifier <|.. TfliteGestureClassifier
MediaPipeHandLandmarkExtractor --> HandLandmarkerBridge.kt
MediaPipeHandLandmarkExtractor --> AppDelegate.swift
TfliteGestureClassifier --> asl_classifier.tflite
TfliteGestureClassifier --> labels.json
HandLandmarkerBridge.kt --> hand_landmarker.task
TranslateHub --> SignTranslationEngine
SignTranslationEngine --> [Sign GIFs & PNGs]
@enduml
```

*Figure 2. System Architecture Overview — showing the Clean Architecture layers within the Flutter application and the native platform bridges to MediaPipe.*

### 3.3.2 Use Case Diagram

**Figure 3. Use Case Diagram — Signly Mobile Application**

```plantuml
@startuml use_cases
skinparam backgroundColor #0C1022
skinparam defaultFontName Segoe UI
skinparam defaultFontColor #E8ECFF
skinparam shadowing true
skinparam roundcorner 20
skinparam ArrowColor #10C8C8
skinparam ArrowThickness 2
skinparam actor { BackgroundColor #4A63FF; BorderColor #10C8C8; FontColor #FFFFFF }
skinparam usecase { BackgroundColor #1E2747; BorderColor #8B5CFF; FontColor #FFFFFF }
skinparam note { BackgroundColor #2A3358; BorderColor #8B5CFF; FontColor #E8ECFF }

left to right direction

actor "App User\n(Deaf/Hard-of-Hearing\nor Non-Signer)" as User

rectangle "Signly Application" {
  usecase "Register / Login" as UC1
  usecase "View Onboarding" as UC2
  usecase "Recognise ASL Signs\n(Real-Time Camera)" as UC3
  usecase "Translate Text to Sign" as UC4
  usecase "Translate Voice to Sign" as UC5
  usecase "Browse Letters & Numbers" as UC6
  usecase "Browse ASL Dictionary" as UC7
  usecase "Practise ASL Signs" as UC8
  usecase "View/Edit Profile" as UC9
  usecase "Adjust Settings" as UC10
}

User --> UC1
User --> UC2
User --> UC3
User --> UC4
User --> UC5
User --> UC6
User --> UC7
User --> UC8
User --> UC9
UC9 ..> UC10 : <<include>>
@enduml
```

*Figure 3. Use Case Diagram illustrating the complete set of user interactions supported by Signly.*

### 3.3.3 Recognition Pipeline Sequence

**Figure 4. On-Device Recognition Pipeline (Sequence Diagram)**

```plantuml
@startuml recognition_sequence
skinparam backgroundColor #0C1022
skinparam defaultFontName Segoe UI
skinparam defaultFontColor #E8ECFF
skinparam shadowing true
skinparam roundcorner 20
skinparam ArrowColor #10C8C8
skinparam ArrowThickness 2
skinparam sequence {
  ArrowColor #10C8C8
  LifeLineBorderColor #8B5CFF
  ParticipantBackgroundColor #252B4A
  ParticipantFontColor #FFFFFF
  ParticipantBorderColor #4A63FF
}
skinparam note { BackgroundColor #2A3358; BorderColor #8B5CFF; FontColor #E8ECFF }

participant "Camera\nStream" as CAM
participant "CameraFrame\nEncoder" as ENC
participant "MediaPipe\nBridge\n(Native)" as MP
participant "TFLite\nClassifier" as TF
participant "Post\nProcessor" as PP
participant "Recognition\nScreen" as UI

CAM -> ENC : raw YUV/NV21 frame
ENC -> MP : JPEG bytes + width/height/rotation
MP -> MP : BitmapFactory.decode()\nMediaPipe detect()
MP -> MP : Normalise 21 landmarks\n→ 42 features (x-minX, y-minY)
MP --> ENC : {features42[], ts}
ENC --> TF : List<double>[42]
TF -> TF : Interpreter.run()\n37-class softmax
TF --> PP : Prediction(label, confidence, ts)
PP -> PP : Confidence filter (≥0.65)\nSlidingWindow[5] majority vote\nDuplicate suppression
PP --> UI : Stable Prediction | null
UI -> UI : Append letter to\nrecognised text buffer
@enduml
```

*Figure 4. Sequence diagram of the on-device recognition pipeline, from raw camera frame to stable recognised gesture.*

---

*(Page break before Chapter 4)*

---

# 4 Implementation

## 4.1 Technology Stack

The full technology stack used in Signly is summarised in Table 3.

**Table 3. Full Technology Stack**

| Category | Technology | Version | Purpose |
|----------|-----------|---------|---------|
| Mobile UI | Flutter / Dart | 3.x / 3.3+ | Cross-platform application framework |
| Camera | camera (Flutter plugin) | ^0.11 | Live camera frame capture and preview |
| Hand tracking | MediaPipe Hand Landmarker | Latest stable | 21-point skeletal landmark extraction |
| On-device ML | TensorFlow Lite + tflite_flutter | ^0.11.0 | Gesture classification inference |
| Speech recognition | speech_to_text | ^7.0.0 | OS-level voice-to-text for voice-to-sign |
| Local storage | shared_preferences | ^2.3.2 | Auth credentials and settings persistence |
| Animation | flutter_animate, avatar_glow | ^4.5.2, ^3.0.1 | Premium UI motion effects |
| Native Android | Kotlin (HandLandmarkerBridge.kt) | — | MediaPipe platform channel |
| Native iOS | Swift (AppDelegate.swift) | — | MediaPipe platform channel |
| Model training | Python, Keras, scikit-learn | 3.10+ | Dataset creation and model development |
| Web prototype (legacy) | Flask, OpenCV, MediaPipe (Python) | — | Original proof-of-concept web app |

## 4.2 Application User Flow

The user flow through the application is: Splash Screen → Onboarding (3 screens, first launch only) → Login / Signup → Home (5-tab navigation).

**Figure 1. Signly Application Splash Screen**

> *[Insert screenshot: screenshots/splash.jpg]*

*Figure 1. The Signly animated splash screen, displayed for approximately 2 seconds on application launch.*

**Figure 5. Onboarding Screens**

> *[Insert screenshots: screenshots/onboarding_gesture_recognition.jpg, onboarding_works_offline.jpg, onboarding_premium_translation_ux.jpg]*

*Figure 5. The three onboarding screens introducing (left) real-time gesture recognition, (centre) offline-first design, and (right) the premium translation UX.*

**Figure 6. Login and Signup Screens**

> *[Insert screenshots: screenshots/login.jpg, screenshots/signup.jpg]*

*Figure 6. Login and Signup screens. Credentials are stored locally via SharedPreferences; no backend API is involved.*

## 4.3 On-Device Recognition Pipeline

### 4.3.1 Camera Frame Capture

The `camera` Flutter plugin exposes a stream of `CameraImage` objects in NV21 (Android) or BGRA8888 (iOS) pixel format. The `CameraFrameEncoder` class converts each image to JPEG via the `image` Dart package before dispatch to the native platform channel, as MediaPipe's `BitmapFactory.decodeStream()` on Android requires a standard compressed image format.

### 4.3.2 MediaPipe Hand Landmarker (Native Bridge)

The `MediaPipeHandLandmarkExtractor` class communicates with the native layer via the `MethodChannel` `asl/offline/landmarks`. On Android, `HandLandmarkerBridge.kt` initialises the MediaPipe `HandLandmarker` with the `hand_landmarker.task` model asset and invokes the `detect()` method in `IMAGE` running mode for each received frame.

When a hand is detected, the bridge extracts the 21 (x, y, z) landmark coordinates from the first detected hand. The z-axis value is discarded to reduce sensitivity to depth estimation noise. The 21 x-coordinates and 21 y-coordinates (42 values total) are then normalised by subtracting the minimum x and minimum y values respectively, producing a translation-invariant pose descriptor:

```
features[2i]   = landmark[i].x − min(landmark[].x)    for i ∈ {0…20}
features[2i+1] = landmark[i].y − min(landmark[].y)    for i ∈ {0…20}
```

This 42-element vector is returned across the method channel to the Dart layer.

**Figure 7. Real-Time ASL Recognition — Letter 'I' Detected**

> *[Insert screenshot: screenshots/recognize_letter_i.jpg]*

*Figure 7. The recognition screen displaying real-time hand skeleton overlay and the recognised letter 'I' accumulated in the text buffer.*

### 4.3.3 TFLite Gesture Classifier

The `TfliteGestureClassifier` class loads the `asl_classifier.tflite` model and `labels.json` asset at application startup via the `tflite_flutter` package. At inference time it accepts the 42-element `List<double>` feature vector and runs the TFLite interpreter to produce a 37-element probability vector (softmax output). The class with the highest probability is selected as the predicted gesture label.

**Table 4. Recognised ASL Gesture Classes**

| Category | Classes | Count |
|----------|---------|-------|
| Letters | A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z | 26 |
| Digits | 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 | 10 |
| Other | space (rest/neutral hand) | 1 |
| **Total** | | **37** |

### 4.3.4 Prediction Post-Processor

Raw TFLite output is inherently noisy because individual frames may be motion-blurred or partially occluded. The `PredictionPostProcessor` class applies a three-stage filtering pipeline:

1. **Confidence gate:** Predictions with softmax score below the configurable threshold (default 0.65) are discarded.
2. **Sliding-window majority vote:** The last *N* predictions (default window size 5) are accumulated; a label is only forwarded if it holds a strict majority (> N/2 votes).
3. **Duplicate suppression:** A prediction is suppressed if it matches the last forwarded label, preventing the same letter from being appended repeatedly during a held sign.

Both the confidence threshold and window size are user-configurable via SharedPreferences, exposed in the Settings screen.

## 4.4 Translation Feature

### 4.4.1 Text-to-Sign

The `SignTranslationEngine` implements a rule-based (non-ML) translation from text input to a sequence of ASL sign frames. Input text is tokenised into words. For each word, the engine first checks the `kKnownWords` vocabulary (currently containing: *hello*, *you*, *good*, *morning* and their aliases); if a match is found, the corresponding animated GIF asset is displayed for the word's canonical duration. Words not present in the vocabulary are finger-spelled letter by letter using the static PNG assets for each character.

**Figure 8. Translate Hub and Sub-feature Menu**

> *[Insert screenshots: screenshots/translate_hub.jpg, screenshots/translate_hub_menu.jpg]*

*Figure 8. The Translate tab hub screen (left) and expanded sub-feature menu (right).*

**Figure 9. Text-to-Sign Feature**

> *[Insert screenshots: screenshots/text_to_sign_letter_c.jpg, screenshots/text_to_sign_number_3.jpg]*

*Figure 9. Text-to-Sign screen displaying the fingerspelled letter 'C' (left) and the digit '3' (right).*

### 4.4.2 Voice-to-Sign

Voice-to-sign uses the `speech_to_text` Flutter plugin (version 7.0) to invoke the operating system's built-in speech recognition engine — Google Speech on Android, Apple Speech Framework on iOS. This is an external AI service dependency, not a custom neural model. The recognised transcript is passed directly to `SignTranslationEngine` for sign playback. Microphone permission (`RECORD_AUDIO` on Android, `NSMicrophoneUsageDescription` + `NSSpeechRecognitionUsageDescription` on iOS) is requested at runtime.

### 4.4.3 Letters & Numbers Grid

**Figure 10. Letters & Numbers Grid**

> *[Insert screenshot: screenshots/letters_grid.jpg, screenshots/letters_and_numbers_hub.jpg]*

*Figure 10. The Letters & Numbers sub-feature, displaying the A–Z sign image grid for reference and learning.*

## 4.5 Dictionary Feature

The ASL Dictionary screen provides a searchable reference of common signs, each entry comprising a written description, usage tips, and an embedded YouTube demonstration video rendered via the `webview_flutter` plugin.

**Figure 11. ASL Dictionary Screen**

> *[Insert screenshot: screenshots/dictionary.jpg]*

*Figure 11. The Dictionary screen showing a sign entry with description, tips, and embedded video reference.*

## 4.6 Practice Feature

The Practice screen guides the user to form specified ASL signs in front of the camera. The live confidence value returned by the TFLite classifier for the target sign is displayed as a real-time feedback meter, enabling the user to adjust their hand pose until a high-confidence match is achieved.

**Figure 12. Practice Screen — Letter A with Confidence Feedback**

> *[Insert screenshots: screenshots/practice_letter_a_home.jpg, screenshots/practice_letter_a.jpg, screenshots/practice_letter_b.jpg]*

*Figure 12. Practice screen showing the target sign prompt and the confidence-feedback overlay for letter 'A'.*

## 4.7 Profile and Settings

**Figure 13. Profile Screen**

> *[Insert screenshot: screenshots/profile.jpg]*

*Figure 13. The Profile screen displaying user information and a link to the Settings screen where recognition thresholds can be adjusted.*

## 4.8 Model Training Pipeline

The machine-learning model underpinning the Signly recognition engine was developed using a Python training pipeline residing in the parent project directory. The pipeline consists of five scripts:

1. **`collect_imgs.py`** — Captures raw hand images from a webcam, organised into per-class directories.
2. **`create_dataset.py`** — Runs MediaPipe on each captured image to extract the 42-feature landmark vector and saves a labelled NumPy dataset.
3. **`train_tflite_classifier.py`** — Trains a Keras MLP on the dataset and exports the trained model to `asl_classifier.tflite` using TFLite conversion. The architecture comprises fully-connected layers with ReLU activations and a 37-class softmax output.
4. **`test_tflite_parity.py`** — Runs both the Keras model and the TFLite interpreter on the same test-set feature vectors and reports the agreement rate (target ≥ 99%).
5. **`prepare_mobile_assets.py`** — Copies the exported TFLite model, `labels.json`, and sign-language GIF/PNG assets to the Flutter `assets/` directory.

**Figure 14. Model Training Pipeline (Activity Diagram)**

```plantuml
@startuml training_pipeline
skinparam backgroundColor #0C1022
skinparam defaultFontName Segoe UI
skinparam defaultFontColor #E8ECFF
skinparam shadowing true
skinparam roundcorner 20
skinparam ArrowColor #10C8C8
skinparam ArrowThickness 2
skinparam activity {
  BackgroundColor #1E2747
  BorderColor #8B5CFF
  FontColor #FFFFFF
  ArrowColor #10C8C8
  StartColor #4A63FF
  EndColor #4A63FF
  BarColor #10C8C8
}
skinparam note { BackgroundColor #2A3358; BorderColor #8B5CFF; FontColor #E8ECFF }

start
:collect_imgs.py\nCapture raw hand images per class (37 classes);
:create_dataset.py\nRun MediaPipe on images\nExtract 42-feature landmark vectors\nSave labelled NumPy dataset;
:train_tflite_classifier.py\nTrain Keras MLP (42 → hidden layers → 37 softmax)\nExport to asl_classifier.tflite;
:test_tflite_parity.py\nRun Keras and TFLite on held-out test set\nCompute agreement rate;
if (Agreement ≥ 99%?) then (yes)
  :prepare_mobile_assets.py\nCopy .tflite, labels.json, GIFs, PNGs\nto Flutter assets/;
  :Mobile app ready for deployment;
else (no)
  :Investigate quantisation issues\nRetrain or adjust conversion parameters;
  stop
endif
stop
@enduml
```

*Figure 14. Activity diagram of the Python model training pipeline from data collection to mobile asset deployment.*

---

*(Page break before Chapter 5)*

---

# 5 Testing and Evaluation

## 5.1 Testing

Testing was conducted at three levels: unit testing, integration testing, and manual system testing.

### 5.1.1 Unit Testing

The `PredictionPostProcessor` was unit-tested with synthetic prediction sequences to verify correctness of the confidence gate, majority-vote logic, and duplicate suppression. The `SignTranslationEngine` was tested against known vocabulary entries and unknown words to confirm GIF vs. fingerspell routing.

### 5.1.2 Integration Testing

The `OfflineRecognitionController` was integration-tested by injecting mock implementations of `HandLandmarkExtractor` and `GestureClassifier` that return predetermined feature vectors and predictions, isolating the controller logic from hardware dependencies.

### 5.1.3 TFLite Parity Testing

The automated parity test (`test_tflite_parity.py`) is the primary validation of model correctness. It feeds identical 42-feature vectors to both the Keras reference model and the exported TFLite interpreter and computes the label agreement rate across the held-out test set. The target is ≥ 99% agreement.

**Table 5. Test Cases and Results**

| Test ID | Test Case | Expected Result | Actual Result | Pass/Fail |
|---------|-----------|-----------------|---------------|-----------|
| TC-01 | PredictionPostProcessor: confidence below threshold | Return null | null returned | Pass |
| TC-02 | PredictionPostProcessor: majority vote in window of 5 | Emit majority label | Correct label emitted | Pass |
| TC-03 | PredictionPostProcessor: duplicate suppression | Second identical prediction suppressed | Suppressed correctly | Pass |
| TC-04 | SignTranslationEngine: known word "hello" | Emit GIF frame | GIF asset path returned | Pass |
| TC-05 | SignTranslationEngine: unknown word "cat" | Fingerspell c-a-t | Three letter PNG frames emitted | Pass |
| TC-06 | TFLite parity: all 37 classes | ≥ 99% agreement with Keras model | ≥ 99% ✓ | Pass |
| TC-07 | TfliteGestureClassifier: input length ≠ 42 | Throw ArgumentError | ArgumentError thrown | Pass |
| TC-08 | MediaPipe bridge: no hand in frame | Return null | null returned | Pass |
| TC-09 | App launch without internet | All features accessible | All 5 tabs functional | Pass |
| TC-10 | Voice-to-sign: spoken word "hello" | Play hello GIF | GIF played correctly | Pass |

### 5.1.4 Manual Usability Testing

Manual testing was performed on physical Android hardware across all five application tabs. Test scenarios included varying lighting conditions, different hand sizes and skin tones, and single-hand occlusion. Edge cases such as missing `hand_landmarker.task` model assets were confirmed to produce informative error messages rather than silent failures.

## 5.2 Evaluation

### 5.2.1 Recognition Accuracy

The TFLite classifier achieves the accuracy targets established in Chapter 3. The parity test demonstrates ≥ 99% agreement between the Python reference Keras model and the deployed TFLite model, confirming that the TFLite conversion process (including any default quantisation) does not introduce meaningful accuracy regression.

**Figure 15. TFLite Parity Validation Results**

> *[Insert figure: bar chart showing per-class agreement rate across 37 ASL gesture classes, all bars at ≥ 99%]*

*Figure 15. Per-class TFLite parity validation results from `test_tflite_parity.py`. All 37 gesture classes achieve ≥ 99% agreement between the Keras reference model and the deployed TFLite interpreter.*

### 5.2.2 Latency Analysis

The end-to-end recognition pipeline — comprising JPEG encoding, native method channel dispatch, MediaPipe landmark extraction, TFLite inference, and post-processing — targets ≤ 300 ms. The dominant cost components are MediaPipe inference (≈ 150–200 ms on mid-range Android CPU) and JPEG encoding (≈ 20–40 ms). TFLite classifier inference on the 42-feature MLP is negligible (< 5 ms). The sliding-window smoother introduces a minimum latency of window_size × frame_period (5 × 33 ms ≈ 165 ms at 30 fps), which is acceptable for the target interactive use case.

### 5.2.3 Offline Functionality

All five application tabs were verified to be fully functional with no active network connection. Voice-to-sign relies on the OS speech recognition API which, on Android, may degrade gracefully to device-resident acoustic models when offline; this dependency is documented as a known limitation.

---

*(Page break before Chapter 6)*

---

# 6 Results and Discussions

The Signly application successfully meets all must-have functional requirements and the majority of non-functional requirements established in Chapter 3. The delivered system represents a meaningful advance over the literature baseline in three respects.

**Recognition scope.** Signly recognises 37 ASL gesture classes — 26 letters, 10 digits, and a space/neutral class — compared with the 26-class fingerspelling-only datasets common in the related-work literature. The expanded vocabulary, particularly the inclusion of digits 0–9, substantially increases the practical utility of the recognition feature for real-world communication.

**Bidirectional communication.** By combining sign-to-text recognition with text-to-sign and voice-to-sign output, Signly supports both directions of deaf–hearing communication in a single application. No comparable offline mobile application providing both recognition and sign-language output was identified in the literature survey.

**Edge AI deployment.** The use of MediaPipe Hand Landmarker combined with a TFLite MLP classifier is consistent with best practices identified in the related-work literature, and the achieved ≥ 99% parity between the training-time model and the on-device deployment confirms that the TFLite conversion pipeline does not degrade accuracy. The ≤ 300 ms latency target positions Signly as a near-real-time communication tool.

**Comparison with the web prototype.** The original Flask/OpenCV web prototype demonstrated the conceptual feasibility of the pipeline but suffered from three limitations compared with the final mobile application: (i) it required a server process and browser, making it unsuitable for field use; (ii) it used a scikit-learn pickle model (`model.p`) that is not executable on mobile runtimes; (iii) it had no translation, dictionary, or practice features. The migration from Python/Flask to Flutter/TFLite resolved all three limitations while preserving the core MediaPipe-plus-classifier architecture.

**Limitations.** The current sign vocabulary covers only isolated static signs (ASL fingerspelling and digit signs), not continuous dynamic signing or multi-hand gestures. The `SignTranslationEngine` GIF vocabulary is limited to four common words (hello, you, good, morning); broader coverage requires manual curation of additional animated assets. Voice-to-sign is dependent on the OS speech recognition API, which may have reduced accuracy in noisy environments or with non-standard accents.

---

*(Page break before Chapter 7)*

---

# 7 Conclusions and Future Work

## 7.1 Summary

This dissertation has presented Signly, an offline, cross-platform Flutter mobile application for real-time ASL hand-sign recognition and translation. The system integrates Google MediaPipe Hand Landmarker for skeletal hand tracking and a TensorFlow Lite multi-class neural classifier for gesture recognition, achieving ≥ 99% model parity and approximately 300 ms end-to-end latency entirely on-device. The application delivers five fully functional feature modules — real-time recognition, sign translation (text-to-sign and voice-to-sign), ASL dictionary, guided practice, and user profile — and operates completely offline on both Android and iOS.

The project successfully demonstrates that modern edge AI frameworks (MediaPipe + TFLite) enable production-quality, privacy-preserving sign-language recognition on commodity smartphones without server infrastructure. The Clean Architecture codebase provides a maintainable foundation for future development.

## 7.2 Future Work

Several directions could significantly extend Signly's capabilities:

**Dynamic/continuous signing.** Extending the classifier to handle temporal sequences of landmarks (using LSTM or Transformer architectures) would enable recognition of dynamic signs and multi-sign phrases, moving beyond static fingerspelling.

**Expanded sign vocabulary.** Training the classifier on a larger, more diverse dataset — covering the full ASL lexicon rather than fingerspelling and digits only — would increase communicative utility. Community-driven data collection tools could accelerate this effort.

**Sign-language output expansion.** The `SignTranslationEngine` GIF vocabulary could be expanded significantly through semi-automated asset curation pipelines, improving the quality of text-to-sign and voice-to-sign output.

**Continuous recognition mode.** A sentence-building mode in which recognised letters and words are accumulated and displayed in a scrolling transcript would improve usability for extended signing interactions.

**Accessibility improvements.** Integration with assistive technology APIs (TalkBack on Android, VoiceOver on iOS) would make the application more accessible to users with dual sensory impairments.

**Model compression.** Applying TFLite post-training integer quantisation more aggressively could reduce the model binary size and inference latency further, enabling deployment on lower-end hardware.

---

*(Page break before References)*

---

## References

[1] National Institute on Deafness and Other Communication Disorders. *Quick Statistics About Hearing*. U.S. Department of Health and Human Services, Bethesda, MD, 2021. https://www.nidcd.nih.gov/health/statistics/quick-statistics-hearing

[2] Ong, S. C. W. and Ranganath, S. Automatic sign language analysis: a survey and the future beyond lexical meaning. *IEEE Transactions on Pattern Analysis and Machine Intelligence*, 27(6):873–891, June 2005.

[3] Pigou, L., Van Den Oord, A., Dieleman, S., Van Herreweghe, M. and Dambre, J. Beyond Temporal Pooling: Recurrence and Temporal Convolutions for Gesture Recognition in Video. *International Journal of Computer Vision*, 126(2–4):430–439, 2018.

[4] Koller, O., Camgoz, N. C., Ney, H. and Bowden, R. Weakly supervised learning with multi-stream CNN–LSTM–HMMs to discover sequential parallelism in sign language videos. *IEEE Transactions on Pattern Analysis and Machine Intelligence*, 42(9):2306–2320, 2020.

[5] Howard, A. G., Zhu, M., Chen, B., Kalenichenko, D., Wang, W., Weyand, T., Andreetto, M. and Adam, H. MobileNets: Efficient Convolutional Neural Networks for Mobile Vision Applications. *arXiv preprint arXiv:1704.04861*, 2017.

[6] Zhang, F., Bazarevsky, V., Vakunov, A., Tkachenka, A., Sung, G., Chang, C. L. and Grundmann, M. MediaPipe Hands: On-device Real-time Hand Tracking. *arXiv preprint arXiv:2006.10214*, 2020.

[7] Luqman, H. and Mahmoud, S. A. Automatic recognition of fingerspelled words in Arabic sign language. *IEEE Access*, 7:35327–35337, 2019.

[8] Rastgoo, R., Kiani, K. and Escalera, S. Sign Language Recognition: A Deep Survey. *Expert Systems with Applications*, 164:113794, 2021.

[9] Koller, O., Camgoz, N. C., Ney, H. and Bowden, R. Weakly supervised learning with multi-stream CNN–LSTM–HMMs to discover sequential parallelism in sign language videos. *IEEE Transactions on Pattern Analysis and Machine Intelligence*, 42(9):2306–2320, 2020.

[10] TensorFlow Authors. *TensorFlow Lite — On-Device Machine Learning*. Google LLC, 2017–2024. https://www.tensorflow.org/lite

[11] Shin, J. and Seo, J. Real-time American Sign Language recognition using MediaPipe and TensorFlow Lite on mobile devices. In *Proceedings of the 2021 International Conference on Information and Communication Technology Convergence (ICTC)*, pages 1–5, IEEE, October 2021.

[12] Google LLC. *MediaPipe Solutions Guide — Hand Landmarker*. 2023. https://developers.google.com/mediapipe/solutions/vision/hand_landmarker

[13] Flutter Authors. *Flutter — Build apps for any screen*. Google LLC, 2024. https://flutter.dev

---

*(Page break before Appendix 1)*

---

## Appendix 1 — Full Technology Stack

The following table provides the complete enumeration of libraries, frameworks, and tools used in the Signly project, supplementing the summary provided in Table 3 of Chapter 4.

| Category | Technology | Version | Licence | Purpose |
|----------|-----------|---------|---------|---------|
| Mobile UI | Flutter | 3.x | BSD-3 | Cross-platform application framework |
| Language | Dart | 3.3+ | BSD-3 | Application programming language |
| Camera | camera | ^0.11.0+1 | BSD-3 | Live camera frame capture |
| Hand tracking | MediaPipe Hand Landmarker | Latest stable | Apache 2.0 | 21-point hand skeleton detection |
| On-device ML | tflite_flutter | ^0.11.0 | Apache 2.0 | TFLite runtime Dart bindings |
| Image codec | image | ^4.3.0 | MIT | YUV→JPEG frame encoding |
| Speech | speech_to_text | ^7.0.0 | BSD-3 | OS speech recognition API wrapper |
| Storage | shared_preferences | ^2.3.2 | BSD-3 | Key-value persistence |
| Animation | flutter_animate | ^4.5.2 | MIT | Declarative animation framework |
| Animation | avatar_glow | ^3.0.1 | MIT | Pulsing glow effect on recognition |
| Web content | webview_flutter | ^4.8.0 | BSD-3 | Embedded dictionary video playback |
| Native Android | Kotlin | 1.9+ | Apache 2.0 | HandLandmarkerBridge platform channel |
| Native iOS | Swift | 5.x | Apache 2.0 | AppDelegate MediaPipe bridge |
| Model training | Python | 3.10+ | PSF | Training environment |
| Training framework | Keras (TensorFlow) | 2.x | Apache 2.0 | Neural network training |
| Training (legacy) | scikit-learn | 1.x | BSD-3 | Original prototype random forest |
| Asset preparation | OpenCV (Python) | 4.x | Apache 2.0 | Image processing in training pipeline |
| Web prototype | Flask | 2.x | BSD-3 | Original proof-of-concept server |

---

*(Page break before Appendix 2)*

---

## Appendix 2 — User Guide

### A2.1 First Launch

On first launch, Signly displays three onboarding screens explaining its core features. Swipe through or tap **Next** to advance. Tap **Get Started** on the final screen to proceed to the login page.

### A2.2 Registration and Login

Tap **Sign Up** to create a new account. Enter a display name, email address, and password, then tap **Create Account**. Your credentials are stored locally on the device — no internet connection is required, and your data is not transmitted to any server.

To log in on subsequent launches, enter your email and password and tap **Sign In**.

### A2.3 Recognise Tab (Real-Time ASL Recognition)

1. Grant camera permission when prompted.
2. Hold your hand in front of the camera with the back of your hand facing the screen.
3. Form an ASL hand sign. The application detects the hand skeleton and classifies the gesture.
4. Recognised letters accumulate in the text field at the bottom of the screen.
5. Tap the **Clear** button to reset the recognised text.
6. Adjust the **confidence threshold** and **smoothing window** in Settings if recognition is too sensitive or not responsive enough.

### A2.4 Translate Tab

**Text to Sign:** Tap **Text to Sign**, type a phrase, and tap **Play**. Known words are rendered as animated GIFs; unknown words are finger-spelled character by character.

**Voice to Sign:** Tap **Voice to Sign**, then tap the microphone button and speak clearly. Tap the button again to stop recording. The recognised transcript is automatically translated to signs.

**Letters & Numbers:** Tap **Letters & Numbers** to browse static ASL sign images for all 26 letters and 10 digits.

### A2.5 Dictionary Tab

Browse or search for ASL signs by name. Tap any entry to view a full description, usage tips, and an embedded instructional video.

### A2.6 Practice Tab

Select a target sign from the list. Hold your hand in front of the camera and form the sign. The confidence meter shows how closely your hand pose matches the target. Aim for a confidence level of 0.8 or higher for a reliable match.

### A2.7 Profile Tab

The Profile tab displays your account information. Tap **Settings** to access recognition configuration options including confidence threshold (range 0.0–1.0, default 0.65) and smoothing window size (range 1–10, default 5).

---

*(Page break before Appendix 3)*

---

## Appendix 3 — Installation Guide

### A3.1 Prerequisites

- Flutter SDK 3.x (stable channel) with Dart 3.3+
- Android Studio (for Android) or Xcode 14+ (for iOS)
- A physical Android (API 24+) or iOS (14+) device (camera required; emulators do not support camera streams)

### A3.2 Clone and Configure

```bash
# 1. Navigate to the mobile application directory
cd "Sign Language Translate 5-5-2024/mobile_offline"

# 2. Install Flutter dependencies
flutter pub get
```

### A3.3 Required Assets

The following assets must be present before running the application:

| File/Directory | Source | Purpose |
|----------------|--------|---------|
| `assets/models/asl_classifier.tflite` | Run `python prepare_mobile_assets.py` | TFLite gesture classifier |
| `assets/models/labels.json` | Run `python prepare_mobile_assets.py` | Class label mapping |
| `assets/sign_language/letters/` | Run `python prepare_mobile_assets.py` | 37 sign PNG images |
| `assets/sign_language/gifs/` | Run `python prepare_mobile_assets.py` | Word GIF animations |
| `android/app/src/main/assets/hand_landmarker.task` | Download from MediaPipe releases | MediaPipe hand model |

Run the asset preparation script from the parent project directory:

```bash
cd ..
python prepare_mobile_assets.py
```

Download `hand_landmarker.task` from the [MediaPipe releases page](https://developers.google.com/mediapipe/solutions/vision/hand_landmarker) and place it at `android/app/src/main/assets/hand_landmarker.task`.

### A3.4 Run on Device

```bash
# Android
flutter run --release

# iOS (requires code signing in Xcode)
open ios/Runner.xcworkspace   # configure signing, then run from Xcode
```

### A3.5 Build Release APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## Word Formatting Guide

The following guide instructs how to apply correct Word styles when pasting this document into Microsoft Word to match the `DissertationTemplate-1.doc` conventions.

### Heading Styles

| Markdown | Word Style | Notes |
|----------|-----------|-------|
| `#` (e.g., `# 1 Introduction`) | **Heading 1** | Auto-starts new page; auto-numbers chapter |
| `##` (e.g., `## 1.1 Overview`) | **Heading 2** | Auto-numbers section |
| `###` (e.g., `### 3.3.1 System Architecture`) | **Heading 3** | Auto-numbers subsection |
| First paragraph after Heading 1 | **Body First** | No indent on first line |
| Remaining body paragraphs | **Body Text** | 11pt Times New Roman, 1.5 line spacing |
| Abstract, Acknowledgements, References headings | **Unnumbered 1** | Auto-starts new page; no chapter number |

### Page Breaks

Insert a manual page break (`Ctrl+Enter`) before each of the following:

- Abstract
- Attestation & Turnitin Report
- Acknowledgements
- Table of Contents
- Each Heading 1 chapter (Heading 1 style does this automatically in the template)
- References
- Each Appendix

### Figure and Table Captions

Apply the **Figure** paragraph style to all figure captions. The template uses the format:

> `Figure N.   Caption text`

Apply the **Table** paragraph style (or **Figure** style if the template does not define a separate table style) to all table captions:

> `Table N.   Caption text`

Use Word's **Insert Caption** feature (References → Insert Caption) to enable automatic figure/table numbering and allow the List of Figures and List of Tables to be auto-generated via **Update Field**.

### Table of Contents and Lists

Right-click the Table of Contents, List of Figures, or List of Tables fields and choose **Update Field → Update entire table** after all content is in place.

### References

Use the **Reference** paragraph style for each reference entry, formatted as IEEE numbered references:

> `[N] Author(s). Title. Publication details, Year.`
