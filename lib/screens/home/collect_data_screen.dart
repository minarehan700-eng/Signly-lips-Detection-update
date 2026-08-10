import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../application/landmark_quality.dart';
import '../../application/offline_recognition_controller.dart';
import '../../application/prediction_post_processor.dart';
import '../../application/training_sample_store.dart';
import '../../domain/sign_vocab.dart';
import '../../infrastructure/camera_frame_encoder.dart';
import '../../infrastructure/mediapipe_hand_landmark_extractor.dart';
import '../../infrastructure/tflite_gesture_classifier.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/hand_quality_banner.dart';

class CollectDataScreen extends StatefulWidget {
  const CollectDataScreen({super.key});

  @override
  State<CollectDataScreen> createState() => _CollectDataScreenState();
}

class _CollectDataScreenState extends State<CollectDataScreen> {
  static const _priorityLabels = ['A', 'B', 'C', 'S', '4', 'O'];
  static const _collectionMinHandScore = 0.40;

  final _controller = OfflineRecognitionController(
    landmarkExtractor: MediaPipeHandLandmarkExtractor(),
    classifier: TfliteGestureClassifier(),
    postProcessor: PredictionPostProcessor(),
  );
  final _encoder = CameraFrameEncoder();
  final _store = TrainingSampleStore();

  CameraController? _camera;
  bool _initializing = true;
  String? _error;
  bool _isProcessing = false;
  DateTime _lastProcessed = DateTime.fromMillisecondsSinceEpoch(0);

  String _selectedLabel = 'A';
  HandQualityReport _qualityReport = const HandQualityReport(
    isUsable: false,
    hint: HandQualityHint.noHand,
  );
  Map<String, int> _counts = {};
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    try {
      await _controller.initialize();
      await _refreshCounts();
      final cams = await availableCameras();
      final cam = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cams.first,
      );

      final camera = CameraController(
        cam,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await camera.initialize();
      await camera.startImageStream(_onFrame);
      if (!mounted) return;
      setState(() {
        _camera = camera;
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

  Future<void> _refreshCounts() async {
    final counts = await _store.countByLabel();
    if (!mounted) return;
    setState(() => _counts = counts);
  }

  HandQualityReport _assessForCollection() {
    final landmarks = _controller.lastLandmarks;
    if (landmarks == null) {
      return const HandQualityReport(
        isUsable: false,
        hint: HandQualityHint.noHand,
      );
    }
    return LandmarkQuality.assess(
      features42: landmarks.features42,
      handScore: landmarks.handScore,
      span: landmarks.span,
      holdSteadyEnabled: false,
      minHandScoreThreshold: _collectionMinHandScore,
    );
  }

  Future<void> _onFrame(CameraImage image) async {
    if (_isProcessing) return;
    final now = DateTime.now();
    if (now.difference(_lastProcessed).inMilliseconds < 90) return;
    _lastProcessed = now;
    _isProcessing = true;

    try {
      final jpeg = await _encoder.encodeToJpeg(image);
      if (jpeg == null) return;
      await _controller.onFrame(
        bytes: jpeg,
        width: image.width,
        height: image.height,
        rotation: 0,
      );
      if (!mounted) return;
      setState(() => _qualityReport = _assessForCollection());
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _capture() async {
    if (_capturing || !_qualityReport.isUsable) return;
    final landmarks = _controller.lastLandmarks;
    if (landmarks == null) return;

    setState(() => _capturing = true);
    try {
      await _store.addSample(
        TrainingSample(
          label: _selectedLabel,
          features42: List<double>.from(landmarks.features42),
          handScore: landmarks.handScore,
          span: landmarks.span,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      await _refreshCounts();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Captured ${_labelDisplay(_selectedLabel)} sample')),
      );
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _export() async {
    final path = await _store.exportJson();
    if (!mounted) return;
    await Clipboard.setData(ClipboardData(text: path));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exported to $path (path copied)'),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all samples?'),
        content: const Text('This removes all captured training samples.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _store.clearAll();
    await _refreshCounts();
  }

  void _selectLabel(String label) => setState(() => _selectedLabel = label);

  static String _labelDisplay(String label) =>
      label == kClassifierSpaceLabel ? 'Space' : label;

  @override
  void dispose() {
    unawaited(_camera?.dispose());
    super.dispose();
  }

  Widget _buildLabelGrid(String title, List<String> labels) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: labels.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1.4,
          ),
          itemBuilder: (context, index) {
            final label = labels[index];
            final selected = _selectedLabel == label;
            return FilterChip(
              label: Text(
                _labelDisplay(label),
                style: TextStyle(
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) => _selectLabel(label),
            );
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildCaptureStatus() {
    final theme = Theme.of(context);
    if (_capturing) {
      return Text(
        'Saving...',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
        ),
      );
    }
    if (_qualityReport.isUsable) {
      return Text(
        'Ready — tap Capture',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: Colors.green.shade700,
          fontWeight: FontWeight.w500,
        ),
      );
    }
    return Text(
      'Capture disabled: ${_qualityReport.message}',
      style: theme.textTheme.bodyMedium?.copyWith(
        color: Colors.amber.shade800,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Collect Training Data')),
      body: _initializing
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Capture features42 + label when hand quality is good. '
                          'Export writes training_samples.json for adb pull.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        GlassCard(
                          borderRadius: 16,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Target label', style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 8),
                              Center(
                                child: Text(
                                  _labelDisplay(_selectedLabel),
                                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Quick pick',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _priorityLabels.map((label) {
                                  final selected = _selectedLabel == label;
                                  return ChoiceChip(
                                    label: Text(label),
                                    selected: selected,
                                    onSelected: (_) => _selectLabel(label),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 12),
                              _buildLabelGrid('Letters', kClassifierLetterLabels),
                              _buildLabelGrid('Numbers', kClassifierNumberLabels),
                              _buildLabelGrid('Space', const [kClassifierSpaceLabel]),
                              Text(
                                'Saved for ${_labelDisplay(_selectedLabel)}: ${_counts[_selectedLabel] ?? 0}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              if (_counts.isNotEmpty)
                                Text(
                                  'Total samples: ${_counts.values.fold<int>(0, (a, b) => a + b)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
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
                                    if (_qualityReport.hint != HandQualityHint.ready)
                                      Positioned(
                                        top: 12,
                                        left: 12,
                                        right: 12,
                                        child: HandQualityBanner(report: _qualityReport),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _qualityReport.isUsable && !_capturing ? _capture : null,
                                icon: const Icon(Icons.camera_rounded),
                                label: Text(_capturing ? 'Saving...' : 'Capture'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _buildCaptureStatus(),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _export,
                                icon: const Icon(Icons.upload_file_rounded),
                                label: const Text('Export JSON'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _clearAll,
                                icon: const Icon(Icons.delete_outline_rounded),
                                label: const Text('Clear'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
