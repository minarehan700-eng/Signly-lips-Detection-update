import 'dart:math' as math;

enum HandQualityHint {
  noHand,
  handTooSmall,
  handTooLarge,
  lowDetectionScore,
  movingTooFast,
  ready,
}

class HandQualityReport {
  const HandQualityReport({
    required this.isUsable,
    required this.hint,
    this.span = 0,
    this.handScore = 0,
    this.velocity = 0,
  });

  final bool isUsable;
  final HandQualityHint hint;
  final double span;
  final double handScore;
  final double velocity;

  String get message {
    switch (hint) {
      case HandQualityHint.noHand:
        return 'Center your hand in the camera frame';
      case HandQualityHint.handTooSmall:
        return 'Move hand closer to the camera';
      case HandQualityHint.handTooLarge:
        return 'Move hand farther from the camera';
      case HandQualityHint.lowDetectionScore:
        return 'Improve lighting and keep hand fully visible';
      case HandQualityHint.movingTooFast:
        return 'Hold your hand steady for a moment';
      case HandQualityHint.ready:
        return '';
    }
  }
}

class LandmarkQuality {
  const LandmarkQuality._();

  static const double minSpan = 0.06;
  static const double maxSpan = 0.92;
  static const double minHandScore = 0.45;
  static const double defaultMaxVelocity = 0.028;

  static HandQualityReport assess({
    required List<double>? features42,
    double handScore = 1.0,
    double span = 0,
    List<double>? previousFeatures42,
    bool holdSteadyEnabled = true,
    double maxVelocity = defaultMaxVelocity,
    double minHandScoreThreshold = minHandScore,
  }) {
    if (features42 == null || features42.length != 42) {
      return const HandQualityReport(
        isUsable: false,
        hint: HandQualityHint.noHand,
      );
    }

    final effectiveSpan = span > 0 ? span : _handSpan(features42);

    if (effectiveSpan < minSpan) {
      return HandQualityReport(
        isUsable: false,
        hint: HandQualityHint.handTooSmall,
        span: effectiveSpan,
        handScore: handScore,
      );
    }
    if (effectiveSpan > maxSpan) {
      return HandQualityReport(
        isUsable: false,
        hint: HandQualityHint.handTooLarge,
        span: effectiveSpan,
        handScore: handScore,
      );
    }
    if (handScore < minHandScoreThreshold) {
      return HandQualityReport(
        isUsable: false,
        hint: HandQualityHint.lowDetectionScore,
        span: effectiveSpan,
        handScore: handScore,
      );
    }

    if (holdSteadyEnabled && previousFeatures42 != null) {
      final velocity = _velocity(features42, previousFeatures42);
      if (velocity > maxVelocity) {
        return HandQualityReport(
          isUsable: false,
          hint: HandQualityHint.movingTooFast,
          span: effectiveSpan,
          handScore: handScore,
          velocity: velocity,
        );
      }
    }

    return HandQualityReport(
      isUsable: true,
      hint: HandQualityHint.ready,
      span: effectiveSpan,
      handScore: handScore,
    );
  }

  static bool isUsable({
    required List<double> features42,
    double handScore = 1.0,
    double span = 0,
    List<double>? previousFeatures42,
    bool holdSteadyEnabled = true,
    double maxVelocity = defaultMaxVelocity,
    double minHandScoreThreshold = minHandScore,
  }) {
    return assess(
      features42: features42,
      handScore: handScore,
      span: span,
      previousFeatures42: previousFeatures42,
      holdSteadyEnabled: holdSteadyEnabled,
      maxVelocity: maxVelocity,
      minHandScoreThreshold: minHandScoreThreshold,
    ).isUsable;
  }

  static double _handSpan(List<double> features) {
    var maxVal = 0.0;
    for (final value in features) {
      if (value > maxVal) maxVal = value;
    }
    return maxVal;
  }

  static double _velocity(List<double> current, List<double> previous) {
    if (current.length != previous.length) return 0;
    var sum = 0.0;
    for (var i = 0; i < current.length; i++) {
      final delta = current[i] - previous[i];
      sum += delta * delta;
    }
    return math.sqrt(sum / current.length);
  }
}
