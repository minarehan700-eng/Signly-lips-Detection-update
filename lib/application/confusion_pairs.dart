class ConfusionPairs {
  const ConfusionPairs._();

  static const double defaultPenalty = 0.55;
  static const double highMarginBypass = 0.22;

  static const Map<String, Set<String>> _pairs = {
    'A': {'S', 'E', 'T'},
    'S': {'A', 'T', 'N'},
    'M': {'N', 'T', 'S'},
    'N': {'M', 'T', 'S'},
    'G': {'H', 'Q'},
    'H': {'G', 'U'},
    'C': {'O', 'G'},
    'O': {'C', 'Q'},
    '6': {'9', 'Y'},
    '9': {'6', 'G'},
    'D': {'P', 'Q', 'F'},
    'P': {'D', 'Q', 'K'},
    'Q': {'G', 'P', 'O'},
    'F': {'D', 'U'},
    'E': {'A', 'S'},
    'T': {'N', 'M', 'A'},
    'B': {'4', 'V'},
    'V': {'B', 'U'},
    '1': {'I', 'L'},
    'I': {'1', 'J'},
    'L': {'1', 'I'},
    'R': {'U', 'V'},
    'U': {'R', 'H'},
    'Y': {'6', 'J'},
    'J': {'I', 'Y'},
    'K': {'P', 'V'},
    'W': {'V', 'U'},
    'X': {'K', 'H'},
    'Z': {'2', '3'},
    '2': {'Z', 'V'},
    '3': {'W', 'E'},
    '4': {'B', 'H'},
    '5': {'S', 'F'},
    '7': {'T', 'L'},
    '8': {'A', 'O'},
    '0': {'O', 'C'},
  };

  static bool areConfused(String a, String b) {
    if (a == b) return false;
    return _pairs[a]?.contains(b) ?? _pairs[b]?.contains(a) ?? false;
  }

  static const double practiceTargetPenalty = 0.32;

  static const Map<String, String> _practiceConfusionPartner = {
    'A': 'S',
    'B': '4',
    'C': 'O',
  };

  static double weightFor({
    required String label,
    required String? runnerUpLabel,
    required double margin,
    required double baseConfidence,
    bool enabled = true,
    String? practiceTarget,
  }) {
    var weight = baseConfidence;

    if (enabled && runnerUpLabel != null) {
      if (areConfused(label, runnerUpLabel) && margin < highMarginBypass) {
        final penalty = defaultPenalty + (0.18 - margin).clamp(0.0, 0.18) * 0.8;
        weight = baseConfidence * penalty.clamp(0.25, 1.0);
      }
    }

    if (practiceTarget != null && label != practiceTarget) {
      final partner = _practiceConfusionPartner[practiceTarget];
      if (partner != null && label == partner) {
        weight *= practiceTargetPenalty;
      } else if (areConfused(practiceTarget, label)) {
        weight *= 0.45;
      }
    }

    return weight;
  }
}
