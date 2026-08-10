import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_navigation.dart';
import '../core/app_storage.dart';
import '../widgets/animated_brand_text.dart';
import '../widgets/geometric_wave_shapes.dart';
import '../widgets/gradient_background.dart';
import '../widgets/sign_motion_background.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _storage = AppStorage();
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    _splashTimer = Timer(const Duration(milliseconds: 2600), _routeNext);
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  Future<void> _routeNext() async {
    final seen = await _storage.isOnboardingSeen();
    final loggedIn = await _storage.isLoggedIn();
    if (!mounted) return;

    final Widget next;
    if (!seen) {
      next = const OnboardingScreen();
    } else if (loggedIn) {
      next = const HomeScreen();
    } else {
      next = const LoginScreen();
    }

    Navigator.of(context).pushReplacement(
      AppNavigation.fadeTransition(next),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const GeometricWaveShapes(),
            const SignMotionBackground(),
            Center(
              child: _AnimatedLogoMark(),
            ),
            Positioned(
              bottom: 52,
              left: 0,
              right: 0,
              child: Text(
                'Translate signs instantly',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedLogoMark extends StatefulWidget {
  @override
  State<_AnimatedLogoMark> createState() => _AnimatedLogoMarkState();
}

class _AnimatedLogoMarkState extends State<_AnimatedLogoMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final angle = _controller.value * math.pi * 2;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: angle,
                  child: Container(
                    width: 148,
                    height: 148,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 1.2),
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: -angle * 0.7,
                  child: Container(
                    width: 118,
                    height: 118,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30, width: 1.1),
                    ),
                  ),
                ),
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5E7BFF), Color(0xFF9D56FF)],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x805A7CFF),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.sign_language_rounded, color: Colors.white, size: 48),
                ),
              ],
            ).animate().fadeIn(duration: 420.ms).scale(curve: Curves.easeOutBack),
            const SizedBox(height: 22),
            const AnimatedBrandText().animate().fadeIn(delay: 280.ms),
          ],
        );
      },
    );
  }
}
