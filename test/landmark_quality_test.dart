import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_offline/application/landmark_quality.dart';

List<double> _features({double span = 0.2}) {
  final values = List<double>.filled(42, 0);
  values[0] = span;
  values[1] = span * 0.5;
  return values;
}

void main() {
  group('LandmarkQuality', () {
    test('flags hand that is too small', () {
      final report = LandmarkQuality.assess(
        features42: _features(span: 0.04),
        handScore: 0.9,
        span: 0.04,
      );
      expect(report.isUsable, isFalse);
      expect(report.hint, HandQualityHint.handTooSmall);
    });

    test('flags fast motion when hold steady is enabled', () {
      final previous = _features(span: 0.2);
      final current = List<double>.from(previous);
      for (var i = 0; i < current.length; i++) {
        current[i] += 0.05;
      }

      final report = LandmarkQuality.assess(
        features42: current,
        handScore: 0.9,
        span: 0.25,
        previousFeatures42: previous,
        holdSteadyEnabled: true,
        maxVelocity: 0.028,
      );

      expect(report.isUsable, isFalse);
      expect(report.hint, HandQualityHint.movingTooFast);
    });

    test('accepts steady usable hand', () {
      final features = _features(span: 0.2);
      final report = LandmarkQuality.assess(
        features42: features,
        handScore: 0.8,
        span: 0.2,
        previousFeatures42: features,
      );
      expect(report.isUsable, isTrue);
      expect(report.hint, HandQualityHint.ready);
    });

    test('respects custom minHandScore threshold', () {
      final features = _features(span: 0.2);
      final strict = LandmarkQuality.assess(
        features42: features,
        handScore: 0.42,
        span: 0.2,
      );
      final relaxed = LandmarkQuality.assess(
        features42: features,
        handScore: 0.42,
        span: 0.2,
        minHandScoreThreshold: 0.40,
      );
      expect(strict.isUsable, isFalse);
      expect(relaxed.isUsable, isTrue);
    });

    test('skips hold steady when disabled', () {
      final previous = _features(span: 0.2);
      final current = List<double>.from(previous);
      for (var i = 0; i < current.length; i++) {
        current[i] += 0.05;
      }

      final report = LandmarkQuality.assess(
        features42: current,
        handScore: 0.9,
        span: 0.25,
        previousFeatures42: previous,
        holdSteadyEnabled: false,
      );

      expect(report.isUsable, isTrue);
      expect(report.hint, HandQualityHint.ready);
    });
  });
}
