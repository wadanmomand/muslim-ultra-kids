import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// Downloads + caches per-ayah recitation MP3s from the Islamic Network
/// free CDN (license verified 2026-10-12: bundling/caching allowed,
/// keep original bitrates, credit reciters).
///
/// Strategy: on first launch, download every ayah the bundled lessons need
/// (both reciters). After that the game is fully offline. Lesson player
/// prefers local files and falls back to streaming.
class AudioPackManager {
  static const editions = ['ar.alafasy', 'ar.abdulbasitmurattal'];
  static const editionNames = {
    'ar.alafasy': 'Mishary Alafasy',
    'ar.abdulbasitmurattal': 'Abdul Basit',
  };
  static const int bitrate = 64;
  static const _manifestKey = 'muk_audio_manifest_v1';

  Directory? _dir;
  Map<String, List<int>> _manifest = {};

  /// Global ayah numbers (1-6236) the current lessons need.
  static Set<int> neededAyahs(Map<String, Lesson> lessons) {
    final out = <int>{};
    for (final lesson in lessons.values) {
      for (final step in lesson.steps) {
        final n = step.globalAyahNumber;
        if (n != null) out.add(n);
      }
    }
    return out;
  }

  Future<void> init() async {
    final base = await getApplicationDocumentsDirectory();
    _dir = Directory('${base.path}/audio');
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_manifestKey);
    if (raw != null) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        _manifest = m.map((k, v) =>
            MapEntry(k, (v as List).map((e) => (e as num).toInt()).toList()));
      } catch (_) {
        _manifest = {};
      }
    }
  }

  String _filePath(String edition, int ayah) =>
      '${_dir!.path}/$edition/$ayah.mp3';

  /// Local file if already downloaded, else null.
  File? localFile(String edition, int ayah) {
    final f = File(_filePath(edition, ayah));
    return f.existsSync() ? f : null;
  }

  bool get isComplete =>
      _manifest.length == editions.length &&
      editions.every((e) => (_manifest[e] ?? []).isNotEmpty);

  /// Downloads [ayahs] for both reciters. Reports 0.0-1.0 progress.
  /// Skips files already present. Throws on persistent failure.
  Future<void> downloadAll(
    Set<int> ayahs, {
    void Function(double progress)? onProgress,
  }) async {
    final jobs = <_Job>[];
    for (final edition in editions) {
      for (final ayah in ayahs) {
        if (localFile(edition, ayah) == null) {
          jobs.add(_Job(edition, ayah));
        }
      }
    }
    if (jobs.isEmpty) {
      await _saveManifest(ayahs);
      onProgress?.call(1.0);
      return;
    }

    final client = HttpClient();
    try {
      var done = 0;
      for (final job in jobs) {
        await _downloadOne(client, job);
        done++;
        onProgress?.call(done / jobs.length);
      }
    } finally {
      client.close(force: true);
    }
    await _saveManifest(ayahs);
  }

  Future<void> _downloadOne(HttpClient client, _Job job) async {
    final url =
        'https://cdn.islamic.network/quran/audio/$bitrate/${job.edition}/${job.ayah}.mp3';
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode != 200) {
      throw HttpException(
          'Audio download failed: $url (${response.statusCode})');
    }
    final file = File(_filePath(job.edition, job.ayah));
    await file.parent.create(recursive: true);
    final sink = file.openWrite();
    try {
      await response.pipe(sink);
    } finally {
      await sink.close();
    }
    debugPrint('downloaded $url');
  }

  Future<void> _saveManifest(Set<int> ayahs) async {
    final sorted = ayahs.toList()..sort();
    _manifest = {for (final e in editions) e: sorted};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_manifestKey, jsonEncode(_manifest));
  }
}

class _Job {
  final String edition;
  final int ayah;
  _Job(this.edition, this.ayah);
}
