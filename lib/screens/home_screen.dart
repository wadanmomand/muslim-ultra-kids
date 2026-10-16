import 'package:flutter/material.dart';

import '../engine/daily_ayah.dart';
import '../engine/game_state.dart';
import '../engine/models.dart';
import '../engine/sfx.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import '../widgets/bubble_text.dart';
import '../widgets/kids_drawer.dart';
import '../widgets/kids_icon.dart';
import 'lesson_screen.dart' show BannerAdFooter;
import 'map_screen.dart';

/// Home page rendered over a full-screen AI-generated 3D art background.
/// Interactive regions (world cards, PLAY button) are transparent tap zones
/// positioned over the baked 3D art; dynamic + localized text (title, card
/// labels, Ayah of the Day) is overlaid as widgets. BoxFit.fill keeps the
/// art and the tap zones aligned on every screen size.
class HomeScreen extends StatelessWidget {
  final GameState state;

  const HomeScreen({super.key, required this.state});

  void _openMap(BuildContext context, {String? focusWorldId}) {
    Sfx.pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MapScreen(state: state, focusWorldId: focusWorldId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = state.strings;
    final isDark = state.isDark;
    World? worldById(String id) {
      for (final w in state.worlds) {
        if (w.id == id) return w;
      }
      return null;
    }
    final qaidaWorld = worldById('qaida');
    final juzWorld = worldById('juzAmma');

    return Scaffold(
      drawer: KidsMenuDrawer(state: state),
      body: Stack(
        children: [
          // 3D art background (fills the whole screen; tap zones below use
          // the same fractional coordinates, so they always line up).
          Positioned.fill(
            child: Image.asset(
              'assets/art/home_3d_bg.webp',
              fit: BoxFit.fill,
            ),
          ),
          if (isDark)
            Positioned.fill(
              child: Container(
                  color: Colors.black.withValues(alpha: 0.28)),
            ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                return Stack(
                  children: [
                    // Hamburger menu (top-left, over empty sky).
                    const Positioned(
                      top: 6,
                      left: 12,
                      child: MenuButton(),
                    ),
                    // Brand title (English in every language, over empty sky).
                    Positioned(
                      top: h * 0.035,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: BubbleText(
                          strings.get('appName'),
                          fontSize: 42,
                        ),
                      ),
                    ),
                    // Noorani Qaida card tap zone.
                    Positioned(
                      left: w * 0.07,
                      top: h * 0.44,
                      width: w * 0.44,
                      height: h * 0.19,
                      child: _TapZone(
                        label: qaidaWorld?.titleIn(state.lang.code) ??
                            'Qaida',
                        onTap: () => _openMap(context,
                            focusWorldId: qaidaWorld?.id),
                      ),
                    ),
                    // Qaida card label (over the card's empty lower area).
                    Positioned(
                      left: w * 0.07,
                      top: h * 0.575,
                      width: w * 0.44,
                      child: _CardLabel(
                        qaidaWorld?.titleIn(state.lang.code) ?? 'Qaida',
                      ),
                    ),
                    // Juz Amma card tap zone.
                    Positioned(
                      left: w * 0.50,
                      top: h * 0.44,
                      width: w * 0.44,
                      height: h * 0.19,
                      child: _TapZone(
                        label: juzWorld?.titleIn(state.lang.code) ??
                            'Juz Amma',
                        onTap: () => _openMap(context,
                            focusWorldId: juzWorld?.id),
                      ),
                    ),
                    // Juz Amma card label.
                    Positioned(
                      left: w * 0.50,
                      top: h * 0.575,
                      width: w * 0.44,
                      child: _CardLabel(
                        juzWorld?.titleIn(state.lang.code) ?? 'Juz Amma',
                      ),
                    ),
                    // Ayah of the Day overlay (over the empty banner plaque).
                    Positioned(
                      left: w * 0.13,
                      right: w * 0.13,
                      top: h * 0.638,
                      height: h * 0.072,
                      child: _AyahOverlay(state: state),
                    ),
                    // PLAY button tap zone (PLAY text is baked into the art).
                    Positioned(
                      left: w * 0.20,
                      top: h * 0.715,
                      width: w * 0.60,
                      height: h * 0.095,
                      child: _TapZone(
                        label: strings.get('play'),
                        onTap: () => _openMap(context),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BannerAdFooter(),
          ),
        ],
      ),
    );
  }
}

/// Transparent tap zone over a baked 3D art region.
class _TapZone extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TapZone({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// Localized label drawn over a 3D art card's empty lower area.
class _CardLabel extends StatelessWidget {
  final String text;

  const _CardLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        shadows: [
          Shadow(offset: Offset(0, 2), color: Colors.black38, blurRadius: 3),
        ],
      ),
    );
  }
}

/// Ayah of the Day content overlaid on the art's empty banner plaque,
/// with recitation playback.
class _AyahOverlay extends StatefulWidget {
  final GameState state;

  const _AyahOverlay({required this.state});

  @override
  State<_AyahOverlay> createState() => _AyahOverlayState();
}

class _AyahOverlayState extends State<_AyahOverlay> {
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
    // Scale content to the banner height so it never overflows,
    // on tall phones and small test viewports alike.
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxHeight / 150).clamp(0.45, 1.0);
        final btnSize = 46 * scale;
        return Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.get('ayahOfTheDay'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w800,
                      color: KidsTheme.tealDark,
                    ),
                  ),
                  Text(
                    ayah.text,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 17 * scale,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                      color: const Color(0xFF3A2E1A),
                    ),
                  ),
                  Text(
                    ayah.meaningIn(strings.lang.code),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12 * scale,
                      color: const Color(0xFF6B5B3E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _playing ? null : () => _play(ayah),
              child: Container(
                width: btnSize,
                height: btnSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 4)
                  ],
                ),
                child: Center(
                  child: KidsIcon(
                    _playing ? 'hourglass' : 'speaker',
                    size: 30 * scale,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
