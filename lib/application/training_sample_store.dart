import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class TrainingSample {
  const TrainingSample({
    required this.label,
    required this.features42,
    required this.handScore,
    required this.span,
    required this.timestamp,
  });

  final String label;
  final List<double> features42;
  final double handScore;
  final double span;
  final int timestamp;

  Map<String, dynamic> toJson() => {
        'label': label,
        'features42': features42,
        'handScore': handScore,
        'span': span,
        'timestamp': timestamp,
      };

  factory TrainingSample.fromJson(Map<String, dynamic> json) {
    return TrainingSample(
      label: json['label'] as String,
      features42: (json['features42'] as List<dynamic>)
          .map((v) => (v as num).toDouble())
          .toList(),
      handScore: (json['handScore'] as num).toDouble(),
      span: (json['span'] as num).toDouble(),
      timestamp: json['timestamp'] as int,
    );
  }
}

class TrainingSampleStore {
  static const String pendingFileName = 'training_samples_pending.json';
  static const String exportFileName = 'training_samples.json';

  Future<File> _pendingFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$pendingFileName');
  }

  Future<File> _exportFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$exportFileName');
  }

  Future<List<TrainingSample>> loadAll() async {
    final file = await _pendingFile();
    if (!await file.exists()) return [];

    final raw = await file.readAsString();
    if (raw.trim().isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => TrainingSample.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addSample(TrainingSample sample) async {
    final samples = await loadAll()..add(sample);
    await _writePending(samples);
  }

  Future<int> countForLabel(String label) async {
    final samples = await loadAll();
    return samples.where((s) => s.label == label).length;
  }

  Future<Map<String, int>> countByLabel() async {
    final samples = await loadAll();
    final counts = <String, int>{};
    for (final sample in samples) {
      counts[sample.label] = (counts[sample.label] ?? 0) + 1;
    }
    return counts;
  }

  Future<String> exportJson() async {
    final samples = await loadAll();
    final exportFile = await _exportFile();
    final encoder = const JsonEncoder.withIndent('  ');
    await exportFile.writeAsString(encoder.convert(samples.map((s) => s.toJson()).toList()));
    return exportFile.path;
  }

  Future<void> clearAll() async {
    await _writePending([]);
    final exportFile = await _exportFile();
    if (await exportFile.exists()) {
      await exportFile.delete();
    }
  }

  Future<void> _writePending(List<TrainingSample> samples) async {
    final file = await _pendingFile();
    final encoder = const JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(samples.map((s) => s.toJson()).toList()));
  }
}
