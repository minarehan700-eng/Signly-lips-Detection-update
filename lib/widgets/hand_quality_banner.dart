import 'package:flutter/material.dart';

import '../application/landmark_quality.dart';

class HandQualityBanner extends StatelessWidget {
  const HandQualityBanner({
    super.key,
    required this.report,
  });

  final HandQualityReport report;

  @override
  Widget build(BuildContext context) {
    if (report.hint == HandQualityHint.ready || report.message.isEmpty) {
      return const SizedBox.shrink();
    }

    final color = switch (report.hint) {
      HandQualityHint.movingTooFast => Colors.amber,
      HandQualityHint.lowDetectionScore => Colors.orange,
      HandQualityHint.handTooSmall || HandQualityHint.handTooLarge => Colors.cyan,
      HandQualityHint.noHand => Colors.redAccent,
      HandQualityHint.ready => Colors.green,
    };

    final icon = switch (report.hint) {
      HandQualityHint.movingTooFast => Icons.back_hand_rounded,
      HandQualityHint.lowDetectionScore => Icons.light_mode_rounded,
      HandQualityHint.handTooSmall => Icons.zoom_in_rounded,
      HandQualityHint.handTooLarge => Icons.zoom_out_rounded,
      HandQualityHint.noHand => Icons.pan_tool_alt_rounded,
      HandQualityHint.ready => Icons.check_circle_rounded,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              report.message,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
