import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_background.dart';

class SignDetailScreen extends StatelessWidget {
  const SignDetailScreen({
    required this.title,
    required this.assetPath,
    super.key,
  });

  final String title;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(title),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GlassCard(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.image_not_supported_outlined,
                      size: 64,
                    ),
                  ),
                ).animate().fadeIn(duration: 320.ms).scale(
                      begin: const Offset(0.95, 0.95),
                      curve: Curves.easeOutCubic,
                    ),
                const SizedBox(height: 30),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppTheme.brandBlue, AppTheme.brandTeal],
                  ).createShader(bounds),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 54,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
