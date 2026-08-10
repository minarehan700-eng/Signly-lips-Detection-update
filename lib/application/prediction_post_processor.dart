import 'dart:collection';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/prediction.dart';
import 'confusion_pairs.dart';

class PredictionPostProcessor {
  PredictionPostProcessor({
    this.confidenceThreshold = 0.58,
    this.windowSize = 4,
    this.minMargin = 0.14,
    this.debounceMs = 350,
    this.adaptiveThresholdEnabled = true,
    this.confusionPenaltyEnabled = true,
  });

  static const double defaultConfidenceThreshold = 0.58;
  static const int defaultWindowSize = 4;
  static const double defaultMinMargin = 0.14;

  double confidenceThreshold;
  int windowSize;
  double minMargin;
  int debounceMs;
  bool adaptiveThresholdEnabled;
  bool confusionPenaltyEnabled;

  final Queue<Prediction> _window = Queue<Prediction>();

  /// Last label committed to the output stream (not the live preview).
  String _lastCommitted = '';

  int get _requiredVotes => (windowSize / 2).floor() + 1;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    confidenceThreshold =
        prefs.getDouble('confidence_threshold') ?? defaultConfidenceThreshold;
    windowSize = prefs.getInt('window_size') ?? defaultWindowSize;
    minMargin = prefs.getDouble('min_margin') ?? defaultMinMargin;
    adaptiveThresholdEnabled =
        prefs.getBool('adaptive_threshold_enabled') ?? true;
    confusionPenaltyEnabled =
        prefs.getBool('confusion_penalty_enabled') ?? true;
  }

  void updateSettings({
    double? confidenceThreshold,
    int? windowSize,
    double? minMargin,
    bool? adaptiveThresholdEnabled,
    bool? confusionPenaltyEnabled,
  }) {
    if (confidenceThreshold != null) {
      this.confidenceThreshold = confidenceThreshold;
    }
    if (windowSize != null) {
      this.windowSize = windowSize;
    }
    if (minMargin != null) {
      this.minMargin = minMargin;
    }
    if (adaptiveThresholdEnabled != null) {
      this.adaptiveThresholdEnabled = adaptiveThresholdEnabled;
    }
    if (confusionPenaltyEnabled != null) {
      this.confusionPenaltyEnabled = confusionPenaltyEnabled;
    }
  }

  void reset() {
    _window.clear();
    _lastCommitted = '';
  }

  /// Clears the commit lock so the same sign can be emitted again after a
  /// release gesture (hand lowered, fast transition, etc.).
  void releaseHold() {
    _lastCommitted = '';
  }

  /// Ages the sliding window when a frame is skipped upstream (e.g. quality
  /// gate) so stale votes do not block the next sign forever.
  void ageWindow() {
    if (_window.isNotEmpty) {
      _window.removeFirst();
    }
  }

  Prediction? stable(Prediction input, {String? targetHint}) {
    if (!_passesFrameGates(input)) {
      ageWindow();
      return null;
    }

    _window.addLast(input);
    while (_window.length > windowSize) {
      _window.removeFirst();
    }

    if (_window.length < windowSize) {
      return null;
    }

    final winner = _weightedWinner(targetHint: targetHint);
    if (winner == null) {
      return null;
    }

    final (label, avgConfidence) = winner;
    if (!_passesStabilityGates(label)) {
      return null;
    }

    // Emit when the stable winner changes OR the previous sign was released
    // (window no longer dominated by the last committed label).
    if (label == _lastCommitted && !_isSignReleased(_lastCommitted)) {
      return null;
    }

    _lastCommitted = label;
    return Prediction(
      label: label,
      confidence: avgConfidence,
      ts: input.ts,
    );
  }

  bool _isSignReleased(String committed) {
    if (committed.isEmpty || _window.length < windowSize) {
      return committed.isEmpty;
    }
    final committedCount =
        _window.where((p) => p.label == committed).length;
    return committedCount < _requiredVotes;
  }

  double _effectiveThreshold() {
    if (!adaptiveThresholdEnabled || _window.isEmpty) {
      return confidenceThreshold;
    }

    var boost = 0.0;
    final labels = _window.map((p) => p.label).toSet();
    if (labels.length > 1) {
      boost += 0.05;
    }

    final margins = _window.map((p) => p.margin).toList();
    final avgMargin = margins.reduce((a, b) => a + b) / margins.length;
    if (avgMargin < 0.18) {
      boost += (0.18 - avgMargin) * 0.45;
    }

    final confidences = _window.map((p) => p.confidence).toList();
    final avgConfidence =
        confidences.reduce((a, b) => a + b) / confidences.length;
    if (avgConfidence < confidenceThreshold + 0.05) {
      boost += 0.03;
    }

    return (confidenceThreshold + boost).clamp(confidenceThreshold, 0.95);
  }

  bool _passesFrameGates(Prediction input) {
    if (input.confidence < _effectiveThreshold()) {
      return false;
    }
    if (input.margin < minMargin) {
      return false;
    }
    return true;
  }

  (String, double)? _weightedWinner({String? targetHint}) {
    final weightedScores = <String, double>{};
    final counts = <String, int>{};
    final confidenceSums = <String, double>{};

    for (final prediction in _window) {
      final weight = ConfusionPairs.weightFor(
        label: prediction.label,
        runnerUpLabel: prediction.runnerUpLabel,
        margin: prediction.margin,
        baseConfidence: prediction.confidence,
        enabled: confusionPenaltyEnabled,
        practiceTarget: targetHint,
      );

      weightedScores[prediction.label] =
          (weightedScores[prediction.label] ?? 0) + weight;
      counts[prediction.label] = (counts[prediction.label] ?? 0) + 1;
      confidenceSums[prediction.label] =
          (confidenceSums[prediction.label] ?? 0) + prediction.confidence;
    }

    String bestLabel = '';
    double bestWeightedScore = -1;
    counts.forEach((label, _) {
      final score = weightedScores[label] ?? 0;
      if (score > bestWeightedScore) {
        bestLabel = label;
        bestWeightedScore = score;
      }
    });

    if (bestLabel.isEmpty) {
      return null;
    }

    final winnerCount = counts[bestLabel] ?? 0;
    if (winnerCount < _requiredVotes) {
      return null;
    }

    final avgConfidence = (confidenceSums[bestLabel] ?? 0) / winnerCount;
    if (avgConfidence < _effectiveThreshold()) {
      return null;
    }

    if (confusionPenaltyEnabled) {
      final winnerFrames = _window.where((p) => p.label == bestLabel);
      final confusedFrames = winnerFrames.where(
        (p) =>
            p.runnerUpLabel != null &&
            ConfusionPairs.areConfused(p.label, p.runnerUpLabel!) &&
            p.margin < ConfusionPairs.highMarginBypass,
      );
      if (confusedFrames.length > winnerCount ~/ 2) {
        return null;
      }
    }

    return (bestLabel, avgConfidence);
  }

  bool _passesStabilityGates(String label) {
    final labelFrames = _window.where((p) => p.label == label).toList();
    if (labelFrames.length < _requiredVotes) {
      return false;
    }

    final margins = labelFrames.map((p) => p.margin).toList();
    final avgMargin = margins.reduce((a, b) => a + b) / margins.length;
    return avgMargin >= minMargin;
  }
}
