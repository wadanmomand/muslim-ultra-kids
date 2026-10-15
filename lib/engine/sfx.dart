import 'package:audioplayers/audioplayers.dart';

/// Tiny bundled sound effects (assets/sfx/*.wav, synthesized locally).
/// No backend, no licensing issues.
class Sfx {
  static final Map<String, AudioPlayer> _players = {};

  static Future<void> play(String name) async {
    try {
      final player = _players.putIfAbsent(name, () => AudioPlayer());
      await player.stop();
      await player.play(AssetSource('sfx/$name.wav'));
    } catch (_) {
      // SFX must never crash the game.
    }
  }

  static Future<void> pop() => play('pop');
  static Future<void> star() => play('star');
  static Future<void> success() => play('success');
  static Future<void> error() => play('error');
}
