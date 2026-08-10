import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../application/offline_recognition_controller.dart';
import '../../application/prediction_post_processor.dart';
import '../../core/accuracy_tracker.dart';
import '../../core/app_navigation.dart';
import '../../domain/sign_info.dart';
import '../../widgets/asl_reference_image.dart';
import 'collect_data_screen.dart';
import '../../infrastructure/camera_frame_encoder.dart';
import '../../infrastructure/mediapipe_hand_landmark_extractor.dart';
import '../../infrastructure/tflite_gesture_classifier.dart';
import '../../application/landmark_quality.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/hand_quality_banner.dart';
import '../../widgets/hand_skeleton_painter.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({this.target, super.key});

  final String? target;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late final OfflineRecognitionController _controller;
  final _encoder = CameraFrameEncoder();
  final _tracker = AccuracyTracker();

  CameraController? _camera;
  bool _initializing = true;
  String? _error;
  bool _isProcessing = false;
  DateTime _lastProcessed = DateTime.fromMillisecondsSinceEpoch(0);

  late String _currentTarget;
  int _correctCount = 0;
  int _totalAttempts = 0;
  int _correctOnFirstTry = 0;
  double _currentConfidence = 0;
  String _currentLabel = '-';
  bool _isComplete = false;
  bool _showSkeleton = true;
  List<double>? _currentLandmarks;
  HandQualityReport _qualityReport = const HandQualityReport(
    isUsable: false,
    hint: HandQualityHint.noHand,
  );

  @override
  void initState() {
    super.initState();
    _currentTarget = widget.target ?? 'A';
    _controller = OfflineRecognitionController(
      landmarkExtractor: MediaPipeHandLandmarkExtractor(),
      classifier: TfliteGestureClassifier(),
      postProcessor: PredictionPostProcessor(),
    );
    _setup();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.reloadSettings();
  }

  Future<void> _setup() async {
    try {
      await _controller.initialize();
      final cams = await availableCameras();
      final cam = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cams.first,
      );

      final controller = CameraController(
        cam,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();
      await controller.startImageStream(_onFrame);
      if (!mounted) return;
      setState(() {
        _camera = controller;
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
    if (now.difference(_lastProcessed).inMilliseconds < 90) {
      return;
    }
    _lastProcessed = now;
    _isProcessing = true;

    try {
      final jpeg = await _encoder.encodeToJpeg(image);
      if (jpeg == null) return;
      final prediction = await _controller.onFrame(
        bytes: jpeg,
        width: image.width,
        height: image.height,
        rotation: 0,
        targetHint: _practiceTargetHint,
      );
      if (!mounted) return;

      final landmarks = _controller.lastLandmarks;
      setState(() {
        _qualityReport = _controller.qualityReport;
        if (landmarks != null) {
          _currentLandmarks = landmarks.features42;
        }
        if (prediction != null) {
          _currentLabel = prediction.label;
          _currentConfidence = prediction.confidence;

          if (prediction.label == _currentTarget) {
            _correctCount++;
            if (_correctCount == 1) {
              _totalAttempts++;
              _correctOnFirstTry++;
            }
            if (_correctCount >= 3) {
              _isComplete = true;
              _tracker.record(_currentTarget, true);
            }
          } else {
            if (_correctCount > 0) {
              _totalAttempts++;
              _tracker.record(_currentTarget, false);
            }
            _correctCount = 0;
          }
        }
      });
    } finally {
      _isProcessing = false;
    }
  }

  void _nextSign() {
    setState(() {
      _correctCount = 0;
      _isComplete = false;
      _currentConfidence = 0;
      _currentLabel = '-';
    });
  }

  String? get _practiceTargetHint {
    if ({'A', 'B', 'C'}.contains(_currentTarget)) {
      return _currentTarget;
    }
    return null;
  }

  void _openCollectData() {
    Navigator.of(context).push(
      AppNavigation.fadeTransition(const CollectDataScreen()),
    );
  }

  void _markComplete() {
    setState(() {
      _isComplete = false;
      _totalAttempts++;
      _currentConfidence = 0;
      _currentLabel = '-';
      _correctCount = 0;
    });
  }

  @override
  void dispose() {
    unawaited(_camera?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error: $_error'),
        ),
      );
    }

    final targetInfo = kSignInfoMap[_currentTarget] ?? kSignInfoMap['A']!;
    final positioningHint = AslReferenceImage.positioningHint(_currentTarget);
    final showPalmBanner = AslReferenceImage.showPalmForwardBanner(_currentTarget);

    return SafeArea(
      child: Column(
        children: [
          GlassCard(
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Practice', style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 8),
                          Text(
                            _currentTarget == ' ' ? 'Space' : _currentTarget,
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 48),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    AslReferenceImage(letter: _currentTarget, size: 88),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  targetInfo.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (showPalmBanner) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.cyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.cyan.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      'Match the reference — palm faces camera for A and B',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.cyan),
                    ),
                  ),
                ],
                if (positioningHint != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    positioningHint,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.amber,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_camera != null)
            GlassCard(
              borderRadius: 16,
              padding: const EdgeInsets.all(8),
              child: AspectRatio(
                aspectRatio: _camera!.value.aspectRatio,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      CameraPreview(_camera!),
                      if (_showSkeleton && _currentLandmarks != null)
                        CustomPaint(
                          painter: HandSkeletonPainter(
                            landmarks: _currentLandmarks!,
                            imageWidth: _camera!.value.previewSize?.width.toInt() ?? 640,
                            imageHeight: _camera!.value.previewSize?.height.toInt() ?? 480,
                            showLabels: false,
                            showConnections: true,
                          ),
                        ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: Icon(
                              _showSkeleton ? Icons.visibility : Icons.visibility_off,
                              color: Colors.cyan,
                            ),
                            onPressed: () => setState(() => _showSkeleton = !_showSkeleton),
                            iconSize: 20,
                          ),
                        ),
                      ),
                      if (_qualityReport.hint != HandQualityHint.ready)
                        Positioned(
                          top: 48,
                          left: 12,
                          right: 12,
                          child: HandQualityBanner(report: _qualityReport),
                        ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _currentLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${(_currentConfidence * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _currentConfidence,
                                minHeight: 6,
                                backgroundColor: Colors.white24,
                                valueColor: AlwaysStoppedAnimation(
                                  _currentConfidence < 0.55
                                      ? Colors.red
                                      : _currentConfidence < 0.8
                                          ? Colors.amber
                                          : Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isComplete)
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '✓',
                                  style: TextStyle(
                                    fontSize: 64,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Correct!',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Colors.green,
                                      ),
                                ),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 300.ms)
                              .scale(
                                begin: const Offset(0.8, 0.8),
                                duration: 300.ms,
                              ),
                        ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 280.ms),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Session', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text(
                        '$_totalAttempts signed',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('On 1st try', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text(
                        '$_correctOnFirstTry/$_totalAttempts',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _openCollectData,
            icon: const Icon(Icons.dataset_rounded, size: 18),
            label: const Text('Collect Training Data'),
          ),
          const SizedBox(height: 10),
          if (_isComplete)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _nextSign,
                    child: const Text('Next'),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _markComplete,
                    child: const Text('Skip'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
