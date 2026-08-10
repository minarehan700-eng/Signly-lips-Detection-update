import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../widgets/animated_brand_text.dart';
import '../../widgets/animated_auth_background.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
    this.heroIcon = Icons.sign_language_rounded,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final IconData heroIcon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedAuthBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final contentMaxWidth = width > 460 ? 420.0 : width - 28;
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 74,
                                height: 74,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF5A7CFF), Color(0xFF9D56FF)],
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x665A7CFF),
                                      blurRadius: 18,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.sign_language_rounded,
                                  size: 38,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const AnimatedBrandText(
                                text: 'Signly',
                                fontSize: 26,
                                letterSpacing: 0.35,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 260.ms).scale(begin: const Offset(0.9, 0.9)),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF5E7BFF), Color(0xFF9D56FF)],
                                ),
                              ),
                              child: Icon(heroIcon, color: Colors.white, size: 30),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                title,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.05),
                        const SizedBox(height: 14),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white70,
                              ),
                        ).animate().fadeIn(delay: 60.ms, duration: 280.ms),
                        const SizedBox(height: 18),
                        child.animate().fadeIn(delay: 110.ms, duration: 320.ms).slideY(begin: 0.04),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
