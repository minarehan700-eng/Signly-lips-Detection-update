import 'package:flutter/material.dart';

import '../../application/sign_translation_engine.dart';
import '../../widgets/sign_display_panel.dart';

mixin SignTranslationMixin<T extends StatefulWidget> on State<T> {
  final SignTranslationEngine _engine = SignTranslationEngine();
  SignDisplayState _display = initialSignDisplayState();
  bool _isTranslating = false;

  bool get isTranslating => _isTranslating;

  void resetDisplay() {
    _engine.cancel();
    setState(() {
      _display = initialSignDisplayState();
      _isTranslating = false;
    });
  }

  Future<void> onRefreshSignDisplay() {
    return Future<void>.delayed(const Duration(seconds: 1), resetDisplay);
  }

  Widget buildSignPanel({required String hintText}) {
    return SignDisplayPanel(
      assetPath: _display.assetPath,
      displayText: _display.displayText,
      switchKey: _display.switchKey,
      hintText: hintText,
    );
  }

  Future<void> runTranslation(String text) async {
    if (text.trim().isEmpty || !mounted) return;

    _engine.cancel();
    setState(() {
      _isTranslating = true;
      _display = _display.copyWith(displayText: '');
    });

    var caption = '';
    await _engine.translate(
      text,
      onFrame: (frame) {
        if (!mounted) return;
        setState(() {
          caption += frame.caption;
          _display = _display.copyWith(
            assetPath: frame.assetPath,
            displayText: caption,
            switchKey: _display.switchKey + 1,
          );
        });
      },
    );

    if (mounted) {
      setState(() => _isTranslating = false);
    }
  }

  @override
  void dispose() {
    _engine.cancel();
    super.dispose();
  }
}
