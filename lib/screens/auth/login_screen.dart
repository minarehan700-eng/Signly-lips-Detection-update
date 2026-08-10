import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/app_navigation.dart';
import '../../core/app_storage.dart';
import '../../widgets/app_button.dart';
import '../../widgets/social_auth_row.dart';
import '../home/home_screen.dart';
import 'auth_scaffold.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _storage = AppStorage();
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      await _storage.saveLogin(name: _email.text.split('@').first);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        AppNavigation.fadeTransition(const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not sign in. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Welcome Back',
      subtitle: 'Sign in to continue your offline ASL experience.',
      heroIcon: Icons.lock_rounded,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
            ).animate().fadeIn(delay: 70.ms).slideX(begin: -0.04),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (v) => (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
            ).animate().fadeIn(delay: 120.ms).slideX(begin: 0.04),
            const SizedBox(height: 20),
            AppButton(
              label: _loading ? 'Signing in...' : 'Login',
              icon: Icons.lock_open_rounded,
              onPressed: _loading ? () {} : _login,
            ).animate().fadeIn(delay: 160.ms).slideY(begin: 0.08),
            const SizedBox(height: 14),
            const SocialAuthRow(),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(AppNavigation.fadeTransition(const SignupScreen()));
              },
              child: const Text('No account? Create one'),
            ),
          ],
        ),
      ),
    );
  }
}
