import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../domain/sign_vocab.dart';
import 'glass_card.dart';

class SignDisplayPanel extends StatelessWidget {
  const SignDisplayPanel({
    required this.assetPath,
    required this.displayText,
    required this.switchKey,
    this.hintText = 'Enter text or speak to see signs...',
    super.key,
  });

  final String assetPath;
  final String displayText;
  final int switchKey;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final imageHeight = (4 / 3) * width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          borderRadius: 20,
          padding: EdgeInsets.zero,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: ClipRRect(
              key: ValueKey<int>(switchKey),
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                alignment: Alignment.center,
                width: width,
                height: imageHeight,
                errorBuilder: (_, __, ___) => SizedBox(
                  width: width,
                  height: imageHeight,
                  child: const Center(child: Icon(Icons.image_not_supported_outlined)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.brandTeal.withValues(alpha: 0.2),
                AppTheme.brandTeal,
                AppTheme.brandTeal.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Text(
              displayText.isEmpty ? hintText : displayText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: displayText.isEmpty ? Colors.white54 : Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.brandTeal.withValues(alpha: 0.2),
                AppTheme.brandTeal,
                AppTheme.brandTeal.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }
}

/// Initial state for sign display panels.
SignDisplayState initialSignDisplayState() => SignDisplayState(
      assetPath: spaceAsset(),
      displayText: '',
      switchKey: 0,
    );

class SignDisplayState {
  const SignDisplayState({
    required this.assetPath,
    required this.displayText,
    required this.switchKey,
  });

  final String assetPath;
  final String displayText;
  final int switchKey;

  SignDisplayState copyWith({
    String? assetPath,
    String? displayText,
    int? switchKey,
  }) {
    return SignDisplayState(
      assetPath: assetPath ?? this.assetPath,
      displayText: displayText ?? this.displayText,
      switchKey: switchKey ?? this.switchKey,
    );
  }
}
