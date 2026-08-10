import 'dart:math' as math;

import '../domain/prediction.dart';

/// Lightweight geometry checks for commonly confused ASL letters (A/B/C).
class LetterGeometryValidator {
  const LetterGeometryValidator._();

  static const double lowMarginThreshold = 0.18;
  static const double strongScore = 0.72;

  static const int _wrist = 0;
  static const int _thumbTip = 4;
  static const int _indexMcp = 5;
  static const int _indexTip = 8;
  static const int _middleTip = 12;
  static const int _ringTip = 16;
  static const int _pinkyTip = 20;

  static LetterGeometryMatch? evaluate(List<double> features42) {
    if (features42.length != 42) return null;

    final span = _span(features42);
    if (span < 0.04) return null;

    final scores = <String, double>{
      'A': _scoreA(features42, span),
      'B': _scoreB(features42, span),
      'C': _scoreC(features42, span),
    };

    var bestLetter = '';
    var bestScore = 0.0;
    scores.forEach((letter, score) {
      if (score > bestScore) {
        bestLetter = letter;
        bestScore = score;
      }
    });

    if (bestLetter.isEmpty || bestScore < strongScore) {
      return null;
    }

    final runnerUp = scores.entries
        .where((e) => e.key != bestLetter)
        .map((e) => e.value)
        .reduce(math.max);
    if (bestScore - runnerUp < 0.12) {
      return null;
    }

    return LetterGeometryMatch(
      letter: bestLetter,
      score: bestScore,
      isStrong: true,
    );
  }

  static Prediction? applyOverride({
    required Prediction raw,
    required List<double> features42,
  }) {
    if (raw.margin >= lowMarginThreshold) {
      return null;
    }

    final match = evaluate(features42);
    if (match == null || !match.isStrong) {
      return null;
    }

    if (!{'A', 'B', 'C'}.contains(match.letter)) {
      return null;
    }

    return Prediction(
      label: match.letter,
      confidence: math.max(raw.confidence, match.score),
      ts: raw.ts,
      runnerUpLabel: raw.label,
      runnerUpConfidence: raw.confidence,
    );
  }

  static double _scoreA(List<double> f, double span) {
    final thumbSideOffset = (_x(f, _thumbTip) - _x(f, _indexMcp)).abs() / span;
    final thumbIndexGap = _dist(f, _thumbTip, _indexTip) / span;
    final thumbOverFingers = _thumbOverFingersScore(f, span);
    final compactness = _fistCompactness(f, span);

    var score = 0.0;
    if (thumbSideOffset > 0.12) score += 0.35;
    if (thumbIndexGap > 0.18 && thumbIndexGap < 0.55) score += 0.25;
    if (thumbOverFingers < 0.45) score += 0.25;
    if (compactness > 0.55) score += 0.15;
    return score.clamp(0.0, 1.0);
  }

  static double _scoreB(List<double> f, double span) {
    final spread = _fingerTipSpread(f, span);
    final thumbTucked = _dist(f, _thumbTip, _wrist) / span;
    final fingersExtended = _fingersExtended(f, span);

    var score = 0.0;
    if (spread < 0.22) score += 0.4;
    if (thumbTucked < 0.42) score += 0.25;
    if (fingersExtended > 0.62) score += 0.25;
    if (_dist(f, _indexTip, _middleTip) / span < 0.1) score += 0.1;
    return score.clamp(0.0, 1.0);
  }

  static double _scoreC(List<double> f, double span) {
    final thumbIndexGap = _dist(f, _thumbTip, _indexTip) / span;
    final curvature = _cCurvature(f, span);

    var score = 0.0;
    if (thumbIndexGap > 0.14 && thumbIndexGap < 0.42) score += 0.45;
    if (curvature > 0.5) score += 0.3;
    if (thumbIndexGap < 0.08) score -= 0.35;
    return score.clamp(0.0, 1.0);
  }

  static double _thumbOverFingersScore(List<double> f, double span) {
    final thumbY = _y(f, _thumbTip);
    final indexTipY = _y(f, _indexTip);
    final middleTipY = _y(f, _middleTip);
    final avgFingerY = (indexTipY + middleTipY) / 2;
    return (thumbY - avgFingerY).abs() / span;
  }

  static double _fingerTipSpread(List<double> f, double span) {
    return (_dist(f, _indexTip, _middleTip) +
            _dist(f, _middleTip, _ringTip) +
            _dist(f, _ringTip, _pinkyTip)) /
        (3 * span);
  }

  static double _fistCompactness(List<double> f, double span) {
    final wristDist = (_dist(f, _indexTip, _wrist) +
            _dist(f, _middleTip, _wrist) +
            _dist(f, _ringTip, _wrist) +
            _dist(f, _pinkyTip, _wrist)) /
        4;
    return 1.0 - (wristDist / span).clamp(0.0, 1.0);
  }

  static double _fingersExtended(List<double> f, double span) {
    final wristY = _y(f, _wrist);
    final tips = [_indexTip, _middleTip, _ringTip, _pinkyTip];
    var extended = 0;
    for (final tip in tips) {
      if ((_y(f, tip) - wristY).abs() / span > 0.35) {
        extended++;
      }
    }
    return extended / tips.length;
  }

  static double _cCurvature(List<double> f, double span) {
    final middleOffset = _dist(f, _middleTip, _wrist);
    final arc = (_dist(f, _thumbTip, _middleTip) + _dist(f, _indexTip, _middleTip)) / 2;
    return (arc / span) * (1.0 - (middleOffset / span).clamp(0.0, 0.8));
  }

  static double _span(List<double> f) {
    var maxVal = 0.0;
    for (final value in f) {
      if (value > maxVal) maxVal = value;
    }
    return maxVal;
  }

  static double _x(List<double> f, int landmark) => f[landmark * 2];

  static double _y(List<double> f, int landmark) => f[landmark * 2 + 1];

  static double _dist(List<double> f, int a, int b) {
    final dx = _x(f, a) - _x(f, b);
    final dy = _y(f, a) - _y(f, b);
    return math.sqrt(dx * dx + dy * dy);
  }
}

class LetterGeometryMatch {
  const LetterGeometryMatch({
    required this.letter,
    required this.score,
    required this.isStrong,
  });

  final String letter;
  final double score;
  final bool isStrong;
}
