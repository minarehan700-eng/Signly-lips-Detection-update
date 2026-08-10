import 'package:flutter/services.dart';

import '../domain/contracts.dart';
import '../domain/landmarks.dart';

class MediaPipeHandLandmarkExtractor implements HandLandmarkExtractor {
  static const MethodChannel _channel = MethodChannel("asl/offline/landmarks");
  bool _initialized = false;

  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await _channel.invokeMethod("initializeHandLandmarker");
      _initialized = true;
    } on PlatformException catch (e) {
      throw Exception(
        e.message ?? 'Hand landmarker failed to initialize (${e.code}).',
      );
    }
  }

  @override
  Future<NormalizedLandmarks?> processFrame({
    required Uint8List bytes,
    required int width,
    required int height,
    required int rotation,
  }) async {
    if (bytes.isEmpty || width <= 0 || height <= 0) {
      return null;
    }

    final Map<String, dynamic>? response;
    try {
      response = await _channel.invokeMapMethod<String, dynamic>(
        "processFrame",
        {
          "bytes": bytes,
          "width": width,
          "height": height,
          "rotation": rotation,
        },
      );
    } on PlatformException {
      return null;
    }

    if (response == null) {
      return null;
    }

    final rawFeatures = response["features42"] as List<dynamic>?;
    if (rawFeatures == null || rawFeatures.length != 42) {
      return null;
    }

    final features = rawFeatures.map((e) => (e as num).toDouble()).toList(growable: false);
    final ts = (response["ts"] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch;
    final handScore = (response["handScore"] as num?)?.toDouble() ?? 1.0;
    final span = (response["span"] as num?)?.toDouble() ?? 0.0;
    return NormalizedLandmarks(
      features42: features,
      ts: ts,
      handScore: handScore,
      span: span,
    );
  }
}
