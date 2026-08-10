import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_navigation.dart';
import '../core/app_storage.dart';
import '../widgets/app_button.dart';
import '../widgets/gradient_background.dart';
import '../widgets/sign_motion_background.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

class _OnboardingItem {
  const _OnboardingItem(this.title, this.subtitle, this.icon);
  final String title;
  final String subtitle;
  final IconData icon;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _storage = AppStorage();
  final _pageController = PageController();
  final _items = const [
    _OnboardingItem(
      'Real-time Gesture Recognition',
      'Capture signs from your camera with low-latency on-device AI.',
      Icons.bolt_rounded,
    ),
    _OnboardingItem(
      'Works Fully Offline',
      'No internet required for live recognition once models are bundled.',
      Icons.wifi_off_rounded,
    ),
    _OnboardingItem(
      'Premium Translation UX',
      'Smooth predictions with confidence scores and debounced text stream.',
      Icons.auto_awesome_rounded,
    ),
  ];
  int _index = 0;

  Future<void> _finish() async {
    await _storage.setOnboardingSeen();
    final loggedIn = await _storage.isLoggedIn();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      AppNavigation.fadeTransition(loggedIn ? const HomeScreen() : const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const SignMotionBackground(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _finish,
                        child: const Text('Skip'),
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _items.length,
                        onPageChanged: (v) => setState(() => _index = v),
                        itemBuilder: (_, i) {
                          final item = _items[i];
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.08),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Icon(item.icon, size: 62, color: Colors.white),
                              ).animate().scale(delay: 120.ms).shimmer(duration: 900.ms),
                              const SizedBox(height: 26),
                              Text(
                                item.title,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                item.subtitle,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.white70,
                                    ),
                              ),
                            ],
                          ).animate().fadeIn(duration: 260.ms).slideY(begin: 0.03);
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _items.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: i == _index ? Colors.white : Colors.white30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    AppButton(
                      label: _index == _items.length - 1 ? 'Start Now' : 'Continue',
                      onPressed: () {
                        if (_index == _items.length - 1) {
                          _finish();
                          return;
                        }
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOut,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
