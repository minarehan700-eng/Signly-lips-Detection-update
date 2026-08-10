import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/app_navigation.dart';
import '../../domain/sign_vocab.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_background.dart';
import 'sign_detail_screen.dart';

const _kNumbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

class NumbersGridScreen extends StatelessWidget {
  const NumbersGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Numbers'),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: GridView.builder(
              itemCount: _kNumbers.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final number = _kNumbers[index];
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    AppNavigation.fadeTransition(
                      SignDetailScreen(
                        title: number,
                        assetPath: letterAsset(number),
                      ),
                    ),
                  ),
                  child: GlassCard(
                    borderRadius: 14,
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: Text(
                        number,
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
