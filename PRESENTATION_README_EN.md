# Graduation Project Presentation Guide — Signly
## Real-Time American Sign Language (ASL) Recognition — Fully Offline

> **Presentation file:** `Signly (1).pptx`  
> **Number of slides:** 32  
> **Purpose of this file:** Brief notes for each slide and what to say during the presentation.

---

## Slide 1 — Cover (Signly)

**Title:** Signly — Graduation Project 2026

**What to say:**
Greet the committee and introduce yourself briefly. Explain that your project is called **Signly** — a mobile app that recognizes **American Sign Language (ASL)** in real time **without an internet connection**. Mention that it is built with **Flutter** for **iOS and Android**, uses **MediaPipe** for hand detection, and **TensorFlow Lite** for on-device AI classification.

---

## Slide 2 — Outline

**Title:** Presentation Agenda

**What to say:**
Walk through the structure of your presentation so the audience knows what to expect. You will cover eight sections: **Introduction**, **Project Objectives**, **Literature Review**, **Proposed Solution**, **Live Demo**, **Results & Discussion**, **Conclusion & Future Work**, and finally **Q&A**. Keep this brief — it is a transitional slide only.

---

## Slide 3 — Section 01: Introduction

**Title:** Introduction — Section 01

**What to say:**
Say that you are starting with the introduction to define the field of **automatic sign language recognition (SLR)**. This section explains why the topic matters, the application domain, and the challenges that remain unsolved. Take a short pause before diving into details — this is a section divider.

---

## Slide 4 — Background

**Title:** Sign language is a primary language — software rarely speaks it

**What to say:**
Explain that sign language is a complete, natural language, and **ASL** is a primary language for the Deaf and hard-of-hearing community. Most consumer software does not natively support sign input. Cite the numbers: over **70 million** people use sign languages as their first language, there are more than **300** sign languages worldwide, and your project focuses on **37 signs** (A–Z, 0–9, and space). Connect the topic to four pillars: **accessibility** (camera as an input alternative), **education** (self-paced practice with instant feedback), **privacy** (on-device processing), and **offline operation**.

---

## Slide 5 — Open Challenges

**Title:** What still makes mobile SLR hard

**What to say:**
Say that sign recognition on mobile devices remains difficult for practical reasons. Cover four challenges: **latency** (under 100 ms per frame without a server), **appearance variation** (lighting, background, camera angle), **similar hand shapes** (e.g., A, S, and T), and **privacy & offline use** (no uploading video to the cloud). Explain that Signly was designed specifically to address these challenges.

---

## Slide 6 — Section 02: Project Objectives

**Title:** Project Objectives — Section 02

**What to say:**
Move to the second section and say you will present **Signly's goals** and **who benefits** from the app. This is a section divider — no lengthy explanation needed, just announce the start of the objectives section.

---

## Slide 7 — Goals & Beneficiaries

**Title:** Objectives

**What to say:**
Present the five project goals: **real-time recognition** of fingerspelling (A–Z, 0–9, space), **fully offline** operation on the device, **high accuracy** with a lightweight model, **learning support** via dictionary and practice mode, and **personalization** through per-sign accuracy tracking. Then explain the beneficiaries: **Deaf and hard-of-hearing users** (an accessible, private input channel), **ASL learners** (practice anywhere with a confidence score), and **teachers and interpreters** (confidence as a supplement to human feedback).

---

## Slide 8 — Section 03: Literature Review

**Title:** Literature Review & Related Work — Section 03

**What to say:**
Say you will review how sign language recognition has evolved — from sensor gloves to deep learning based on hand landmarks. This section shows where prior systems fall short and why there was a gap that your project fills.

---

## Slide 9 — Evolution of SLR

**Title:** Three generations of approaches

**What to say:**
Describe three generations: **Gen 1** (sensor gloves and depth cameras — accurate but not portable), **Gen 2** (CNNs on raw images — good accuracy but heavy and background-sensitive), **Gen 3** (hand landmark extraction plus a lightweight classifier — **your project's approach**). Say that Signly combines **MediaPipe + MLP/TFLite** to balance accuracy, speed, and size on mobile.

---

## Slide 10 — Comparison with Related Work

**Title:** Related work vs. Signly

**What to say:**
Walk through the comparison table and explain that prior systems either require special hardware, depend on the cloud, or lack learning tools. Signly combines: **on-device execution**, **offline operation**, **learning tools** (dictionary + practice), and accuracy around **98.6%**. Emphasize that the gap your project addresses is the absence of a prior system that combines all these features in one integrated learning experience. *(Note: figures on this slide are indicative — confirm them from your actual results if asked.)*

---

## Slide 11 — Section 04: Proposed Solution

**Title:** Proposed Solution — Section 04

**What to say:**
Say you are now entering the core of the project: **system architecture**, the **four-stage pipeline**, **model training**, and **evaluation**. This is a section divider before the detailed technical explanation.

---

## Slide 12 — System Architecture

**Title:** System architecture — four stages

**What to say:**
Explain the path from camera to UI in four steps: **01 Capture** (Flutter grabs RGB frames from the camera), **02 Detection** (MediaPipe extracts 21 landmarks per hand), **03 Classification** (TFLite MLP outputs the class and confidence across 37 signs), **04 Display & Storage** (stabilized results appear in the UI and are saved locally). Mention the stack: **Flutter/Dart** for the UI, **MediaPipe** for computer vision, **TFLite** for machine learning, and **SharedPreferences** for local storage.

---

## Slide 13 — Phase 1: Hand Landmark Detection

**Title:** Phase 1 — Hand Landmark Detection

**What to say:**
Say that each frame passes through **MediaPipe Hands**, which returns **21 landmarks** with (x, y, z) coordinates — the wrist plus four points per finger. Explain the benefit: recognition is separated from raw image appearance, inputs shrink from thousands of pixels to **63 values** (21×3), and a small classifier can run fast on-device. This is the foundation of the solution's speed and lightness.

---

## Slide 14 — Phase 2: Feature Engineering

**Title:** Phase 2 — Feature Engineering

**What to say:**
Explain that raw coordinates depend on hand position and size in the frame, so three steps are applied: **translation** (re-center on the wrist: x' = x − x₀), **normalization** (divide by the largest absolute value to remove scale and distance effects), and **assembly** (build a **63-dimensional** vector for the classifier). Say this makes the model **invariant to position and scale**, reduces computation, and produces more stable outputs.

---

## Slide 15 — Phase 3: Model Training

**Title:** Phase 3 — Model Training

**What to say:**
Present the training methodology: roughly **27,000 samples** across **37 classes**, split **70% train / 15% validation / 15% test**, a **compact MLP** (Dense 128 → Dropout → Dense 64 → Softmax 37), training with **Adam** for **50 epochs** and **early stopping**, then export to a quantized **TFLite** model of ~**0.4 MB**. Say the goal was a small, fast model that runs on a mobile CPU. *(Figures are indicative — replace with your actual run results if needed.)*

---

## Slide 16 — Model Selection

**Title:** We compared four classifiers

**What to say:**
Explain that you compared four classifiers: **k-NN** (88.2% — slow and stores all data), **Random Forest** (91.5% — good but larger), **SVM** (93.8% — strong but harder to deploy), and **MLP** (98.6% — best accuracy, size, and speed at ~6 ms). Say **MLP on normalized landmarks** was chosen because it exports easily to TFLite and offers the best balance for mobile deployment.

---

## Slide 17 — Training & Validation Curves

**Title:** Training & validation curves

**What to say:**
Show the charts and say **accuracy** converges around **epoch 35** with no large gap between train and validation (a good sign against overfitting). Explain that **loss** decreased steadily and training stopped early at the best **validation loss**. Say this confirms stable training and that the model is ready for deployment.

---

## Slide 18 — Confusion Matrix

**Title:** Confusion matrix

**What to say:**
Explain that the matrix on the test set is **strongly diagonal** — predictions are mostly correct. Say errors cluster where shapes are genuinely similar: **A ↔ S ↔ T** (closed fist differing only in thumb position) and **M ↔ N** (thumb under three vs. two fingers). Mention that remaining classes exceed **98% recall**, and the slide shows **8 representative classes** from the full 37×37 matrix for clarity.

---

## Slide 19 — Metrics & Requirement Validation

**Title:** Metrics & requirement validation

**What to say:**
Present the metrics: **Accuracy 98.6%**, **Precision 98.4%**, **Recall 98.1%**, **F1 = 0.982**. Then walk through requirement validation: **real-time** (~90 ms per frame ✓), **offline** (zero network — verified in airplane mode ✓), **37-sign coverage** ✓, **model size ~0.4 MB** ✓, **privacy** (frames never leave the device ✓). Say all functional requirements were met.

---

## Slide 20 — Phase 4: Real-Time Inference

**Title:** Phase 4 — Real-Time Inference

**What to say:**
Explain that the live camera produces a prediction every frame, and raw output **flickers** between similar classes. Signly applies four steps: **per-frame prediction**, **confidence gating** (ignore weak predictions), **temporal stabilization** (a class must hold across consecutive frames), and **text append** (the stable sign is added to the output). Mention the color-coded confidence bar (red → orange → green), auto-advance in practice mode, and local per-sign accuracy tracking.

---

## Slide 21 — Section 05: Demo

**Title:** Demo — Section 05

**What to say:**
Say you will now move to a walkthrough of the working application. Mention the features you will show: **onboarding**, **dictionary**, **camera recognition**, **text/voice-to-sign**, and **guided practice mode**. This is a transitional slide — have your device or video ready before continuing.

---

## Slide 22 — Demo: First Run (Onboarding)

**Title:** Demo · First Run

**What to say:**
Show the onboarding screen and explain it sets three promises for the user: **instant recognition** from the camera with on-device AI, **fully offline** operation after models are loaded, and a **polished translation experience** with confidence scores and stabilized text without flicker. If possible, launch the app in front of the committee or play a short video.

---

## Slide 23 — Demo: Dictionary

**Title:** Demo · Reference — Dictionary & formation tips

**What to say:**
Walk through the **Dictionary** tab: each sign is a tappable card, grouped into **common phrases** and **letters & numbers**. Opening a sign shows **how to perform it** and three precise formation tips. Say the **"Practice this sign"** button takes the user directly to practice mode. Mention the bottom navigation: **Recognize · Dictionary · Practice · Settings · Profile**.

---

## Slide 24 — Demo: Recognition & Practice

**Title:** Demo · Recognition & Practice

**What to say:**
Demonstrate practice mode: the user picks a sign and the camera shows a **live confidence bar** (red → orange → **green**). Explain that counters track **completed signs** and **first-attempt accuracy**. Say the user can **skip** a stuck sign and return to it later from the dictionary. This highlights the instant feedback that sets the app apart.

---

## Slide 25 — Demo: Text & Voice to Sign

**Title:** Demo · Text & Voice to Sign

**What to say:**
Say Signly works **both ways**: not only sign → text, but also text/voice → sign. Cover three features: **Text to Sign** (type words and see the signs), **Voice to Sign** (speak and see signs instantly), and **Letters & Numbers** (browse the full alphabet and digits). Mention that known words show GIFs and unknown words are spelled out letter by letter.

---

## Slide 26 — Demo: Account & Privacy

**Title:** Demo · Account & Privacy

**What to say:**
Explain that **sign-in is optional** and never blocks recognition — the app works before and after account creation. Say frames are processed **locally and never uploaded**. Mention sign-in options (Google · Apple · Facebook) for syncing settings, while **accuracy history and preferences** are stored locally via SharedPreferences. Emphasize privacy as a core design value.

---

## Slide 27 — Section 06: Results & Discussion

**Title:** Results & Discussion — Section 06

**What to say:**
Move to the sixth section and say you will present **what was delivered**, **how Signly compares to prior systems**, and the **limitations and challenges** you encountered. This is a section divider before summarizing results.

---

## Slide 28 — Outcomes & Contributions

**Title:** Outcomes & Contributions

**What to say:**
Present the key numbers: **98.6%** test accuracy, **~90 ms** response time, **100%** offline, **two platforms** (iOS/Android) from one Flutter codebase. Then list contributions: a **landmark-based mobile pipeline** with no server, **bidirectional translation** (recognition + text/voice-to-sign), an **integrated learning experience** (dictionary + practice), and **personalization** via accuracy history. Compare briefly: accuracy near glove-based systems **without special hardware**, lighter and faster than image CNNs, with learning tools absent from cloud solutions.

---

## Slide 29 — Discussion: Limitations & Constraints

**Title:** Limitations & constraints

**What to say:**
Be honest about limitations: the project covers **static signs** (fingerspelling), not dynamic signs or two-handed gestures. Mention **remaining confusion** between A/S/T and M/N. Say **compute budget** limited dataset size, and **single-hand detection** is affected by lighting or partial occlusion. Showing awareness of limitations strengthens your credibility with the committee.

---

## Slide 30 — Section 07: Conclusion & Future Work

**Title:** Conclusion & Future Work — Section 07

**What to say:**
Say you are closing the presentation with a summary of what was built and proven, followed by a roadmap for the future. This is a section divider before the final conclusion.

---

## Slide 31 — Recap & Roadmap

**Title:** Conclusion & future work

**What to say:**
In the **conclusion**: say Signly proves that accurate, real-time ASL fingerspelling recognition can run **fully offline on mobile** by combining MediaPipe and TFLite, and that recognition is complemented by a dictionary and guided practice. Confirm goals met: real-time, offline, 37 signs, learning tools. For **future work**: mention **dynamic signs** (LSTM/Transformer), **word- and sentence-level** recognition, **two-handed signs** with broader data, **avatar expansion** for full words and phrases, and **accessibility improvements** (haptics, larger targets, multilingual UI).

---

## Slide 32 — Thank You

**Title:** THANK YOU — Questions & Discussion

**What to say:**
Close with: **"Signly — empowering sign-language communication and learning through on-device AI."** Thank the committee, your supervisor, and anyone who helped. Say you are ready for questions and discussion (**Q & A**). Smile and wait for the committee — prepare answers on: why ASL and not Arabic sign language, dataset size, response time, and how Signly differs from existing apps.

---

## General Presentation Tips

1. **Timing:** Allow ~1–2 minutes per technical slide and ~3–4 minutes for the Demo section.
2. **Device:** Ensure `hand_landmarker.task` and `asl_classifier.tflite` are loaded before the live demo.
3. **Figures:** Slides 10 and 15–19 carry **INDICATIVE** data — replace with your actual run numbers if questioned.
4. **Language:** Deliver in clear, professional English; adjust formality to match your committee's expectations.

---

*This file was generated from the content of `Signly (1).pptx` — 32 slides.*
