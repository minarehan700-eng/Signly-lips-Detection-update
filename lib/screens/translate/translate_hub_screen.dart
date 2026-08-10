import 'package:flutter/material.dart';

import '../../core/app_navigation.dart';
import '../../widgets/translate_hub_card.dart';
import 'letters_and_numbers_screen.dart';
import 'lips_detection_screen.dart';
import 'text_to_sign_screen.dart';
import 'voice_to_sign_screen.dart';

class TranslateHubScreen extends StatelessWidget {
  const TranslateHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Translate',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Convert text or voice into sign language animations.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 20),
          TranslateHubCard(
            title: 'Text to Sign Language',
            subtitle: 'Type words and watch the signs play',
            icon: Icons.text_fields_rounded,
            imageAsset: 'assets/sign_language/icons/TextToTranslate.png',
            onTap: () => Navigator.of(context).push(
              AppNavigation.fadeTransition(const TextToSignScreen()),
            ),
          ),
          const SizedBox(height: 12),
          TranslateHubCard(
            title: 'Voice to Sign Language',
            subtitle: 'Speak and see signs in real time',
            icon: Icons.mic_rounded,
            imageAsset: 'assets/sign_language/icons/VoiceToTranslate.png',
            delayMs: 80,
            onTap: () => Navigator.of(context).push(
              AppNavigation.fadeTransition(const VoiceToSignScreen()),
            ),
          ),
          const SizedBox(height: 12),
          TranslateHubCard(
            title: 'Show Letters & Numbers',
            subtitle: 'Browse ASL alphabet and digits',
            icon: Icons.grid_view_rounded,
            imageAsset: 'assets/sign_language/icons/dictionary.png',
            delayMs: 160,
            onTap: () => Navigator.of(context).push(
              AppNavigation.fadeTransition(const LettersAndNumbersScreen()),
            ),
          ),
          const SizedBox(height: 12),
          TranslateHubCard(
            title: 'Lips Detection',
            subtitle: 'Open camera and detect lip movement',
            icon: Icons.face_retouching_natural,
            delayMs: 240,
            onTap: () => Navigator.of(context).push(
              AppNavigation.fadeTransition(const LipsDetectionScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
