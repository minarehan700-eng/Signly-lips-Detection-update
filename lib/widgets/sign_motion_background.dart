import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class SignMotionBackground extends StatefulWidget {
  const SignMotionBackground({super.key});

  @override
  State<SignMotionBackground> createState() => _SignMotionBackgroundState();
}

class _SignMotionBackgroundState extends State<SignMotionBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value * math.pi * 2;
          return LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              return Stack(
                children: [
                  Positioned(
                    top: h * 0.12 + math.sin(t) * 16,
                    left: w * 0.08 + math.cos(t) * 12,
                    child: const _SignGlyph(icon: Icons.sign_language_rounded, size: 46),
                  ),
                  Positioned(
                    top: h * 0.24 + math.cos(t * 1.2) * 22,
                    right: w * 0.08 + math.sin(t * 1.3) * 14,
                    child: const _SignGlyph(icon: Icons.waving_hand_rounded, size: 40),
                  ),
                  Positioned(
                    bottom: h * 0.22 + math.sin(t * 0.9) * 24,
                    left: w * 0.1 + math.cos(t * 1.1) * 16,
                    child: const _SignGlyph(icon: Icons.gesture_rounded, size: 42),
                  ),
                  Positioned(
                    bottom: h * 0.15 + math.cos(t * 1.4) * 20,
                    right: w * 0.14 + math.sin(t * 1.2) * 14,
                    child: const _SignGlyph(icon: Icons.pan_tool_alt_rounded, size: 34),
                  ),
                  Positioned(
                    top: h * 0.42 + math.sin(t * 1.6) * 18,
                    left: w * 0.42 + math.cos(t * 1.5) * 24,
                    child: _pulseRing(80, AppTheme.brandPurple.withValues(alpha: 0.20)),
                  ),
                  Positioned(
                    top: h * 0.56 + math.cos(t * 1.8) * 20,
                    left: w * 0.24 + math.sin(t * 1.7) * 18,
                    child: _pulseRing(56, AppTheme.brandTeal.withValues(alpha: 0.18)),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _pulseRing(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.4),
      ),
    );
  }
}

class _SignGlyph extends StatelessWidget {
  const _SignGlyph({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: Colors.white.withValues(alpha: 0.72), size: size * 0.52),
    );
  }
}
