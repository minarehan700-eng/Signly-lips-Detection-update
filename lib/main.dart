import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OfflineAslApp());
}

class OfflineAslApp extends StatelessWidget {
  const OfflineAslApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Signly',
      theme: AppTheme.dark(),
      home: const SplashScreen(),
    );
  }
}
