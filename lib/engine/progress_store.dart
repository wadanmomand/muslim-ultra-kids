import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import 'progress.dart';

/// On-device persistence (Phase 3). No backend: Hive box in app storage.
/// Progress is stored as JSON — no codegen needed.
class ProgressStore {
  static const _boxName = 'muk_progress';
  static const _key = 'progress_v1';

  Box<String>? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  Progress load() {
    final raw = _box?.get(_key);
    if (raw == null) return const Progress();
    try {
      return Progress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const Progress();
    }
  }

  Future<void> save(Progress p) async {
    await _box?.put(_key, jsonEncode(p.toJson()));
  }

  Future<void> clear() async {
    await _box?.delete(_key);
  }

  /// Simple string settings (language, toggles).
  String? getSetting(String key) => _box?.get('setting_$key');

  Future<void> setSetting(String key, String value) async {
    await _box?.put('setting_$key', value);
  }
}
