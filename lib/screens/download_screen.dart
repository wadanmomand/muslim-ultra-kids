import 'package:flutter/material.dart';

import '../engine/game_state.dart';
import '../engine/sfx.dart';
import '../theme/app_theme.dart';
import '../widgets/companion.dart';
import '../widgets/kids_icon.dart';

/// First-launch screen: downloads the recitation audio pack (both reciters)
/// from the Islamic Network free CDN, then the game works fully offline.
/// Skippable — lessons fall back to streaming until downloaded.
class DownloadScreen extends StatefulWidget {
  final GameState state;
  final VoidCallback onDone;

  const DownloadScreen({super.key, required this.state, required this.onDone});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  double _progress = 0;
  bool _downloading = false;
  int _failed = 0;

  Future<void> _start() async {
    setState(() {
      _downloading = true;
      _failed = 0;
    });
    try {
      final failed = await widget.state.audioPacks.downloadAll(
        widget.state.neededAyahs,
        onProgress: (p) => mounted ? setState(() => _progress = p) : null,
      );
      if (!mounted) return;
      if (failed == 0) {
        Sfx.success();
        await widget.state.markAudioReady();
        widget.onDone();
      } else {
        setState(() {
          _failed = failed;
          _downloading = false;
        });
      }
    } catch (e) {
      // Unexpected failure outside per-file handling (e.g. storage).
      if (!mounted) return;
      setState(() {
        _failed = -1;
        _downloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ayahs = widget.state.neededAyahs.length;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: KidsTheme.skyGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Companion(size: 110),
                const SizedBox(height: 16),
                const KidsIconLabel(
                  'download',
                  'One-time download',
                  iconSize: 34,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: KidsTheme.ink),
                ),
                const SizedBox(height: 8),
                Text(
                  'Downloading the recitation ($ayahs ayahs × 2 reciters) '
                  'so the game works offline forever. Free, no account needed.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: KidsTheme.ink),
                ),
                const SizedBox(height: 24),
                if (_downloading) ...[
                  LinearProgressIndicator(
                    value: _progress,
                    minHeight: 14,
                    borderRadius: BorderRadius.circular(99),
                    backgroundColor: Colors.white,
                    valueColor: const AlwaysStoppedAnimation(KidsTheme.teal),
                  ),
                  const SizedBox(height: 8),
                  Text('${(_progress * 100).toInt()}%',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                ] else ...[
                  ElevatedButton(
                    onPressed: _start,
                    child: const KidsIconLabel('download', 'Download now',
                        iconSize: 28),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: widget.onDone,
                    child: const Text('Skip for now',
                        style: TextStyle(
                            fontSize: 16, color: KidsTheme.tealDark)),
                  ),
                ],
                if (_failed != 0) ...[
                  const SizedBox(height: 12),
                  KidsIconLabel(
                    'sad',
                    _failed == -1
                        ? 'Something went wrong. Please try again.'
                        : '$_failed audio file(s) could not be downloaded. '
                            'Check your internet and try again — '
                            'already downloaded files will not be re-downloaded.',
                    iconSize: 32,
                    style:
                        const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _start,
                    child: const KidsIconLabel('replay', 'Try again',
                        iconSize: 28),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
