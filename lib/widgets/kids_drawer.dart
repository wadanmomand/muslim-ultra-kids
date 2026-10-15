import 'package:flutter/material.dart';

import '../engine/game_state.dart';
import '../l10n/strings.dart';
import '../screens/download_screen.dart';
import '../screens/parent_dashboard.dart';
import '../theme/app_theme.dart';
import 'kids_icon.dart';

/// Hamburger menu drawer: holds every top-bar option so the home and map
/// screens stay clean. Contents: stats, Parents gate, language,
/// light/dark toggle, audio download (when the pack is missing).
class KidsMenuDrawer extends StatelessWidget {
  final GameState state;

  const KidsMenuDrawer({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final strings = state.strings;
    final isDark = state.isDark;
    final ink = KidsTheme.inkFor(isDark);
    final p = state.progress;
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Text(
                strings.get('appName'),
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w900, color: ink),
              ),
            ),
            const SizedBox(height: 4),
            _StatsRow(p: p, ink: ink),
            const Divider(height: 24),
            ListTile(
              leading: const KidsIcon('family', size: 34),
              title: Text(strings.get('forParents'),
                  style: TextStyle(fontWeight: FontWeight.w700, color: ink)),
              onTap: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (_) => ParentGate(state: state),
                );
              },
            ),
            ListTile(
              leading: const KidsIcon('globe', size: 34),
              title: Text(strings.get('language'),
                  style: TextStyle(fontWeight: FontWeight.w700, color: ink)),
              trailing: DropdownButton<KidsLang>(
                value: state.lang,
                underline: const SizedBox.shrink(),
                items: KidsLang.values
                    .map((l) =>
                        DropdownMenuItem(value: l, child: Text(l.label)))
                    .toList(),
                onChanged: (l) {
                  if (l != null) state.setLang(l);
                },
              ),
            ),
            SwitchListTile(
              secondary: KidsIcon(isDark ? 'moon' : 'lightning', size: 34),
              title: Text(
                  isDark ? strings.get('darkMode') : strings.get('lightMode'),
                  style: TextStyle(fontWeight: FontWeight.w700, color: ink)),
              value: isDark,
              onChanged: (v) => state.setDark(v),
            ),
            if (state.needsAudioDownload)
              ListTile(
                leading: const KidsIcon('download', size: 34),
                title: Text(strings.get('downloadAudio'),
                    style:
                        TextStyle(fontWeight: FontWeight.w700, color: ink)),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DownloadScreen(
                        state: state,
                        onDone: () => Navigator.of(context).pop(),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final dynamic p;
  final Color ink;
  const _StatsRow({required this.p, required this.ink});

  @override
  Widget build(BuildContext context) {
    final cells = [
      ('lightning', '${p.xp}', 'XP'),
      ('star', '${p.totalStars}', 'Stars'),
      ('book', '${p.lessonsCompleted}', 'Lessons'),
      ('fire', '${p.streakDays}', 'Streak'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: cells
            .map((c) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        KidsIcon(c.$1, size: 30),
                        const SizedBox(height: 2),
                        Text(c.$2,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: ink)),
                        Text(c.$3,
                            style: TextStyle(
                                fontSize: 10,
                                color: ink.withValues(alpha: 0.6))),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

/// Golden 3D hamburger button used on home and map.
class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => Scaffold.of(context).openDrawer(),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFD964), KidsTheme.gold, KidsTheme.goldDark],
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
              BoxShadow(
                  color: Colors.white54, blurRadius: 2, offset: Offset(0, -2)),
            ],
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    width: 22,
                    height: 3.5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(99),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 2)
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
