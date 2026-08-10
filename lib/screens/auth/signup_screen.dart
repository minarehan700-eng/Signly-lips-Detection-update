import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/app_navigation.dart';
import '../../core/app_storage.dart';
import '../../widgets/app_button.dart';
import '../../widgets/social_auth_row.dart';
import '../home/home_screen.dart';
import 'auth_scaffold.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _storage = AppStorage();
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      await _storage.saveLogin(name: _name.text.trim());
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        AppNavigation.fadeTransition(const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create account. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create Account',
      subtitle: 'Join and start recognizing signs on-device.',
      heroIcon: Icons.person_add_alt_1_rounded,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ).animate().fadeIn(delay: 50.ms).slideX(begin: -0.04),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
            ).animate().fadeIn(delay: 95.ms).slideX(begin: 0.04),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (v) => (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
            ).animate().fadeIn(delay: 130.ms).slideX(begin: -0.04),
            const SizedBox(height: 20),
            AppButton(
              label: _loading ? 'Creating account...' : 'Sign Up',
              icon: Icons.person_add_alt_1_rounded,
              onPressed: _loading ? () {} : _signup,
            ).animate().fadeIn(delay: 165.ms).slideY(begin: 0.08),
            const SizedBox(height: 14),
            const SocialAuthRow(),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
