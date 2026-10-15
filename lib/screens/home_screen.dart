import 'package:flutter/material.dart';

import '../engine/game_state.dart';
import '../engine/sfx.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import '../widgets/ayah_of_day_card.dart';
import '../widgets/bubble_text.dart';
import '../widgets/companion.dart';
import '../widgets/kids_drawer.dart';
import '../widgets/kids_icon.dart';
import 'lesson_screen.dart' show BannerAdFooter;
import 'map_screen.dart';

/// Dedicated home page: 3D title, mascot, world cards, Ayah of the Day,
/// big PLAY button. The hamburger menu holds every top option so the
/// screen stays clean. PLAY / world cards open the adventure map.
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
    return Scaffold(
      drawer: KidsMenuDrawer(state: state),
      body: Container(
        decoration: BoxDecoration(gradient: KidsTheme.bgFor(isDark)),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Builder(
                    builder: (ctx) => const MenuButton(),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Column(
                    children: [
                      BubbleText(strings.get('appName'), fontSize: 40),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Companion(size: 110),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.9),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black12, blurRadius: 8)
                              ],
                            ),
                            child: const KidsIcon('book', size: 64),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _WorldCard(
                              icon: 'book',
                              title: state.worlds.isNotEmpty
                                  ? state.worlds[0].titleIn(state.lang.code)
                                  : 'Qaida',
                              gradient: const [
                                Color(0xFF3ED6C3),
                                KidsTheme.tealDark
                              ],
                              onTap: () => _openMap(context,
                                  focusWorldId: state.worlds.isNotEmpty
                                      ? state.worlds[0].id
                                      : null),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _WorldCard(
                              icon: 'moon',
                              title: state.worlds.length > 1
                                  ? state.worlds[1].titleIn(state.lang.code)
                                  : 'Juz Amma',
                              gradient: const [
                                Color(0xFFB388EB),
                                Color(0xFF7B4FD6)
                              ],
                              onTap: () => _openMap(context,
                                  focusWorldId: state.worlds.length > 1
                                      ? state.worlds[1].id
                                      : null),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AyahOfTheDayCard(state: state),
                      const SizedBox(height: 16),
                      _PlayButton(
                        label: strings.get('play'),
                        onTap: () => _openMap(context),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              const BannerAdFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorldCard extends StatelessWidget {
  final String icon;
  final String title;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _WorldCard({
    required this.icon,
    required this.title,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
              BoxShadow(
                  color: Colors.white38, blurRadius: 2, offset: Offset(0, -2)),
            ],
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              KidsIcon(icon, size: 68),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                          offset: Offset(0, 2),
                          color: Colors.black38,
                          blurRadius: 2)
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PlayButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFD964), KidsTheme.gold, KidsTheme.goldDark],
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
              BoxShadow(
                  color: Colors.white54, blurRadius: 3, offset: Offset(0, -2)),
            ],
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: BubbleText(label.toUpperCase(), fontSize: 30),
        ),
      ),
    );
  }
}
