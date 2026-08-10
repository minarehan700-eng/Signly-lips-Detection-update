import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../domain/contracts.dart';
import '../domain/prediction.dart';

class TfliteGestureClassifier implements GestureClassifier, TemperatureAwareClassifier {
  Interpreter? _interpreter;
  late Map<int, String> _labels;

  @override
  double temperature = 0.85;

  @override
  Future<void> load() async {
    _interpreter = await Interpreter.fromAsset("assets/models/asl_classifier.tflite");
    final labelsRaw = await rootBundle.loadString("assets/models/labels.json");
    final parsed = jsonDecode(labelsRaw) as Map<String, dynamic>;
    _labels = parsed.map((k, v) => MapEntry(int.parse(k), v.toString()));
  }

  @override
  Prediction classify(List<double> features) {
    final interpreter = _interpreter;
    if (interpreter == null) {
      throw StateError("Classifier is not loaded");
    }
    if (features.length != 42) {
      throw ArgumentError("Expected 42 features, got ${features.length}");
    }

    final input = [List<double>.from(features)];
    final output = [List<double>.filled(37, 0)];
    interpreter.run(input, output);

    final probs = _applyTemperature(output[0], temperature);
    var bestIdx = 0;
    var secondIdx = 1;
    var bestScore = probs[0];
    var secondScore = probs[1];

    if (secondScore > bestScore) {
      final tempIdx = bestIdx;
      final tempScore = bestScore;
      bestIdx = secondIdx;
      bestScore = secondScore;
      secondIdx = tempIdx;
      secondScore = tempScore;
    }

    for (var i = 2; i < probs.length; i++) {
      final score = probs[i];
      if (score > bestScore) {
        secondIdx = bestIdx;
        secondScore = bestScore;
        bestIdx = i;
        bestScore = score;
      } else if (score > secondScore) {
        secondIdx = i;
        secondScore = score;
      }
    }

    return Prediction(
      label: _labels[bestIdx] ?? "?",
      confidence: bestScore,
      ts: DateTime.now().millisecondsSinceEpoch,
      runnerUpLabel: _labels[secondIdx],
      runnerUpConfidence: secondScore,
    );
  }

  List<double> _applyTemperature(List<double> probs, double temp) {
    if (temp == 1.0) return probs;

    const eps = 1e-8;
    final logits = probs
        .map((p) => math.log((p + eps).clamp(eps, 1.0)) / temp)
        .toList(growable: false);
    final maxLogit = logits.reduce(math.max);
    final expVals = logits.map((v) => math.exp(v - maxLogit)).toList();
    final sum = expVals.reduce((a, b) => a + b);
    return expVals.map((v) => v / sum).toList(growable: false);
  }

  List<Prediction> topPredictions(List<double> features, {int count = 3}) {
    final interpreter = _interpreter;
    if (interpreter == null) {
      throw StateError("Classifier is not loaded");
    }

    final input = [List<double>.from(features)];
    final output = [List<double>.filled(37, 0)];
    interpreter.run(input, output);

    final probs = _applyTemperature(output[0], temperature);
    final ranked = <(int, double)>[];
    for (var i = 0; i < probs.length; i++) {
      ranked.add((i, probs[i]));
    }
    ranked.sort((a, b) => b.$2.compareTo(a.$2));

    final ts = DateTime.now().millisecondsSinceEpoch;
    return ranked
        .take(count)
        .map(
          (entry) => Prediction(
            label: _labels[entry.$1] ?? "?",
            confidence: entry.$2,
            ts: ts,
          ),
        )
        .toList();
  }
}
