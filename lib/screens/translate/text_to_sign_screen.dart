import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_background.dart';
import 'sign_translation_mixin.dart';

class TextToSignScreen extends StatefulWidget {
  const TextToSignScreen({super.key});

  @override
  State<TextToSignScreen> createState() => _TextToSignScreenState();
}

class _TextToSignScreenState extends State<TextToSignScreen>
    with SignTranslationMixin {
  final _controller = TextEditingController();
  static const _hint = 'Press the button and start writing...';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Text to Sign'),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: RefreshIndicator(
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
        animate: isTranslating,
        glowColor: AppTheme.brandTeal,
        duration: const Duration(milliseconds: 2000),
        repeat: true,
        child: FloatingActionButton(
          onPressed: _showTextInput,
          child: const Icon(Icons.edit_rounded),
        ),
      ),
    );
  }

  void _showTextInput() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Enter text',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Type something to translate...',
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    final text = _controller.text;
                    _controller.clear();
                    Navigator.pop(context);
                    runTranslation(text);
                  },
                  child: const Text('Show Result'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
