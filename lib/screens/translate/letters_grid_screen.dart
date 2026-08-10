import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/app_navigation.dart';
import '../../domain/sign_vocab.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_background.dart';
import 'sign_detail_screen.dart';

const _kLetters = [
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
  'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
];

class LettersGridScreen extends StatelessWidget {
  const LettersGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Letters'),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: GridView.builder(
              itemCount: _kLetters.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final letter = _kLetters[index];
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    AppNavigation.fadeTransition(
                      SignDetailScreen(
                        title: letter,
                        assetPath: letterAsset(letter),
                      ),
                    ),
                  ),
                  child: GlassCard(
                    borderRadius: 14,
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: Text(
                        letter,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: (index * 20).ms),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
