import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/app_navigation.dart';
import '../../domain/sign_info.dart';
import '../../widgets/glass_card.dart';
import 'practice_screen.dart';

class DictionaryScreen extends StatelessWidget {
  const DictionaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final letters = kSignInfoMap.values.where((s) => !s.isPhrase).toList();
    final phrases = kSignInfoMap.values.where((s) => s.isPhrase).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'ASL Dictionary',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (phrases.isNotEmpty) ...[
                  Text(
                    'Common Phrases',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.cyan,
                        ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: phrases.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _SignCard(sign: phrases[index])
                              .animate()
                              .fadeIn(delay: (index * 30).ms),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Text(
                  'Letters & Numbers',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.cyan,
                      ),
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: letters.length,
                  itemBuilder: (context, index) {
                    final sign = letters[index];
                    return _SignCard(sign: sign)
                        .animate()
                        .fadeIn(delay: (index * 20).ms);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SignCard extends StatelessWidget {
  const _SignCard({required this.sign});

  final SignInfo sign;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetailSheet(context, sign),
      child: GlassCard(
        borderRadius: 14,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              sign.label,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              sign.label == ' ' ? 'Space' : sign.label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailSheet(BuildContext context, SignInfo sign) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: sign.videoUrl != null ? 0.85 : 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, controller) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0C1022),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white24),
          ),
          child: ListView(
            controller: controller,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        sign.label == ' ' ? 'Space' : sign.label,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (sign.videoUrl != null) ...[
                      Text(
                        'Video Demonstration',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black,
                        ),
                        child: WebViewWidget(
                          controller: WebViewController()
                            ..setJavaScriptMode(JavaScriptMode.unrestricted)
                            ..loadRequest(
                              Uri.parse(
                                sign.videoUrl!.replaceFirst(
                                  'youtube.com/embed/',
                                  'youtube.com/embed/',
                                ),
                              ),
                            ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    Text(
                      'How to form:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sign.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tips:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...sign.tips.map(
                      (tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 16)),
                            Expanded(
                              child: Text(tip, style: Theme.of(context).textTheme.bodySmall),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (sign.label != ' ' && !sign.isPhrase)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              AppNavigation.fadeTransition(
                                PracticeScreen(target: sign.label),
                              ),
                            );
                          },
                          icon: const Icon(Icons.fitness_center_rounded),
                          label: const Text('Practice this sign'),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
