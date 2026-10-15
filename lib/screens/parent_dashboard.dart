import 'dart:math';

import 'package:flutter/material.dart';

import '../engine/audio_pack.dart';
import '../engine/daily_ayah.dart';
import '../engine/game_state.dart';
import '../engine/progress.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import '../widgets/kids_icon.dart';

/// Parental gate: simple arithmetic, so little kids can't wander in.
class ParentGate extends StatefulWidget {
  final GameState state;

  const ParentGate({super.key, required this.state});

  @override
  State<ParentGate> createState() => _ParentGateState();
}

class _ParentGateState extends State<ParentGate> {
  late final int a;
  late final int b;
  late final List<int> options;

  @override
  void initState() {
    super.initState();
    final r = Random();
    a = 6 + r.nextInt(8);
    b = 5 + r.nextInt(8);
    final correct = a + b;
    final set = {correct, correct + 1, correct - 2, correct + 3};
    set.removeWhere((x) => x <= 0 || x == correct && false);
    final wrong = set.where((x) => x != correct).take(2).toList();
    options = [correct, ...wrong]..shuffle(r);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(widget.state.strings.get('forParents')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const KidsIconLabel('lock', 'Grown-ups only: solve to enter',
              iconSize: 28,
              style: TextStyle(fontSize: 15)),
          const SizedBox(height: 12),
          Text('$a + $b = ?',
              style:
                  const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: options
                .map((o) => ElevatedButton(
                      onPressed: () {
                        if (o == a + b) {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ParentDashboard(state: widget.state),
                            ),
                          );
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text('$o'),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

/// Parent dashboard: stats, reciter/language settings, notifications,
/// reset progress, and audio/reciter credits. No ads here.
class ParentDashboard extends StatefulWidget {
  final GameState state;

  const ParentDashboard({super.key, required this.state});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  bool _notifOn = true;

  @override
  void initState() {
    super.initState();
    _notifOn = widget.state.store.getSetting('notif') != 'off';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.state.progress;
    final strings = widget.state.strings;
    final isDark = widget.state.isDark;
    final ink = KidsTheme.inkFor(isDark);
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Material(
            color: KidsTheme.cardFor(isDark),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.of(context).pop(),
              child: Icon(Icons.arrow_back,
                  color: isDark ? Colors.white : KidsTheme.tealDark),
            ),
          ),
        ),
        title: Text(
          strings.get('forParents'),
          style: TextStyle(fontWeight: FontWeight.w900, color: ink),
        ),
      ),
      body: Container(
        decoration:
            BoxDecoration(gradient: KidsTheme.bgFor(widget.state.isDark)),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          children: [
            _StatsGrid(p: p),
            const SizedBox(height: 16),
            _Section(
              icon: 'mic',
              title: strings.get('reciter'),
              isDark: isDark,
              child: RadioGroup<String>(
                groupValue: p.reciterEdition,
                onChanged: (v) =>
                    setState(() => widget.state.setReciter(v!)),
                child: Column(
                  children: AudioPackManager.editions
                      .map((e) => RadioListTile<String>(
                            title: Text(
                              AudioPackManager.editionNames[e] ?? e,
                              style: TextStyle(color: ink),
                            ),
                            value: e,
                          ))
                      .toList(),
                ),
              ),
            ),
            _Section(
              icon: 'globe',
              title: strings.get('language'),
              isDark: isDark,
              child: Wrap(
                spacing: 10,
                children: KidsLang.values
                    .map((l) => _LangPill(
                          label: l.label,
                          selected: widget.state.lang == l,
                          isDark: isDark,
                          onTap: () =>
                              setState(() => widget.state.setLang(l)),
                        ))
                    .toList(),
              ),
            ),
            _Section(
              icon: 'bell',
              title: strings.get('dailyAyahReminder'),
              isDark: isDark,
              child: SwitchListTile(
                title: Text(strings.get('sendEveryMorning'),
                    style: TextStyle(color: ink)),
                value: _notifOn,
                onChanged: (v) async {
                  setState(() => _notifOn = v);
                  await widget.state.store
                      .setSetting('notif', v ? 'on' : 'off');
                  if (v) {
                    await AyahReminders.scheduleDaily(
                        ayahForDate(DateTime.now()),
                        widget.state.lang.code);
                  } else {
                    await AyahReminders.cancel();
                  }
                },
              ),
            ),
            _Section(
              icon: 'info',
              title: strings.get('about'),
              isDark: isDark,
              child: Text(
                'Quran text: verified Uthmani script.\n'
                'Recitation: Islamic Network (alquran.cloud) free CDN — '
                'downloaded once, works offline. Copyrights belong to the '
                'reciters; bundled under their free redistribution terms.\n'
                'No accounts, no tracking, no ads in lessons.',
                style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(strings.get('resetConfirm')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(strings.get('cancel')),
                    ),
                    TextButton(
                      onPressed: () async {
                        await widget.state.resetProgress();
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          setState(() {});
                        }
                      },
                      child: Text(strings.get('reset'),
                          style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
              icon: const KidsIcon('trash', size: 24),
              label: Text(strings.get('resetProgress')),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangPill extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _LangPill({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color:
                selected ? KidsTheme.tealDark : KidsTheme.cardFor(isDark),
            border: Border.all(color: KidsTheme.tealDark, width: 2),
            boxShadow: selected
                ? const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2))
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: selected
                  ? Colors.white
                  : (isDark ? Colors.white : KidsTheme.tealDark),
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String icon;
  final String title;
  final Widget child;
  final bool isDark;

  const _Section(
      {required this.icon,
      required this.title,
      required this.child,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    final ink = KidsTheme.inkFor(isDark);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: KidsTheme.cardFor(isDark),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KidsIconLabel(icon, title,
                iconSize: 30,
                style: TextStyle(
                    fontSize: 19, fontWeight: FontWeight.w900, color: ink)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final Progress p;
  const _StatsGrid({required this.p});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = KidsTheme.inkFor(isDark);
    final cells = [
      ('lightning', '${p.xp}', 'XP'),
      ('star', '${p.totalStars}', 'Stars'),
      ('book', '${p.lessonsCompleted}', 'Lessons'),
      ('fire', '${p.streakDays}', 'Day streak'),
    ];
    return Row(
      children: cells
          .map((c) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: KidsTheme.cardFor(isDark),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3))
                      ],
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          KidsIcon(c.$1, size: 44),
                          const SizedBox(height: 4),
                          Text(c.$2,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: ink)),
                          Text(c.$3,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: ink.withValues(alpha: 0.65))),
                        ],
                      ),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}
