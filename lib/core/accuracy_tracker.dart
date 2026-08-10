import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AccuracyTracker {
  static const String _key = 'accuracy_data';

  Future<void> record(String label, bool isCorrect) async {
    final prefs = await SharedPreferences.getInstance();
    final dataStr = prefs.getString(_key) ?? '{}';
    final data = jsonDecode(dataStr) as Map<String, dynamic>;

    if (!data.containsKey(label)) {
      data[label] = {'correct': 0, 'total': 0};
    }

    data[label]['total'] = (data[label]['total'] as int) + 1;
    if (isCorrect) {
      data[label]['correct'] = (data[label]['correct'] as int) + 1;
    }

    await prefs.setString(_key, jsonEncode(data));
  }

  Future<Map<String, ({int correct, int total})>> getStats() async {
    final prefs = await SharedPreferences.getInstance();
    final dataStr = prefs.getString(_key) ?? '{}';
    final data = jsonDecode(dataStr) as Map<String, dynamic>;

    final result = <String, ({int correct, int total})>{};
    for (final label in data.keys) {
      final entry = data[label] as Map<String, dynamic>;
      result[label] = (
        correct: entry['correct'] as int,
        total: entry['total'] as int,
      );
    }
    return result;
  }

  Future<double> overallAccuracy() async {
    final stats = await getStats();
    if (stats.isEmpty) return 0.0;

    int totalCorrect = 0;
    int totalAttempts = 0;
    for (final entry in stats.values) {
      totalCorrect += entry.correct;
      totalAttempts += entry.total;
    }

    return totalAttempts == 0 ? 0.0 : totalCorrect / totalAttempts;
  }

  Future<double?> getLabelAccuracy(String label) async {
    final stats = await getStats();
    if (!stats.containsKey(label)) return null;
    final entry = stats[label]!;
    return entry.total == 0 ? 0.0 : entry.correct / entry.total;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
