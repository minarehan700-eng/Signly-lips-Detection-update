import 'package:flutter/material.dart';

/// Crops a single letter/digit from the bundled ASL alphabet chart.
class AslReferenceImage extends StatelessWidget {
  const AslReferenceImage({
    required this.letter,
    this.size = 96,
    super.key,
  });

  final String letter;
  final double size;

  static const _chartAsset = 'assets/images/asl_alphabet_chart.png';

  static const Map<String, (int row, int col, int cols)> _grid = {
    'A': (0, 0, 9),
    'B': (0, 1, 9),
    'C': (0, 2, 9),
    'D': (0, 3, 9),
    'E': (0, 4, 9),
    'F': (0, 5, 9),
    'G': (0, 6, 9),
    'H': (0, 7, 9),
    'I': (0, 8, 9),
    'J': (1, 0, 8),
    'K': (1, 1, 8),
    'L': (1, 2, 8),
    'M': (1, 3, 8),
    'N': (1, 4, 8),
    'O': (1, 5, 8),
    'P': (1, 6, 8),
    'Q': (1, 7, 8),
    'R': (2, 0, 10),
    'S': (2, 1, 10),
    'T': (2, 2, 10),
    'U': (2, 3, 10),
    'V': (2, 4, 10),
    'W': (2, 5, 10),
    'X': (2, 6, 10),
    'Y': (2, 7, 10),
    'Z': (2, 8, 10),
    '0': (2, 9, 10),
    '1': (3, 0, 9),
    '2': (3, 1, 9),
    '3': (3, 2, 9),
    '4': (3, 3, 9),
    '5': (3, 4, 9),
    '6': (3, 5, 9),
    '7': (3, 6, 9),
    '8': (3, 7, 9),
    '9': (3, 8, 9),
  };

  static String? positioningHint(String letter) {
    switch (letter) {
      case 'A':
        return 'Fist with thumb on the side of the index — not over the fingers like S.';
      case 'B':
        return 'Four fingers together pointing up; thumb flat in palm — not spread like 4.';
      case 'C':
        return 'Curved gap between thumb and fingers — not a closed circle like O.';
      default:
        return null;
    }
  }

  static bool showPalmForwardBanner(String letter) =>
      letter == 'A' || letter == 'B';

  @override
  Widget build(BuildContext context) {
    final cell = _grid[letter];
    if (cell == null) {
      return SizedBox(
        width: size,
        height: size,
        child: const Icon(Icons.image_not_supported_outlined),
      );
    }

    final (row, col, cols) = cell;
    const rowCount = 4;
    final cellWidth = 1 / cols;
    final cellHeight = 1 / rowCount;
    final left = col * cellWidth;
    final top = row * cellHeight;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: size,
        height: size,
        child: OverflowBox(
          maxWidth: size / cellWidth,
          maxHeight: size / cellHeight,
          alignment: Alignment(
            -1 + 2 * (left + cellWidth / 2),
            -1 + 2 * (top + cellHeight / 2),
          ),
          child: Image.asset(
            _chartAsset,
            fit: BoxFit.cover,
            width: size / cellWidth,
            height: size / cellHeight,
          ),
        ),
      ),
    );
  }
}
