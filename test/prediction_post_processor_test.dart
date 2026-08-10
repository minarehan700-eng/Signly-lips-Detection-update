import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_offline/application/prediction_post_processor.dart';
import 'package:mobile_offline/domain/prediction.dart';

Prediction _pred(
  String label, {
  double confidence = 0.8,
  String? runnerUp,
  double runnerUpConfidence = 0.5,
  int ts = 1000,
}) {
  return Prediction(
    label: label,
    confidence: confidence,
    ts: ts,
    runnerUpLabel: runnerUp,
    runnerUpConfidence: runnerUpConfidence,
  );
}

void main() {
  group('PredictionPostProcessor', () {
    test('rejects confused A/S frames unless margin is high', () {
      final processor = PredictionPostProcessor(
        confidenceThreshold: 0.55,
        windowSize: 4,
        minMargin: 0.1,
        confusionPenaltyEnabled: true,
        adaptiveThresholdEnabled: false,
      );

      final confused = _pred(
        'A',
        confidence: 0.72,
        runnerUp: 'S',
        runnerUpConfidence: 0.65,
      );
      for (var i = 0; i < 4; i++) {
        expect(processor.stable(confused.copyWith(ts: 1000 + i)), isNull);
      }
    });

    test('accepts stable winner with clear margin', () {
      final processor = PredictionPostProcessor(
        confidenceThreshold: 0.55,
        windowSize: 3,
        minMargin: 0.1,
        confusionPenaltyEnabled: true,
        adaptiveThresholdEnabled: false,
      );

      final clear = _pred(
        'B',
        confidence: 0.82,
        runnerUp: 'P',
        runnerUpConfidence: 0.2,
      );

      expect(processor.stable(clear.copyWith(ts: 1000)), isNull);
      expect(processor.stable(clear.copyWith(ts: 1001)), isNull);
      final result = processor.stable(clear.copyWith(ts: 1002));
      expect(result?.label, 'B');
    });

    test('target hint blocks confused S while practicing A', () {
      final processor = PredictionPostProcessor(
        confidenceThreshold: 0.5,
        windowSize: 3,
        minMargin: 0.08,
        confusionPenaltyEnabled: true,
        adaptiveThresholdEnabled: false,
      );

      final confusedS = _pred(
        'S',
        confidence: 0.72,
        runnerUp: 'A',
        runnerUpConfidence: 0.66,
      );

      for (var i = 0; i < 4; i++) {
        expect(
          processor.stable(confusedS.copyWith(ts: 1000 + i), targetHint: 'A'),
          isNull,
        );
      }
    });

    test('target hint accepts stable A while practicing A', () {
      final processor = PredictionPostProcessor(
        confidenceThreshold: 0.5,
        windowSize: 3,
        minMargin: 0.08,
        confusionPenaltyEnabled: true,
        adaptiveThresholdEnabled: false,
      );

      final clearA = _pred(
        'A',
        confidence: 0.78,
        runnerUp: 'S',
        runnerUpConfidence: 0.52,
      );

      expect(processor.stable(clearA.copyWith(ts: 1000), targetHint: 'A'), isNull);
      expect(processor.stable(clearA.copyWith(ts: 1001), targetHint: 'A'), isNull);
      final result = processor.stable(clearA.copyWith(ts: 1002), targetHint: 'A');
      expect(result?.label, 'A');
    });

    test('emits A then B then C without reset between signs', () {
      final processor = PredictionPostProcessor(
        confidenceThreshold: 0.55,
        windowSize: 3,
        minMargin: 0.1,
        confusionPenaltyEnabled: false,
        adaptiveThresholdEnabled: false,
        debounceMs: 350,
      );

      final clearA = _pred(
        'A',
        confidence: 0.82,
        runnerUp: 'S',
        runnerUpConfidence: 0.2,
      );
      final clearB = _pred(
        'B',
        confidence: 0.82,
        runnerUp: 'P',
        runnerUpConfidence: 0.2,
      );
      final clearC = _pred(
        'C',
        confidence: 0.82,
        runnerUp: 'O',
        runnerUpConfidence: 0.2,
      );

      expect(processor.stable(clearA.copyWith(ts: 1000)), isNull);
      expect(processor.stable(clearA.copyWith(ts: 1001)), isNull);
      expect(processor.stable(clearA.copyWith(ts: 1002))?.label, 'A');

      expect(processor.stable(clearA.copyWith(ts: 1100)), isNull);
      expect(processor.stable(clearA.copyWith(ts: 1200)), isNull);

      expect(processor.stable(clearB.copyWith(ts: 2000)), isNull);
      expect(processor.stable(clearB.copyWith(ts: 2001))?.label, 'B');

      expect(processor.stable(clearB.copyWith(ts: 2100)), isNull);

      expect(processor.stable(clearC.copyWith(ts: 3000)), isNull);
      expect(processor.stable(clearC.copyWith(ts: 3001))?.label, 'C');
    });

    test('does not re-emit same letter while hold is maintained', () {
      final processor = PredictionPostProcessor(
        confidenceThreshold: 0.55,
        windowSize: 3,
        minMargin: 0.1,
        confusionPenaltyEnabled: false,
        adaptiveThresholdEnabled: false,
      );

      final clearA = _pred(
        'A',
        confidence: 0.82,
        runnerUp: 'S',
        runnerUpConfidence: 0.2,
      );

      expect(processor.stable(clearA.copyWith(ts: 1000)), isNull);
      expect(processor.stable(clearA.copyWith(ts: 1001)), isNull);
      expect(processor.stable(clearA.copyWith(ts: 1002))?.label, 'A');

      for (var i = 0; i < 6; i++) {
        expect(processor.stable(clearA.copyWith(ts: 1100 + i)), isNull);
      }
    });

    test('ages stale window when transition frames fail gates', () {
      final processor = PredictionPostProcessor(
        confidenceThreshold: 0.55,
        windowSize: 3,
        minMargin: 0.1,
        confusionPenaltyEnabled: false,
        adaptiveThresholdEnabled: false,
      );

      final clearA = _pred(
        'A',
        confidence: 0.82,
        runnerUp: 'S',
        runnerUpConfidence: 0.2,
      );
      final weakB = _pred(
        'B',
        confidence: 0.40,
        runnerUp: 'P',
        runnerUpConfidence: 0.35,
      );
      final clearB = _pred(
        'B',
        confidence: 0.82,
        runnerUp: 'P',
        runnerUpConfidence: 0.2,
      );

      expect(processor.stable(clearA.copyWith(ts: 1000)), isNull);
      expect(processor.stable(clearA.copyWith(ts: 1001)), isNull);
      expect(processor.stable(clearA.copyWith(ts: 1002))?.label, 'A');

      for (var i = 0; i < 3; i++) {
        expect(processor.stable(weakB.copyWith(ts: 2000 + i)), isNull);
      }

      expect(processor.stable(clearB.copyWith(ts: 3000)), isNull);
      expect(processor.stable(clearB.copyWith(ts: 3001)), isNull);
      expect(processor.stable(clearB.copyWith(ts: 3002))?.label, 'B');
    });

    test('emits multiple characters in sequence after reset', () {
      final processor = PredictionPostProcessor(
        confidenceThreshold: 0.55,
        windowSize: 3,
        minMargin: 0.1,
        confusionPenaltyEnabled: false,
        adaptiveThresholdEnabled: false,
      );

      final clearA = _pred(
        'A',
        confidence: 0.82,
        runnerUp: 'S',
        runnerUpConfidence: 0.2,
      );
      final clearB = _pred(
        'B',
        confidence: 0.82,
        runnerUp: 'P',
        runnerUpConfidence: 0.2,
      );

      expect(processor.stable(clearA.copyWith(ts: 1000)), isNull);
      expect(processor.stable(clearA.copyWith(ts: 1001)), isNull);
      expect(processor.stable(clearA.copyWith(ts: 1002))?.label, 'A');

      processor.reset();
      expect(processor.stable(clearB.copyWith(ts: 2000)), isNull);
      expect(processor.stable(clearB.copyWith(ts: 2001)), isNull);
      expect(processor.stable(clearB.copyWith(ts: 2002))?.label, 'B');
    });

    test('re-emits same letter after reset clears emission lock', () {
      final processor = PredictionPostProcessor(
        confidenceThreshold: 0.55,
        windowSize: 3,
        minMargin: 0.1,
        confusionPenaltyEnabled: false,
        adaptiveThresholdEnabled: false,
      );

      final clearA = _pred(
        'A',
        confidence: 0.82,
        runnerUp: 'S',
        runnerUpConfidence: 0.2,
      );

      for (var i = 0; i < 3; i++) {
        processor.stable(clearA.copyWith(ts: 1000 + i));
      }
      expect(processor.stable(clearA.copyWith(ts: 1003)), isNull);

      processor.reset();
      expect(processor.stable(clearA.copyWith(ts: 2000)), isNull);
      expect(processor.stable(clearA.copyWith(ts: 2001)), isNull);
      expect(processor.stable(clearA.copyWith(ts: 2002))?.label, 'A');
    });

    test('same letter re-emits after window ages through transition', () {
      final processor = PredictionPostProcessor(
        confidenceThreshold: 0.55,
        windowSize: 3,
        minMargin: 0.1,
        confusionPenaltyEnabled: false,
        adaptiveThresholdEnabled: false,
      );

      final clearA = _pred(
        'A',
        confidence: 0.82,
        runnerUp: 'S',
        runnerUpConfidence: 0.2,
      );
      final clearB = _pred(
        'B',
        confidence: 0.82,
        runnerUp: 'P',
        runnerUpConfidence: 0.2,
      );

      expect(processor.stable(clearA.copyWith(ts: 1000)), isNull);
      expect(processor.stable(clearA.copyWith(ts: 1001)), isNull);
      expect(processor.stable(clearA.copyWith(ts: 1002))?.label, 'A');

      for (var i = 0; i < 3; i++) {
        processor.ageWindow();
      }
      expect(processor.stable(clearB.copyWith(ts: 2000)), isNull);
      expect(processor.stable(clearB.copyWith(ts: 2001)), isNull);
      expect(processor.stable(clearB.copyWith(ts: 2002))?.label, 'B');

      for (var i = 0; i < 3; i++) {
        processor.ageWindow();
      }
      expect(processor.stable(clearA.copyWith(ts: 3000)), isNull);
      expect(processor.stable(clearA.copyWith(ts: 3001)), isNull);
      expect(processor.stable(clearA.copyWith(ts: 3002))?.label, 'A');
    });

    test('ageWindow unblocks next sign after skipped transition frames', () {
      final processor = PredictionPostProcessor(
        confidenceThreshold: 0.55,
        windowSize: 3,
        minMargin: 0.1,
        confusionPenaltyEnabled: false,
        adaptiveThresholdEnabled: false,
      );

      final clearA = _pred(
        'A',
        confidence: 0.82,
        runnerUp: 'S',
        runnerUpConfidence: 0.2,
      );
      final clearB = _pred(
        'B',
        confidence: 0.82,
        runnerUp: 'P',
        runnerUpConfidence: 0.2,
      );

      expect(processor.stable(clearA.copyWith(ts: 1000)), isNull);
      expect(processor.stable(clearA.copyWith(ts: 1001)), isNull);
      expect(processor.stable(clearA.copyWith(ts: 1002))?.label, 'A');

      for (var i = 0; i < 3; i++) {
        processor.ageWindow();
      }

      expect(processor.stable(clearB.copyWith(ts: 2000)), isNull);
      expect(processor.stable(clearB.copyWith(ts: 2001)), isNull);
      expect(processor.stable(clearB.copyWith(ts: 2002))?.label, 'B');
    });

    test('adaptive threshold blocks unstable low-margin windows', () {
      final processor = PredictionPostProcessor(
        confidenceThreshold: 0.55,
        windowSize: 3,
        minMargin: 0.08,
        adaptiveThresholdEnabled: true,
        confusionPenaltyEnabled: false,
      );

      final a = _pred('A', confidence: 0.58, runnerUp: 'S', runnerUpConfidence: 0.5);
      final b = _pred('B', confidence: 0.57, runnerUp: 'P', runnerUpConfidence: 0.49);
      final c = _pred('A', confidence: 0.59, runnerUp: 'S', runnerUpConfidence: 0.51);

      expect(processor.stable(a.copyWith(ts: 1000)), isNull);
      expect(processor.stable(b.copyWith(ts: 1001)), isNull);
      expect(processor.stable(c.copyWith(ts: 1002)), isNull);
    });
  });
}

extension on Prediction {
  Prediction copyWith({int? ts}) {
    return Prediction(
      label: label,
      confidence: confidence,
      ts: ts ?? this.ts,
      runnerUpLabel: runnerUpLabel,
      runnerUpConfidence: runnerUpConfidence,
    );
  }
}
