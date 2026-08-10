# Signly — ملخص تقني سريع (للعرض والمناقشة)

**المستودع:** [github.com/kamelfcis/Signly-Language-Translate](https://github.com/kamelfcis/Signly-Language-Translate)

> **جملة العرض (Graduation):**  
> *Signly تطبيق Flutter يترجم لغة الإشارة الأمريكية (ASL) أوفلاين عبر الكاميرا — يستخرج 42 ميزة من MediaPipe، يصنّفها بنموذج TFLite محليًا (37 حرف/رقم)، ويعرض الترجمة العكسية (نص/صوت → إشارة) بدون اتصال بالإنترنت.*

---

## نظرة عامة على المعمارية

```
الكاميرا → MediaPipe (Native) → 42 features → TFLite → Post-processing → واجهة المستخدم
                ↑                              ↑
         hand_landmarker.task          asl_classifier.tflite + labels.json
```

| الطبقة | المجلد | الدور |
|--------|--------|-------|
| **Domain** | `lib/domain/` | نماذج البيانات والعقود (`contracts.dart`, `landmarks.dart`, `prediction.dart`) |
| **Infrastructure** | `lib/infrastructure/` | MediaPipe، TFLite، ترميز إطارات الكاميرا |
| **Application** | `lib/application/` | منطق التعرف، ما بعد المعالجة، جمع العينات |
| **Core** | `lib/core/` | التخزين، الثيم، التنقل، تتبع الدقة |
| **Screens** | `lib/screens/` | الشاشات (auth / home / translate) |
| **Widgets** | `lib/widgets/` | مكوّنات UI مشتركة |

---

## 1. التخزين (Database / Storage)

**لا يُستخدم SQLite** — كل البيانات المحلية عبر **SharedPreferences** وملفات **JSON** و**Assets**.

| النوع | الملف / المسار | المحتوى |
|-------|----------------|---------|
| **SharedPreferences** | `lib/core/app_storage.dart` | onboarding، تسجيل الدخول، اسم المستخدم |
| **SharedPreferences** | `lib/application/prediction_post_processor.dart` | عتبات الثقة، نافذة التصويت، إعدادات التشويش |
| **SharedPreferences** | `lib/application/offline_recognition_controller.dart` | hold-steady، softmax temperature |
| **SharedPreferences** | `lib/core/accuracy_tracker.dart` | إحصائيات دقة التدريب (JSON داخل prefs) |
| **SharedPreferences** | `lib/screens/home/settings_screen.dart` | حفظ إعدادات المستخدم |
| **JSON (ملفات)** | `training_samples_pending.json` | عينات معلّقة — `lib/application/training_sample_store.dart` |
| **JSON (ملفات)** | `training_samples.json` | تصدير العينات للتدريب في `ml/` |
| **Assets** | `assets/models/asl_classifier.tflite` | نموذج TensorFlow Lite |
| **Assets** | `assets/models/labels.json` | 37 فئة (A–Z, 0–9, space) |
| **Assets** | `assets/sign_language/` | صور/GIF للحروف والترجمة العكسية |
| **Native** | `android/.../hand_landmarker.task` | نموذج MediaPipe (ليس في pubspec) |

---

## 2. خط أنابيب الذكاء الاصطناعي (AI Pipeline)

### التدفق

1. **إطار الكاميرا** → `lib/infrastructure/camera_frame_encoder.dart`
2. **MediaPipe** (MethodChannel `asl/offline/landmarks`) → `lib/infrastructure/mediapipe_hand_landmark_extractor.dart`
   - الدوال Native: `initializeHandLandmarker`, `processFrame`
   - المخرج: **`features42`** (21 landmark × x,y بعد تطبيع)
3. **فحص الجودة** → `lib/application/landmark_quality.dart` + `letter_geometry_validator.dart`
4. **TFLite** → `lib/infrastructure/tflite_gesture_classifier.dart`
   - `load()` → `Interpreter.fromAsset("assets/models/asl_classifier.tflite")`
   - `classify(features)` → 37 احتمال + temperature scaling
5. **Post-processing** → `lib/application/prediction_post_processor.dart`
   - `stable()` — نافذة تصويت، debounce، عقوبات أزواج التشويش (`confusion_pairs.dart`)
6. **Orchestrator** → `lib/application/offline_recognition_controller.dart`
   - `initialize()` / `onFrame()` — يربط كل المراحل

### ملفات رئيسية

| الملف | الدالة/الكلاس المهم |
|-------|---------------------|
| `mediapipe_hand_landmark_extractor.dart` | `MediaPipeHandLandmarkExtractor.processFrame()` |
| `tflite_gesture_classifier.dart` | `TfliteGestureClassifier.classify()` |
| `prediction_post_processor.dart` | `PredictionPostProcessor.stable()` |
| `offline_recognition_controller.dart` | `OfflineRecognitionController.onFrame()` |
| `recognition_screen.dart` | شاشة التعرف المباشر من الكاميرا |
| `collect_data_screen.dart` | جمع عينات → JSON للتدريب |
| `ml/` | إعادة تدريب النموذج (Python) — انظر `ml/README.md` |

**37 فئة:** A–Z + 0–9 + مسافة — مدخلات النموذج: **42**، مخرجات: **37**.

---

## 3. هيكل Flutter

### نقطة الدخول والتنقل

| الملف | الوظيفة |
|-------|---------|
| `lib/main.dart` | `OfflineAslApp` → `SplashScreen` |
| `lib/screens/splash_screen.dart` | توجيه: onboarding / login / home |
| `lib/core/app_navigation.dart` | انتقالات fade/slide |

### الشاشات الرئيسية

| المسار | الشاشة |
|--------|--------|
| `lib/screens/onboarding_screen.dart` | التعريف الأول |
| `lib/screens/auth/login_screen.dart` | تسجيل الدخول |
| `lib/screens/auth/signup_screen.dart` | إنشاء حساب |
| `lib/screens/home/home_screen.dart` | **4 تبويبات:** Recognize · Translate · Dictionary · Profile |
| `lib/screens/home/recognition_screen.dart` | تعرف ASL بالكاميرا (أوفلاين) |
| `lib/screens/home/dictionary_screen.dart` | قاموس الإشارات |
| `lib/screens/home/practice_screen.dart` | التدريب |
| `lib/screens/home/settings_screen.dart` | إعدادات التعرف |
| `lib/screens/home/collect_data_screen.dart` | جمع بيانات التدريب |
| `lib/screens/translate/translate_hub_screen.dart` | مركز الترجمة |
| `lib/screens/translate/text_to_sign_screen.dart` | نص → إشارة |
| `lib/screens/translate/voice_to_sign_screen.dart` | صوت → إشارة |
| `lib/screens/translate/letters_and_numbers_screen.dart` | شبكة الحروف والأرقام |

### الحزم الأساسية (`pubspec.yaml`)

| الحزمة | الاستخدام |
|--------|-----------|
| `camera` | بث الكاميرا |
| `tflite_flutter` | تشغيل `asl_classifier.tflite` |
| `shared_preferences` | إعدادات وحالة المستخدم |
| `speech_to_text` | Voice → Sign |
| `path_provider` | مسار ملفات JSON للتدريب |
| `flutter_animate` | حركات UI |
| `webview_flutter` | عرض محتوى داخل التطبيق |

---

## 4. أسئلة المناقشة — إجابات سريعة

| السؤال | الإجابة المختصرة |
|--------|------------------|
| لماذا 42 ميزة؟ | 21 نقطة يد × (x, y) بعد تطبيع نسبي لليد |
| أين يعمل MediaPipe؟ | Native Android/iOS عبر MethodChannel — ليس في Dart |
| هل يحتاج إنترنت؟ | لا — التعرف والنموذج محليان بالكامل |
| كيف تُحدَّث الدقة؟ | جمع عينات → `ml/` → إعادة تصدير `.tflite` → `assets/models/` |

---

*آخر تحديث: يونيو 2026 — مشروع تخرج Signly*
