import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/contracts.dart';
import '../domain/landmarks.dart';
import '../domain/prediction.dart';
import 'landmark_quality.dart';
import 'letter_geometry_validator.dart';
import 'prediction_post_processor.dart';

class OfflineRecognitionController {
  OfflineRecognitionController({
    required HandLandmarkExtractor landmarkExtractor,
    required GestureClassifier classifier,
    required PredictionPostProcessor postProcessor,
  })  : _landmarkExtractor = landmarkExtractor,
        _classifier = classifier,
        _postProcessor = postProcessor;

  final HandLandmarkExtractor _landmarkExtractor;
  final GestureClassifier _classifier;
  final PredictionPostProcessor _postProcessor;

  PredictionPostProcessor get postProcessor => _postProcessor;

  NormalizedLandmarks? _lastLandmarks;
  NormalizedLandmarks? get lastLandmarks => _lastLandmarks;
  Prediction? _lastRawPrediction;
  Prediction? get lastRawPrediction => _lastRawPrediction;

  HandQualityReport _qualityReport = const HandQualityReport(
    isUsable: false,
    hint: HandQualityHint.noHand,
  );
  HandQualityReport get qualityReport => _qualityReport;

  List<double>? _previousFeatures42;
  bool _holdSteadyEnabled = true;
  double _maxVelocity = LandmarkQuality.defaultMaxVelocity;
  double _softmaxTemperature = 0.85;

  Future<void> initialize() async {
    await initializeLandmarks();
    await initializeClassifier();
    await _postProcessor.loadSettings();
    await _loadQualitySettings();
  }

  Future<void> initializeLandmarks() async {
    await _landmarkExtractor.initialize();
  }

  Future<void> initializeClassifier() async {
    await _classifier.load();
    await _loadQualitySettings();
    if (_classifier is TemperatureAwareClassifier) {
      (_classifier as TemperatureAwareClassifier).temperature = _softmaxTemperature;
    }
  }

  Future<void> reloadSettings() async {
    await _postProcessor.loadSettings();
    await _loadQualitySettings();
  }

  Future<void> _loadQualitySettings() async {
    final prefs = await SharedPreferences.getInstance();
    _holdSteadyEnabled = prefs.getBool('hold_steady_enabled') ?? true;
    _maxVelocity =
        prefs.getDouble('max_landmark_velocity') ?? LandmarkQuality.defaultMaxVelocity;
    _softmaxTemperature = prefs.getDouble('softmax_temperature') ?? 0.85;
    if (_classifier is TemperatureAwareClassifier) {
      (_classifier as TemperatureAwareClassifier).temperature = _softmaxTemperature;
    }
  }

  Future<Prediction?> onFrame({
    required Uint8List bytes,
    required int width,
    required int height,
    required int rotation,
    String? targetHint,
  }) async {
    final landmarks = await _landmarkExtractor.processFrame(
      bytes: bytes,
      width: width,
      height: height,
      rotation: rotation,
    );

    if (landmarks == null) {
      _lastLandmarks = null;
      _lastRawPrediction = null;
      _previousFeatures42 = null;
      _qualityReport = const HandQualityReport(
        isUsable: false,
        hint: HandQualityHint.noHand,
      );
      _postProcessor.reset();
      return null;
    }

    _lastLandmarks = landmarks;
    _qualityReport = LandmarkQuality.assess(
      features42: landmarks.features42,
      handScore: landmarks.handScore,
      span: landmarks.span,
      previousFeatures42: _previousFeatures42,
      holdSteadyEnabled: _holdSteadyEnabled,
      maxVelocity: _maxVelocity,
    );

    if (!_qualityReport.isUsable) {
      _lastRawPrediction = null;
      // Age the vote window during skipped frames so stale votes from the
      // previous sign do not block stable() after the first emission.
      _postProcessor.ageWindow();
      _previousFeatures42 = List<double>.from(landmarks.features42);
      return null;
    }

    _previousFeatures42 = List<double>.from(landmarks.features42);
    var prediction = _classifier.classify(landmarks.features42);
    _lastRawPrediction = prediction;

    final geometryOverride = LetterGeometryValidator.applyOverride(
      raw: prediction,
      features42: landmarks.features42,
    );
    if (geometryOverride != null) {
      prediction = geometryOverride;
    }

    return _postProcessor.stable(prediction, targetHint: targetHint);
  }
}
