import 'dart:typed_data';

import 'landmarks.dart';
import 'prediction.dart';

abstract class HandLandmarkExtractor {
  Future<void> initialize();
  Future<NormalizedLandmarks?> processFrame({
    required Uint8List bytes,
    required int width,
    required int height,
    required int rotation,
  });
}

abstract class GestureClassifier {
  Future<void> load();
  Prediction classify(List<double> features);
}

abstract class TemperatureAwareClassifier {
  double get temperature;
  set temperature(double value);
}
