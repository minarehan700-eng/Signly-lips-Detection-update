class NormalizedLandmarks {
  final List<double> features42;
  final int ts;
  final double handScore;
  final double span;

  const NormalizedLandmarks({
    required this.features42,
    required this.ts,
    this.handScore = 1.0,
    this.span = 0,
  });
}
