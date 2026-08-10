import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../application/offline_recognition_controller.dart';
import '../../application/prediction_post_processor.dart';
import '../../core/accuracy_tracker.dart';
import '../../infrastructure/camera_frame_encoder.dart';
import '../../infrastructure/mediapipe_hand_landmark_extractor.dart';
import '../../infrastructure/tflite_gesture_classifier.dart';
import '../../application/landmark_quality.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/hand_quality_banner.dart';
import '../../widgets/hand_skeleton_painter.dart';

class RecognitionScreen extends StatefulWidget {
  const RecognitionScreen({super.key, this.active = true});

  final bool active;

  @override
  State<RecognitionScreen> createState() => _RecognitionScreenState();
}

class _RecognitionScreenState extends State<RecognitionScreen> {
  late final OfflineRecognitionController _controller;
  final _encoder = CameraFrameEncoder();
  final _tracker = AccuracyTracker();

  CameraController? _camera;
  bool _initializing = true;
  bool _streaming = false;
  bool _isProcessing = false;
  DateTime _lastProcessed = DateTime.fromMillisecondsSinceEpoch(0);
  String _recognizedText = '';
  String _latestLabel = '-';
  double _confidence = 0;
  String? _error;
  String? _pendingFeedbackLabel;
  bool _showFeedback = false;
  bool _showSkeleton = false;
  bool _showRawPredictions = false;
  bool _setupStarted = false;
  String _initPhase = 'Starting...';
  List<double>? _currentLandmarks;
  String _debugPredictionText = '';
  HandQualityReport _qualityReport = const HandQualityReport(
    isUsable: false,
    hint: HandQualityHint.noHand,
  );

  @override
  void initState() {
    super.initState();
    _controller = OfflineRecognitionController(
      landmarkExtractor: MediaPipeHandLandmarkExtractor(),
      classifier: TfliteGestureClassifier(),
      postProcessor: PredictionPostProcessor(),
    );
    if (widget.active) {
      _scheduleSetup();
    }
  }

  void _scheduleSetup() {
    if (_setupStarted) return;
    _setupStarted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.active) {
        _setupStarted = false;
        return;
      }
      Future<void>.delayed(const Duration(milliseconds: 500), () {
        if (!mounted || !widget.active) {
          _setupStarted = false;
          return;
        }
        unawaited(_setup());
      });
    });
  }

  Future<void> _retrySetup() async {
    _setupStarted = false;
    if (mounted) {
      setState(() {
        _error = null;
        _initializing = true;
        _initPhase = 'Starting...';
      });
    }
    _scheduleSetup();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await _controller.reloadSettings();
    if (!mounted) return;
    setState(() {
      _showRawPredictions = prefs.getBool('show_raw_predictions') ?? false;
    });
  }

  Future<void> _setup() async {
    try {
      if (mounted) {
        setState(() => _initPhase = 'Loading hand tracking model...');
      }
      await _controller.initializeLandmarks();
      if (!mounted || !widget.active) return;

      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted || !widget.active) return;

      if (mounted) {
        setState(() => _initPhase = 'Loading sign classifier...');
      }
      await _controller.initializeClassifier();
      await _controller.postProcessor.loadSettings();
      if (!mounted || !widget.active) return;

      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted || !widget.active) return;

      if (mounted) {
        setState(() => _initPhase = 'Starting camera...');
      }

      final cams = await availableCameras();
      if (!mounted || !widget.active) return;
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

      final controller = CameraController(
        cam,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();
      if (!mounted || !widget.active) {
        await controller.dispose();
        return;
      }
      await controller.startImageStream(_onFrame);
      if (!mounted) return;
      setState(() {
        _camera = controller;
        _streaming = true;
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
      );
      if (!mounted) return;

      final landmarks = _controller.lastLandmarks;
      final rawPrediction = _controller.lastRawPrediction;
      final qualityReport = _controller.qualityReport;
      setState(() {
        _qualityReport = qualityReport;
        if (landmarks != null) {
          _currentLandmarks = landmarks.features42;
        }
        if (_showRawPredictions && rawPrediction != null) {
          final runnerUp = rawPrediction.runnerUpLabel ?? '-';
          final runnerUpScore = rawPrediction.runnerUpConfidence?.toStringAsFixed(2) ?? '-';
          _debugPredictionText =
              '${rawPrediction.label}: ${rawPrediction.confidence.toStringAsFixed(2)} '
              '($runnerUp: $runnerUpScore, margin ${rawPrediction.margin.toStringAsFixed(2)})';
        } else {
          _debugPredictionText = '';
        }
        if (rawPrediction != null) {
          _latestLabel = rawPrediction.label;
          _confidence = rawPrediction.confidence;
        }
        if (prediction != null) {
          if (_pendingFeedbackLabel != prediction.label) {
            _pendingFeedbackLabel = prediction.label;
            _showFeedback = true;
          }
          _recognizedText += prediction.label;
        }
      });
    } finally {
      _isProcessing = false;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence < 0.55) return Colors.red.withValues(alpha: 0.2);
    if (confidence < 0.8) return Colors.amber.withValues(alpha: 0.2);
    return Colors.green.withValues(alpha: 0.2);
  }

  @override
  void didUpdateWidget(covariant RecognitionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) {
      if (widget.active) {
        if (!_setupStarted && _camera == null && _error == null) {
          _scheduleSetup();
        } else {
          unawaited(widget.active ? _resumeCamera() : _pauseCamera());
        }
      } else {
        unawaited(_pauseCamera());
      }
    }
  }

  Future<void> _pauseCamera() async {
    final camera = _camera;
    if (camera == null || !camera.value.isStreamingImages) return;
    try {
      await camera.stopImageStream();
      if (mounted) setState(() => _streaming = false);
    } catch (_) {}
  }

  Future<void> _resumeCamera() async {
    final camera = _camera;
    if (camera == null || camera.value.isStreamingImages) return;
    try {
      await camera.startImageStream(_onFrame);
      if (mounted) setState(() => _streaming = true);
    } catch (_) {}
  }

  @override
  void dispose() {
    unawaited(_camera?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                'Make sure model files exist and camera permission is granted.',
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

    return SafeArea(
      child: Column(
        children: [
          if (_camera != null)
            GlassCard(
              borderRadius: 22,
              padding: const EdgeInsets.all(8),
              child: AspectRatio(
                aspectRatio: _camera!.value.aspectRatio,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
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
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 280.ms).scale(begin: const Offset(0.98, 0.98)),
          if (_qualityReport.hint != HandQualityHint.ready) ...[
            const SizedBox(height: 8),
            HandQualityBanner(report: _qualityReport),
          ],
          if (_showRawPredictions && _debugPredictionText.isNotEmpty) ...[
            const SizedBox(height: 8),
            GlassCard(
              borderRadius: 12,
              padding: const EdgeInsets.all(10),
              child: Text(
                'Raw: $_debugPredictionText',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.cyanAccent,
                    ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _MetricCard(label: 'Latest', value: _latestLabel),
              const SizedBox(width: 8),
              _MetricCard(
                label: 'Confidence',
                value: _confidence.toStringAsFixed(2),
                confidenceColor: _getConfidenceColor(_confidence),
              ),
              const SizedBox(width: 8),
              _MetricCard(label: 'Streaming', value: _streaming ? 'ON' : 'OFF'),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GlassCard(
              borderRadius: 16,
              padding: const EdgeInsets.all(14),
              child: SingleChildScrollView(
                child: Text(
                  _recognizedText.isEmpty ? 'Start signing...' : _recognizedText,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ).animate().fadeIn(delay: 90.ms),
          ),
          const SizedBox(height: 10),
          if (_showFeedback && _pendingFeedbackLabel != null)
            _FeedbackRow(
              label: _pendingFeedbackLabel!,
              onCorrect: () async {
                await _tracker.record(_pendingFeedbackLabel!, true);
                setState(() => _showFeedback = false);
              },
              onIncorrect: () async {
                await _tracker.record(_pendingFeedbackLabel!, false);
                setState(() => _showFeedback = false);
              },
            )
          else
            const SizedBox(height: 44),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _controller.postProcessor.reset();
                    setState(() => _recognizedText = '');
                  },
                  icon: const Icon(Icons.backspace_outlined),
                  label: const Text('Clear'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    this.confidenceColor,
  });

  final String label;
  final String value;
  final Color? confidenceColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: confidenceColor ?? Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}

class _FeedbackRow extends StatelessWidget {
  const _FeedbackRow({
    required this.label,
    required this.onCorrect,
    required this.onIncorrect,
  });

  final String label;
  final VoidCallback onCorrect;
  final VoidCallback onIncorrect;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 12,
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Was "$label" correct?',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: onCorrect,
            icon: const Icon(Icons.thumb_up_rounded),
            iconSize: 18,
          ),
          const SizedBox(width: 6),
          IconButton.filled(
            onPressed: onIncorrect,
            icon: const Icon(Icons.thumb_down_rounded),
            iconSize: 18,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}
