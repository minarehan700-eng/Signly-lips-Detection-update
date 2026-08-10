import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_theme.dart';
import 'glass_card.dart';

class TranslateHubCard extends StatelessWidget {
  const TranslateHubCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.imageAsset,
    this.delayMs = 0,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? imageAsset;
  final VoidCallback onTap;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        borderRadius: 18,
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [AppTheme.brandBlue, AppTheme.brandPurple],
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ],
              ),
            ),
            if (imageAsset != null)
              Image.asset(
                imageAsset!,
                width: 36,
                height: 36,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: AppTheme.brandTeal.withValues(alpha: 0.8),
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: AppTheme.brandTeal.withValues(alpha: 0.8),
              ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: delayMs.ms, duration: 320.ms)
        .slideX(begin: 0.04, curve: Curves.easeOutCubic);
  }
}
