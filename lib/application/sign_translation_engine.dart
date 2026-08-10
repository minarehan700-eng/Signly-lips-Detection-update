import 'dart:async';

import '../domain/sign_vocab.dart';

class SignFrame {
  const SignFrame({
    required this.assetPath,
    required this.caption,
    required this.isGif,
    required this.durationMs,
  });

  final String assetPath;
  final String caption;
  final bool isGif;
  final int durationMs;
}

class SignTranslationEngine {
  int _generation = 0;

  void cancel() {
    _generation++;
  }

  /// Plays sign frames sequentially, calling [onFrame] for each step.
  /// Returns when complete or when cancelled via [cancel].
  Future<void> translate(
    String text, {
    required void Function(SignFrame frame) onFrame,
  }) async {
    final gen = ++_generation;
    final speechStr = text.toLowerCase().trim();
    if (speechStr.isEmpty) return;

    final words = speechStr.split(' ');
    for (final content in words) {
      if (gen != _generation) return;

      if (kKnownWords.containsKey(content)) {
        await _emit(
          gen: gen,
          onFrame: onFrame,
          assetPath: wordGifAsset(content),
          caption: content,
          isGif: true,
          durationMs: kKnownWords[content]!,
        );
      } else {
        final alias = resolveWordAlias(content);
        if (alias != null) {
          await _emit(
            gen: gen,
            onFrame: onFrame,
            assetPath: wordGifAsset(alias),
            caption: content,
            isGif: true,
            durationMs: kKnownWords[alias]!,
          );
        } else {
          for (var i = 0; i < content.length; i++) {
            if (gen != _generation) return;
            final char = content[i];
            if (isKnownLetter(char)) {
              await _emit(
                gen: gen,
                onFrame: onFrame,
                assetPath: letterAsset(char),
                caption: char,
                isGif: false,
                durationMs: kLetterDisplayDurationMs,
              );
            } else {
              await _emit(
                gen: gen,
                onFrame: onFrame,
                assetPath: spaceAsset(),
                caption: char,
                isGif: false,
                durationMs: kUnknownCharDisplayDurationMs,
              );
            }
          }
        }
      }

      if (gen != _generation) return;
      await _emit(
        gen: gen,
        onFrame: onFrame,
        assetPath: spaceAsset(),
        caption: ' ',
        isGif: false,
        durationMs: kSpaceDisplayDurationMs,
      );
    }
  }

  Future<void> _emit({
    required int gen,
    required void Function(SignFrame frame) onFrame,
    required String assetPath,
    required String caption,
    required bool isGif,
    required int durationMs,
  }) async {
    if (gen != _generation) return;
    onFrame(SignFrame(
      assetPath: assetPath,
      caption: caption,
      isGif: isGif,
      durationMs: durationMs,
    ));
    await Future<void>.delayed(Duration(milliseconds: durationMs));
  }
}
