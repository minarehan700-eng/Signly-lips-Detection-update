import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../application/landmark_quality.dart';
import '../../application/prediction_post_processor.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _confidenceThreshold = PredictionPostProcessor.defaultConfidenceThreshold;
  int _windowSize = PredictionPostProcessor.defaultWindowSize;
  double _minMargin = PredictionPostProcessor.defaultMinMargin;
  bool _showRawPredictions = false;
  bool _holdSteadyEnabled = true;
  bool _adaptiveThresholdEnabled = true;
  bool _confusionPenaltyEnabled = true;
  double _maxVelocity = LandmarkQuality.defaultMaxVelocity;
  double _softmaxTemperature = 0.85;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _confidenceThreshold =
          prefs.getDouble('confidence_threshold') ??
              PredictionPostProcessor.defaultConfidenceThreshold;
      _windowSize =
          prefs.getInt('window_size') ?? PredictionPostProcessor.defaultWindowSize;
      _minMargin =
          prefs.getDouble('min_margin') ?? PredictionPostProcessor.defaultMinMargin;
      _showRawPredictions = prefs.getBool('show_raw_predictions') ?? false;
      _holdSteadyEnabled = prefs.getBool('hold_steady_enabled') ?? true;
      _adaptiveThresholdEnabled =
          prefs.getBool('adaptive_threshold_enabled') ?? true;
      _confusionPenaltyEnabled =
          prefs.getBool('confusion_penalty_enabled') ?? true;
      _maxVelocity =
          prefs.getDouble('max_landmark_velocity') ?? LandmarkQuality.defaultMaxVelocity;
      _softmaxTemperature = prefs.getDouble('softmax_temperature') ?? 0.85;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('confidence_threshold', _confidenceThreshold);
    await prefs.setInt('window_size', _windowSize);
    await prefs.setDouble('min_margin', _minMargin);
    await prefs.setBool('show_raw_predictions', _showRawPredictions);
    await prefs.setBool('hold_steady_enabled', _holdSteadyEnabled);
    await prefs.setBool('adaptive_threshold_enabled', _adaptiveThresholdEnabled);
    await prefs.setBool('confusion_penalty_enabled', _confusionPenaltyEnabled);
    await prefs.setDouble('max_landmark_velocity', _maxVelocity);
    await prefs.setDouble('softmax_temperature', _softmaxTemperature);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Recognition Settings',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                GlassCard(
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Confidence Threshold',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      _confidenceThreshold.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.cyan,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Slider(
                  value: _confidenceThreshold,
                  min: 0.3,
                  max: 0.95,
                  divisions: 13,
                  onChanged: (v) => setState(() => _confidenceThreshold = v),
                ),
                const SizedBox(height: 8),
                Text(
                  '⚠️ Lower = more lenient (0.3-0.5 for learning, 0.6-0.8 for accuracy)',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.amber,
                      ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Stability Window Size',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      '$_windowSize frames',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.cyan,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Slider(
                  value: _windowSize.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: (v) => setState(() => _windowSize = v.toInt()),
                ),
                const SizedBox(height: 8),
                Text(
                  '⚠️ Smaller = faster response (1-3 frames), Larger = more stable (5-10 frames)',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.amber,
                      ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Prediction Margin',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      _minMargin.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.cyan,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Slider(
                  value: _minMargin,
                  min: 0.05,
                  max: 0.35,
                  divisions: 6,
                  onChanged: (v) => setState(() => _minMargin = v),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rejects confused predictions when top-2 guesses are too close',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.amber,
                      ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Debug Mode: Show Raw Predictions',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Switch(
                      value: _showRawPredictions,
                      onChanged: (v) => setState(() => _showRawPredictions = v),
                    ),
                  ],
                ),
                Text(
                  'Shows top 3 model predictions without filtering',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Hold Steady Gate',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Switch(
                      value: _holdSteadyEnabled,
                      onChanged: (v) => setState(() => _holdSteadyEnabled = v),
                    ),
                  ],
                ),
                Text(
                  'Rejects frames while the hand is moving too fast',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                if (_holdSteadyEnabled) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Max Hand Motion',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        _maxVelocity.toStringAsFixed(3),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.cyan,
                            ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _maxVelocity,
                    min: 0.012,
                    max: 0.05,
                    divisions: 19,
                    onChanged: (v) => setState(() => _maxVelocity = v),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Adaptive Threshold',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Switch(
                      value: _adaptiveThresholdEnabled,
                      onChanged: (v) =>
                          setState(() => _adaptiveThresholdEnabled = v),
                    ),
                  ],
                ),
                Text(
                  'Raises confidence bar when predictions are unstable',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Confusion-Aware Voting',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Switch(
                      value: _confusionPenaltyEnabled,
                      onChanged: (v) =>
                          setState(() => _confusionPenaltyEnabled = v),
                    ),
                  ],
                ),
                Text(
                  'Penalizes commonly confused pairs (A/S, M/N, 6/9, etc.)',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Softmax Temperature',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      _softmaxTemperature.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.cyan,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Slider(
                  value: _softmaxTemperature,
                  min: 0.7,
                  max: 1.2,
                  divisions: 10,
                  onChanged: (v) => setState(() => _softmaxTemperature = v),
                ),
                Text(
                  'Lower sharpens winner vs runner-up (0.85 recommended)',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.amber,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Tuning Presets',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _PresetButton(
                  label: 'Beginner (Lenient)',
                  description: 'Easy to recognize, fast feedback',
                  onTap: () => setState(() {
                    _confidenceThreshold = 0.45;
                    _windowSize = 2;
                    _minMargin = 0.08;
                  }),
                ),
                const SizedBox(height: 8),
                _PresetButton(
                  label: 'Balanced (Recommended)',
                  description: 'Good mix of speed and accuracy',
                  onTap: () => setState(() {
                    _confidenceThreshold = 0.58;
                    _windowSize = 4;
                    _minMargin = 0.14;
                    _holdSteadyEnabled = true;
                    _adaptiveThresholdEnabled = true;
                    _confusionPenaltyEnabled = true;
                    _maxVelocity = 0.028;
                    _softmaxTemperature = 0.85;
                  }),
                ),
                const SizedBox(height: 8),
                _PresetButton(
                  label: 'Letter Practice',
                  description: 'Responsive A–Z practice with relaxed hold-steady',
                  onTap: () => setState(() {
                    _confidenceThreshold = 0.50;
                    _windowSize = 3;
                    _minMargin = 0.10;
                    _holdSteadyEnabled = true;
                    _adaptiveThresholdEnabled = true;
                    _confusionPenaltyEnabled = true;
                    _maxVelocity = 0.035;
                    _softmaxTemperature = 0.85;
                  }),
                ),
                const SizedBox(height: 8),
                _PresetButton(
                  label: 'Expert (Strict)',
                  description: 'Only recognize high-confidence matches',
                  onTap: () => setState(() {
                    _confidenceThreshold = 0.75;
                    _windowSize = 5;
                    _minMargin = 0.18;
                    _holdSteadyEnabled = true;
                    _adaptiveThresholdEnabled = true;
                    _confusionPenaltyEnabled = true;
                    _maxVelocity = 0.02;
                    _softmaxTemperature = 0.8;
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save Settings'),
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Troubleshooting Tips',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _TipWidget(
                  icon: Icons.lightbulb_rounded,
                  title: 'Signs not recognized?',
                  description: 'Lower confidence threshold or reduce window size',
                ),
                const SizedBox(height: 10),
                _TipWidget(
                  icon: Icons.photo_camera_rounded,
                  title: 'Wrong signs detected?',
                  description: 'Ensure good lighting and clear hand visibility',
                ),
                const SizedBox(height: 10),
                _TipWidget(
                  icon: Icons.speed_rounded,
                  title: 'Too slow to respond?',
                  description: 'Reduce window size for faster recognition',
                ),
                const SizedBox(height: 10),
                _TipWidget(
                  icon: Icons.check_circle_rounded,
                  title: 'Too many false positives?',
                  description: 'Increase confidence threshold or window size',
                ),
              ],
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

class _PresetButton extends StatelessWidget {
  const _PresetButton({
    required this.label,
    required this.description,
    required this.onTap,
  });

  final String label;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _TipWidget extends StatelessWidget {
  const _TipWidget({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.cyan),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelMedium),
              Text(
                description,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
