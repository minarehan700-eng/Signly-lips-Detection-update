import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static const _kOnboardingSeen = 'onboarding_seen';
  static const _kIsLoggedIn = 'is_logged_in';
  static const _kUserName = 'user_name';

  Future<bool> isOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboardingSeen) ?? false;
  }

  Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingSeen, true);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kIsLoggedIn) ?? false;
  }

  Future<void> saveLogin({required String name}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingSeen, true);
    await prefs.setBool(_kIsLoggedIn, true);
    await prefs.setString(_kUserName, name);
  }

  Future<String> userName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserName) ?? 'Guest';
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsLoggedIn, false);
  }
}
