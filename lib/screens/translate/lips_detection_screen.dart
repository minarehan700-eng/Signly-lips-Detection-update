import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../application/lip_letter_detector.dart';
import '../../application/lipsing_detector.dart';
import '../../core/app_theme.dart';
import '../../domain/face_lips_result.dart';
import '../../infrastructure/camera_frame_encoder.dart';
import '../../infrastructure/mediapipe_face_landmark_extractor.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_background.dart';

class LipsDetectionScreen extends StatefulWidget {
  const LipsDetectionScreen({super.key});

  @override
  State<LipsDetectionScreen> createState() => _LipsDetectionScreenState();
}

class _LipsDetectionScreenState extends State<LipsDetectionScreen> {
  final _extractor = MediaPipeFaceLandmarkExtractor();
  final _encoder = CameraFrameEncoder();
  final _lipsingDetector = LipsingDetector();
  final _lipLetterDetector = LipLetterDetector();

  CameraController? _camera;
  String? _cameraResolutionLabel;
  bool _initializing = true;
  bool _isProcessing = false;
  bool _setupStarted = false;
  bool _isFrontCamera = true;
  int _frameImageWidth = 0;
  int _frameImageHeight = 0;
  DateTime _lastProcessed = DateTime.fromMillisecondsSinceEpoch(0);
  String _initPhase = 'Starting...';
  String? _error;
  String? _targetLetter;
  FaceLipsResult _result = FaceLipsResult(
    faceDetected: false,
    mouthOpen: 0,
    mouthPucker: 0,
    smile: 0,
    isLipsing: false,
    ts: 0,
  );

  @override
  void initState() {
    super.initState();
    _scheduleSetup();
  }

  void _scheduleSetup() {
    if (_setupStarted) return;
    _setupStarted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _setupStarted = false;
        return;
      }
      unawaited(_setup());
    });
  }

  Future<void> _retrySetup() async {
    await _camera?.dispose();
    _camera = null;
    _cameraResolutionLabel = null;
    _lipsingDetector.reset();
    _lipLetterDetector.reset();
    _setupStarted = false;
    if (mounted) {
      setState(() {
        _error = null;
        _initializing = true;
        _initPhase = 'Starting...';
        _result = FaceLipsResult(
          faceDetected: false,
          mouthOpen: 0,
          mouthPucker: 0,
          smile: 0,
          isLipsing: false,
          ts: 0,
        );
      });
    }
    _scheduleSetup();
  }

  Future<void> _setup() async {
    try {
      if (mounted) {
        setState(() => _initPhase = 'Loading face landmarker...');
      }
      await _extractor.initialize();
      if (!mounted) return;

      if (mounted) {
        setState(() => _initPhase = 'Starting camera...');
      }

      final cams = await availableCameras();
      if (!mounted) return;
      if (cams.isEmpty) {
        setState(() {
          _error = 'No camera found on this device.';
          _initializing = false;
        });
        return;
      }

      final cam = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cams.first,
      );

      CameraController? controller;
      const presets = [
        ResolutionPreset.veryHigh,
        ResolutionPreset.high,
        ResolutionPreset.medium,
      ];
      for (final preset in presets) {
        final candidate = CameraController(
          cam,
          preset,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.yuv420,
        );
        try {
          await candidate.initialize();
          controller = candidate;
          break;
        } catch (_) {
          await candidate.dispose();
        }
      }

      if (controller == null) {
        setState(() {
          _error = 'Failed to initialize camera at any supported resolution.';
          _initializing = false;
        });
        return;
      }

      if (!mounted) {
        await controller.dispose();
        return;
      }
      await controller.startImageStream(_onFrame);
      if (!mounted) return;

      final previewSize = controller.value.previewSize;
      final resolutionLabel = previewSize != null
          ? 'Camera: ${previewSize.width.toInt()}×${previewSize.height.toInt()}'
          : null;

      setState(() {
        _camera = controller;
        _isFrontCamera = cam.lensDirection == CameraLensDirection.front;
        _cameraResolutionLabel = resolutionLabel;
        _initializing = false;
        _initPhase = 'Ready';
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message ?? e.code;
        _initializing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _initializing = false;
      });
    }
  }

  Future<void> _onFrame(CameraImage image) async {
    if (_isProcessing) return;
    final now = DateTime.now();
    if (now.difference(_lastProcessed).inMilliseconds < 150) {
      return;
    }
    _lastProcessed = now;
    _isProcessing = true;

    try {
      final jpeg = await _encoder.encodeToJpeg(image, quality: 92);
      if (jpeg == null || !mounted) return;
      final raw = await _extractor.processFrame(
        bytes: jpeg,
        width: image.width,
        height: image.height,
        rotation: 0,
      );
      if (!mounted) return;
      final lipsing = _lipsingDetector.update(raw);
      final scored = _lipLetterDetector.update(lipsing);
      setState(() {
        _frameImageWidth = image.width;
        _frameImageHeight = image.height;
        _result = scored;
      });
    } finally {
      _isProcessing = false;
    }
  }

  @override
  void dispose() {
    unawaited(_camera?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Lips Detection'),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_initializing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              _initPhase,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Initialization failed:\n$_error\n\n'
                'Make sure face_landmarker.task exists in '
                'android/app/src/main/assets (and the iOS Runner bundle) '
                'and camera permission is granted.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _retrySetup,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final mouthPct = (_result.mouthOpen.clamp(0.0, 1.0) * 100).round();
    final lipsing = _result.isLipsing;
    final displayLetter = _result.detectedLetter;
    final matched = _targetLetter != null && displayLetter == _targetLetter;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (_camera != null) _buildCameraPreview(context, lipsing),
            if (_cameraResolutionLabel != null) ...[
              const SizedBox(height: 6),
              Text(
                _cameraResolutionLabel!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white60,
                    ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatusCard(
                    label: 'Face',
                    value: _result.faceDetected ? 'Detected' : 'Not detected',
                    accent: _result.faceDetected ? AppTheme.brandTeal : Colors.orangeAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatusCard(
                    label: 'Lipsing',
                    value: lipsing ? 'Yes' : 'No',
                    accent: lipsing ? const Color(0xFF4ADE80) : Colors.white54,
                    prominent: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GlassCard(
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Column(
                children: [
                  Text(
                    'Detected letter',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    displayLetter ?? '—',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: matched
                              ? const Color(0xFF4ADE80)
                              : displayLetter != null
                                  ? AppTheme.brandTeal
                                  : Colors.white38,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                  ),
                  if (displayLetter != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${(_result.letterConfidence * 100).round()}% confidence',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                          ),
                    ),
                  ],
                  if (matched) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Matched!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF4ADE80),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final letter in LipLetterDetector.supportedLetters) ...[
                        _LetterChip(
                          letter: letter,
                          active: displayLetter == letter,
                          target: _targetLetter == letter,
                          onTap: () {
                            setState(() {
                              _targetLetter =
                                  _targetLetter == letter ? null : letter;
                            });
                          },
                        ),
                        if (letter != LipLetterDetector.supportedLetters.last)
                          const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 40.ms),
            const SizedBox(height: 10),
            GlassCard(
              borderRadius: 16,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mouth open',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        '$mouthPct%',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppTheme.brandTeal,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _result.mouthOpen.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: Colors.white12,
                      color: lipsing ? const Color(0xFF4ADE80) : AppTheme.brandBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _MiniMetric(
                        label: 'Pucker',
                        value: (_result.mouthPucker * 100).round(),
                      ),
                      const SizedBox(width: 10),
                      _MiniMetric(
                        label: 'Smile',
                        value: (_result.smile * 100).round(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _MiniMetric(
                        label: 'Close',
                        value: (_result.mouthClose * 100).round(),
                      ),
                      const SizedBox(width: 10),
                      _MiniMetric(
                        label: 'Funnel',
                        value: (_result.mouthFunnel * 100).round(),
                      ),
                      const SizedBox(width: 10),
                      _MiniMetric(
                        label: 'Stretch',
                        value: (_result.mouthStretch * 100).round(),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 80.ms),
            const SizedBox(height: 16),
            Text(
              'Smile=E · Round=C · Closed=B · Wide open=A · Slight open=D',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white60,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview(BuildContext context, bool lipsing) {
    final controller = _camera!;
    final previewSize = controller.value.previewSize;
    final isPortrait = MediaQuery.orientationOf(context) == Orientation.portrait;

    // previewSize is typically landscape sensor coords; invert for portrait UI.
    final double displayAspect;
    if (previewSize != null) {
      displayAspect = isPortrait
          ? previewSize.height / previewSize.width
          : previewSize.width / previewSize.height;
    } else {
      final controllerAspect = controller.value.aspectRatio;
      displayAspect = isPortrait
          ? (controllerAspect > 0 ? 1 / controllerAspect : 9 / 16)
          : (controllerAspect > 0 ? controllerAspect : 16 / 9);
    }

    final screenSize = MediaQuery.sizeOf(context);
    final maxHeight = screenSize.height * 0.33;
    final maxWidth = screenSize.width - 28;
    var previewWidth = maxWidth;
    var previewHeight = previewWidth / displayAspect;
    if (previewHeight > maxHeight) {
      previewHeight = maxHeight;
      previewWidth = previewHeight * displayAspect;
    }

    return GlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(8),
      child: Center(
        child: SizedBox(
          width: previewWidth,
          height: previewHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(controller),
                if (_result.hasMouthBox)
                  CustomPaint(
                    painter: _MouthBoxPainter(
                      minX: _result.mouthMinX,
                      minY: _result.mouthMinY,
                      maxX: _result.mouthMaxX,
                      maxY: _result.mouthMaxY,
                      imageWidth: _frameImageWidth > 0
                          ? _frameImageWidth
                          : (previewSize?.width.toInt() ?? 0),
                      imageHeight: _frameImageHeight > 0
                          ? _frameImageHeight
                          : (previewSize?.height.toInt() ?? 0),
                      isFrontCamera: _isFrontCamera,
                      active: lipsing,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 280.ms).scale(begin: const Offset(0.98, 0.98));
  }
}

class _LetterChip extends StatelessWidget {
  const _LetterChip({
    required this.letter,
    required this.active,
    required this.onTap,
    this.target = false,
  });

  final String letter;
  final bool active;
  final bool target;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = target
        ? AppTheme.brandBlue
        : active
            ? AppTheme.brandTeal
            : Colors.white24;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? AppTheme.brandTeal.withValues(alpha: 0.25)
              : target
                  ? AppTheme.brandBlue.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: active || target ? 1.5 : 1,
          ),
        ),
        child: Text(
          letter,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: active
                    ? AppTheme.brandTeal
                    : target
                        ? AppTheme.brandBlue
                        : Colors.white54,
                fontWeight: active || target ? FontWeight.w700 : FontWeight.w500,
              ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.label,
    required this.value,
    required this.accent,
    this.prominent = false,
  });

  final String label;
  final String value;
  final Color accent;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: (prominent
                    ? Theme.of(context).textTheme.headlineSmall
                    : Theme.of(context).textTheme.titleMedium)
                ?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              '$value%',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _MouthBoxPainter extends CustomPainter {
  _MouthBoxPainter({
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
    required this.imageWidth,
    required this.imageHeight,
    required this.isFrontCamera,
    required this.active,
  });

  final double minX;
  final double minY;
  final double maxX;
  final double maxY;
  final int imageWidth;
  final int imageHeight;
  final bool isFrontCamera;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    // JPEG landmarks are often landscape; preview widget is usually portrait.
    final imageIsLandscape = imageWidth > 0 &&
        imageHeight > 0 &&
        imageWidth > imageHeight;
    final widgetIsPortrait = size.height > size.width;
    final swapAxes = imageIsLandscape && widgetIsPortrait;

    Offset mapPoint(double nx, double ny) {
      var x = nx;
      var y = ny;
      if (swapAxes) {
        // Sensor landscape → display portrait (90° CW-style remap).
        final sx = x;
        x = y;
        y = 1.0 - sx;
      }
      if (isFrontCamera) {
        x = 1.0 - x;
      }
      return Offset(x * size.width, y * size.height);
    }

    final p1 = mapPoint(minX, minY);
    final p2 = mapPoint(maxX, maxY);
    var left = math.min(p1.dx, p2.dx);
    var top = math.min(p1.dy, p2.dy);
    var right = math.max(p1.dx, p2.dx);
    var bottom = math.max(p1.dy, p2.dy);

    var w = right - left;
    var h = bottom - top;

    // Force a horizontal lip band (never a tall vertical bar).
    if (h > w) {
      final cx = (left + right) / 2;
      final cy = (top + bottom) / 2;
      final tmp = w;
      w = h;
      h = tmp;
      left = cx - w / 2;
      right = cx + w / 2;
      top = cy - h / 2;
      bottom = cy + h / 2;
    }

    final minH = w * 0.22;
    final maxH = w * 0.48;
    if (h < minH || h > maxH) {
      final cy = (top + bottom) / 2;
      h = h.clamp(minH, maxH);
      top = cy - h / 2;
      bottom = cy + h / 2;
    }

    final rect = Rect.fromLTRB(left, top, right, bottom);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = active ? const Color(0xFF4ADE80) : AppTheme.brandTeal;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.inflate(6), const Radius.circular(8)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _MouthBoxPainter oldDelegate) {
    return oldDelegate.minX != minX ||
        oldDelegate.minY != minY ||
        oldDelegate.maxX != maxX ||
        oldDelegate.maxY != maxY ||
        oldDelegate.imageWidth != imageWidth ||
        oldDelegate.imageHeight != imageHeight ||
        oldDelegate.isFrontCamera != isFrontCamera ||
        oldDelegate.active != active;
  }
}
