import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_offline/application/letter_geometry_validator.dart';
import 'package:mobile_offline/domain/prediction.dart';

List<double> _baseFeatures() => List<double>.filled(42, 0);

void _setLandmark(List<double> f, int index, double x, double y) {
  f[index * 2] = x;
  f[index * 2 + 1] = y;
}

void main() {
  group('LetterGeometryValidator', () {
    test('detects B-like low finger spread', () {
      final f = _baseFeatures();
      _setLandmark(f, 0, 0.0, 0.0);
      _setLandmark(f, 4, 0.04, 0.06);
      _setLandmark(f, 5, 0.12, 0.18);
      _setLandmark(f, 8, 0.14, 0.62);
      _setLandmark(f, 12, 0.145, 0.625);
      _setLandmark(f, 16, 0.15, 0.63);
      _setLandmark(f, 20, 0.155, 0.635);

      final match = LetterGeometryValidator.evaluate(f);
      expect(match, isNotNull);
      expect(match!.letter, 'B');
    });

    test('applyOverride replaces confused low-margin prediction', () {
      final f = _baseFeatures();
      _setLandmark(f, 0, 0.0, 0.0);
      _setLandmark(f, 4, 0.04, 0.06);
      _setLandmark(f, 5, 0.12, 0.18);
      _setLandmark(f, 8, 0.14, 0.62);
      _setLandmark(f, 12, 0.145, 0.625);
      _setLandmark(f, 16, 0.15, 0.63);
      _setLandmark(f, 20, 0.155, 0.635);

      final raw = Prediction(
        label: '4',
        confidence: 0.62,
        ts: 1000,
        runnerUpLabel: 'B',
        runnerUpConfidence: 0.58,
      );

      final overridden = LetterGeometryValidator.applyOverride(raw: raw, features42: f);
      expect(overridden, isNotNull);
      expect(overridden!.label, 'B');
    });

    test('skips override when margin is high', () {
      final f = _baseFeatures();
      final raw = Prediction(
        label: 'A',
        confidence: 0.9,
        ts: 1000,
        runnerUpLabel: 'S',
        runnerUpConfidence: 0.5,
      );

      expect(
        LetterGeometryValidator.applyOverride(raw: raw, features42: f),
        isNull,
      );
    });
  });
}
