import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/app_navigation.dart';
import '../../core/app_storage.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_background.dart';
import '../auth/login_screen.dart';
import '../translate/translate_hub_screen.dart';
import 'dictionary_screen.dart';
import 'collect_data_screen.dart';
import 'recognition_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = AppStorage();
  int _tab = 1;
  String _userName = 'Guest';
  bool _recognitionMounted = false;
  final Set<int> _visitedTabs = {1};

  @override
  void initState() {
    super.initState();
    _load();
    _scheduleRecognitionMount();
  }

  void _onTabSelected(int index) {
    setState(() {
      _tab = index;
      _visitedTabs.add(index);
    });
    if (index == 0 && !_recognitionMounted) {
      _scheduleRecognitionMount();
    }
  }

  void _scheduleRecognitionMount() {
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted || _tab != 0 || _recognitionMounted) return;
      setState(() => _recognitionMounted = true);
    });
  }

  Future<void> _load() async {
    final n = await _storage.userName();
    if (!mounted) return;
    setState(() => _userName = n);
  }

  Future<void> _logout() async {
    await _storage.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      AppNavigation.fadeTransition(const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Signly'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: IndexedStack(
              index: _tab,
              children: [
                _recognitionMounted
                    ? RecognitionScreen(
                        key: const ValueKey('recognize'),
                        active: _tab == 0,
                      )
                    : const _RecognizeLoadingPlaceholder(),
                _visitedTabs.contains(1)
                    ? const TranslateHubScreen(key: ValueKey('translate'))
                    : const SizedBox.shrink(key: ValueKey('translate')),
                _visitedTabs.contains(2)
                    ? const DictionaryScreen(key: ValueKey('dictionary'))
                    : const SizedBox.shrink(key: ValueKey('dictionary')),
                _visitedTabs.contains(3)
                    ? _ProfileTab(
                        key: const ValueKey('profile'),
                        userName: _userName,
                      )
                    : const SizedBox.shrink(key: ValueKey('profile')),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.videocam_rounded), label: 'Recognize'),
          NavigationDestination(icon: Icon(Icons.translate_rounded), label: 'Translate'),
          NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: 'Dictionary'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class _RecognizeLoadingPlaceholder extends StatelessWidget {
  const _RecognizeLoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Preparing sign recognition...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.userName, super.key});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          borderRadius: 24,
          opacity: 0.1,
          blur: 18,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 26,
                child: Icon(Icons.person_rounded),
              ),
              const SizedBox(height: 14),
              Text('Hi, $userName', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text(
                'Offline mode is enabled. Your sign recognition runs fully on-device using TFLite.',
              ),
            ],
          ),
        ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.06),
        const SizedBox(height: 12),
        GlassCard(
          borderRadius: 18,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.tune_rounded),
            title: const Text('Settings'),
            subtitle: const Text('Recognition thresholds and preferences'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(
              AppNavigation.fadeTransition(const SettingsScreen()),
            ),
          ),
        ).animate().fadeIn(delay: 80.ms, duration: 320.ms).slideY(begin: 0.06),
        const SizedBox(height: 12),
        GlassCard(
          borderRadius: 18,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.dataset_rounded),
            title: const Text('Collect Training Data'),
            subtitle: const Text('Capture landmarks and export training_samples.json'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(
              AppNavigation.fadeTransition(const CollectDataScreen()),
            ),
          ),
        ).animate().fadeIn(delay: 120.ms, duration: 320.ms).slideY(begin: 0.06),
      ],
    );
  }
}
