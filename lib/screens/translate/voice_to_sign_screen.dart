import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../core/app_theme.dart';
import '../../widgets/gradient_background.dart';
import 'sign_translation_mixin.dart';

class VoiceToSignScreen extends StatefulWidget {
  const VoiceToSignScreen({super.key});

  @override
  State<VoiceToSignScreen> createState() => _VoiceToSignScreenState();
}

class _VoiceToSignScreenState extends State<VoiceToSignScreen>
    with SignTranslationMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _loadText = false;
  String _recognizedText = '';
  static const _hint = 'Press the button and start speaking...';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Voice to Sign'),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: _loadText
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.brandTeal),
                )
              : RefreshIndicator(
                  onRefresh: onRefreshSignDisplay,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 100),
                    child: buildSignPanel(hintText: _hint),
                  ),
                ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: AppTheme.brandTeal,
        duration: const Duration(milliseconds: 2000),
        repeat: true,
        child: FloatingActionButton(
          onPressed: _listen,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none_rounded),
        ),
      ),
    );
  }

  Future<void> _listen() async {
    if (!_isListening) {
      final available = await _speech.initialize(
        onStatus: (_) {},
        onError: (_) {},
      );
      if (!available || !mounted) return;

      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() => _recognizedText = result.recognizedWords);
          }
        },
      );
    } else {
      setState(() => _loadText = true);
      await Future<void>.delayed(const Duration(seconds: 3));
      if (!mounted) return;

      setState(() {
        _loadText = false;
        _isListening = false;
      });
      await _speech.stop();

      final text = _recognizedText;
      _recognizedText = '';
      await runTranslation(text);
    }
  }
}
