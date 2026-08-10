import 'package:flutter/material.dart';

class HandSkeletonPainter extends CustomPainter {
  static const List<int> _connections = [
    0, 1, 1, 2, 2, 3, 3, 4,
    0, 5, 5, 6, 6, 7, 7, 8,
    0, 9, 9, 10, 10, 11, 11, 12,
    0, 13, 13, 14, 14, 15, 15, 16,
    0, 17, 17, 18, 18, 19, 19, 20,
  ];

  static const List<String> _landmarkNames = [
    'Wrist',
    'Thumb Base', 'Thumb Mid', 'Thumb Tip',
    'Index Base', 'Index Mid', 'Index Tip',
    'Middle Base', 'Middle Mid', 'Middle Tip',
    'Ring Base', 'Ring Mid', 'Ring Tip',
    'Pinky Base', 'Pinky Mid', 'Pinky Tip',
  ];

  final List<double> landmarks;
  final int imageWidth;
  final int imageHeight;
  final bool showLabels;
  final bool showConnections;

  HandSkeletonPainter({
    required this.landmarks,
    required this.imageWidth,
    required this.imageHeight,
    this.showLabels = false,
    this.showConnections = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks.isEmpty || landmarks.length != 42) {
      return;
    }

    final scaleX = size.width / imageWidth;
    final scaleY = size.height / imageHeight;

    final bonePaint = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.8)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final jointPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.fill;

    final wristPaint = Paint()
      ..color = Colors.cyan
      ..style = PaintingStyle.fill;

    final points = <Offset>[];
    for (int i = 0; i < landmarks.length; i += 2) {
      final x = landmarks[i] * scaleX;
      final y = landmarks[i + 1] * scaleY;
      points.add(Offset(x, y));
    }

    if (showConnections) {
      for (int i = 0; i < _connections.length; i += 2) {
        final startIdx = _connections[i];
        final endIdx = _connections[i + 1];

        if (startIdx < points.length && endIdx < points.length) {
          canvas.drawLine(
            points[startIdx],
            points[endIdx],
            bonePaint,
          );
        }
      }
    }

    for (int i = 0; i < points.length; i++) {
      final paint = i == 0 ? wristPaint : jointPaint;
      final radius = i == 0 ? 6.0 : 4.0;

      canvas.drawCircle(points[i], radius, paint);

      if (showLabels && i < _landmarkNames.length) {
        _drawLabel(canvas, points[i], _landmarkNames[i]);
      }
    }
  }

  void _drawLabel(Canvas canvas, Offset position, String label) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      position.translate(8, -textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(HandSkeletonPainter oldDelegate) {
    return oldDelegate.landmarks != landmarks;
  }
}
