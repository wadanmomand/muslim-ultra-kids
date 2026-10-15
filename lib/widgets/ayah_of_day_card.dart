import 'package:flutter/material.dart';

import '../engine/daily_ayah.dart';
import '../engine/game_state.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import 'kids_icon.dart';

/// Ayah of the Day card: bundled ayah + meaning + recitation playback.
/// Shared by the home page (map no longer shows it).
class AyahOfTheDayCard extends StatefulWidget {
  final GameState state;
  const AyahOfTheDayCard({super.key, required this.state});

  @override
  State<AyahOfTheDayCard> createState() => _AyahOfTheDayCardState();
}

class _AyahOfTheDayCardState extends State<AyahOfTheDayCard> {
  bool _playing = false;

  Future<void> _play(DailyAyah ayah) async {
    setState(() => _playing = true);
    try {
      final src = await widget.state.audio.resolveAyah(
        ayah.globalAyahNumber,
        widget.state.progress.reciterEdition,
      );
      if (src != null) await widget.state.audio.play(src);
    } finally {
      if (mounted) setState(() => _playing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ayah = ayahForDate(DateTime.now());
    final strings = widget.state.strings;
    final isDark = widget.state.isDark;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? KidsTheme.nightCard : Colors.white)
            .withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KidsIconLabel(
                  'moon',
                  strings.get('ayahOfTheDay'),
                  iconSize: 30,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: KidsTheme.tealDark),
                ),
                const SizedBox(height: 4),
                Text(
                  ayah.text,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  softWrap: true,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.9,
                      color: KidsTheme.inkFor(isDark)),
                ),
                const SizedBox(height: 2),
                Text(
                  ayah.meaningIn(strings.lang.code),
                  style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black54),
                ),
              ],
            ),
          ),
          IconButton(
            iconSize: 64,
            onPressed: _playing ? null : () => _play(ayah),
            icon: KidsIcon(_playing ? 'hourglass' : 'speaker', size: 64),
          ),
        ],
      ),
    );
  }
}
