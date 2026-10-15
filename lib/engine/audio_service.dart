import 'package:audioplayers/audioplayers.dart';

import 'audio_pack.dart';
import 'models.dart';

/// Plays recitation: bundled/downloaded file first, stream as fallback.
/// Never TTS for Quranic text (locked rule).
class AudioService {
  final AudioPackManager packs;
  final AudioPlayer _player = AudioPlayer();

  AudioService(this.packs);

  /// Resolves the best [Source] for a step: local file > CDN stream.
  /// Returns null when the step has no ayah audio (e.g. Qaida letters).
  Future<Source?> resolve(LessonStep step, String edition) async {
    final n = step.globalAyahNumber;
    if (n == null) return null;
    final local = packs.localFile(edition, n);
    if (local != null) return DeviceFileSource(local.path);
    final url = step.audioUrl(edition);
    if (url != null) return UrlSource(url);
    return null;
  }

  /// Resolves audio for a raw global ayah number (used by Ayah of the Day).
  Future<Source?> resolveAyah(int ayahNumber, String edition) async {
    final local = packs.localFile(edition, ayahNumber);
    if (local != null) return DeviceFileSource(local.path);
    return UrlSource(
        'https://cdn.islamic.network/quran/audio/${AudioPackManager.bitrate}/$edition/$ayahNumber.mp3');
  }

  Future<void> play(Source source) async {
    try {
      await _player.stop();
      await _player.play(source);
    } catch (_) {
      // Playback must never crash the game.
    }
  }

  Future<void> stop() => _player.stop();

  void dispose() => _player.dispose();
}
