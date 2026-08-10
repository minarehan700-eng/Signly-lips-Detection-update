import 'dart:math' as math;

import 'package:flutter/material.dart';

class GeometricWaveShapes extends StatefulWidget {
  const GeometricWaveShapes({super.key});

  @override
  State<GeometricWaveShapes> createState() => _GeometricWaveShapesState();
}

class _GeometricWaveShapesState extends State<GeometricWaveShapes>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
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
        builder: (_, __) {
          return CustomPaint(
            painter: _GeometricWavePainter(progress: _controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _GeometricWavePainter extends CustomPainter {
  _GeometricWavePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = Colors.white.withValues(alpha: 0.14);
    final p2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withValues(alpha: 0.1);

    _drawWave(canvas, size, yBase: size.height * 0.24, amp: 22, phaseShift: 0.0, paint: p1);
    _drawWave(canvas, size, yBase: size.height * 0.42, amp: 28, phaseShift: math.pi * 0.4, paint: p2);
    _drawWave(canvas, size, yBase: size.height * 0.68, amp: 18, phaseShift: math.pi * 0.8, paint: p1);
  }

  void _drawWave(
    Canvas canvas,
    Size size, {
    required double yBase,
    required double amp,
    required double phaseShift,
    required Paint paint,
  }) {
    final path = Path();
    const step = 26.0;
    final phase = (progress * math.pi * 2) + phaseShift;
    var started = false;

    for (double x = -step; x <= size.width + step; x += step) {
      final y = yBase + math.sin((x / size.width) * math.pi * 4 + phase) * amp;
      if (!started) {
        path.moveTo(x, y);
        started = true;
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    final trianglePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = paint.color.withValues(alpha: paint.color.a * 0.45);

    for (double x = 0; x <= size.width; x += step * 3) {
      final y = yBase + math.sin((x / size.width) * math.pi * 4 + phase) * amp;
      final tri = Path()
        ..moveTo(x, y - 7)
        ..lineTo(x + 5, y + 4)
        ..lineTo(x - 5, y + 4)
        ..close();
      canvas.drawPath(tri, trianglePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GeometricWavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
