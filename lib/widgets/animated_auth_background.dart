import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import 'geometric_wave_shapes.dart';

class AnimatedAuthBackground extends StatefulWidget {
  const AnimatedAuthBackground({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<AnimatedAuthBackground> createState() => _AnimatedAuthBackgroundState();
}

class _AnimatedAuthBackgroundState extends State<AnimatedAuthBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final t = _controller.value;
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF090D1E),
                Color(0xFF1A2141),
                Color(0xFF2D2356),
              ],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              final blob = math.min(width, height) * 0.45;
              final dy = math.sin(t * math.pi * 2) * 28;
              final dx = math.cos(t * math.pi * 2) * 24;

              return Stack(
                fit: StackFit.expand,
                children: [
                  const GeometricWaveShapes(),
                  Positioned(
                    top: 40 + dy,
                    left: -50 + dx,
                    child: _GlowOrb(size: blob, color: AppTheme.brandPurple),
                  ),
                  Positioned(
                    bottom: -40 - dy,
                    right: -40 - dx,
                    child: _GlowOrb(size: blob * 0.9, color: AppTheme.brandBlue),
                  ),
                  Positioned(
                    top: height * 0.35 + dx,
                    right: width * 0.22,
                    child: _GlowOrb(size: blob * 0.5, color: AppTheme.brandTeal),
                  ),
                  Positioned(
                    top: 72 + dy,
                    right: 22 + dx,
                    child: _FloatingSignChip(
                      label: 'A',
                      icon: Icons.sign_language_rounded,
                      scale: 1 + (t * 0.08),
                    ),
                  ),
                  Positioned(
                    top: height * 0.28 - dy,
                    left: 18 + (dx * 0.6),
                    child: _FloatingSignChip(
                      label: 'B',
                      icon: Icons.waving_hand_rounded,
                      scale: 0.95 + (t * 0.1),
                    ),
                  ),
                  Positioned(
                    bottom: 150 + (dy * 0.8),
                    right: width * 0.16 - (dx * 0.5),
                    child: _FloatingSignChip(
                      label: 'C',
                      icon: Icons.gesture_rounded,
                      scale: 0.92 + (t * 0.09),
                    ),
                  ),
                  widget.child,
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.45),
              color.withValues(alpha: 0.08),
              Colors.transparent,
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
      ),
    );
  }
}

class _FloatingSignChip extends StatelessWidget {
  const _FloatingSignChip({
    required this.label,
    required this.icon,
    required this.scale,
  });

  final String label;
  final IconData icon;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withValues(alpha: 0.11),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
