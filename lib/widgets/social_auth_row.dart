import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SocialAuthRow extends StatelessWidget {
  const SocialAuthRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: Colors.white24)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'or continue with',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
            ),
            const Expanded(child: Divider(color: Colors.white24)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(child: _SocialButton(icon: Icons.g_mobiledata_rounded, label: 'Google')),
            SizedBox(width: 10),
            Expanded(child: _SocialButton(icon: Icons.apple_rounded, label: 'Apple')),
            SizedBox(width: 10),
            Expanded(child: _SocialButton(icon: Icons.facebook_rounded, label: 'Facebook')),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 180.ms);
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(42),
        side: const BorderSide(color: Colors.white24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
