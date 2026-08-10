import 'package:flutter/material.dart';

import '../../core/app_navigation.dart';
import '../../widgets/app_button.dart';
import '../../widgets/gradient_background.dart';
import 'letters_grid_screen.dart';
import 'numbers_grid_screen.dart';

class LettersAndNumbersScreen extends StatelessWidget {
  const LettersAndNumbersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Letters & Numbers'),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.back_hand_rounded,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Show Letters',
                  icon: Icons.abc_rounded,
                  onPressed: () => Navigator.of(context).push(
                    AppNavigation.fadeTransition(const LettersGridScreen()),
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Show Numbers',
                  icon: Icons.pin_rounded,
                  onPressed: () => Navigator.of(context).push(
                    AppNavigation.fadeTransition(const NumbersGridScreen()),
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
