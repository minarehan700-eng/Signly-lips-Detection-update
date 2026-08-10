class Prediction {
  final String label;
  final double confidence;
  final int ts;
  final String? runnerUpLabel;
  final double? runnerUpConfidence;

  const Prediction({
    required this.label,
    required this.confidence,
    required this.ts,
    this.runnerUpLabel,
    this.runnerUpConfidence,
  });

  double get margin {
    if (runnerUpConfidence == null) return confidence;
    return confidence - runnerUpConfidence!;
  }
}
