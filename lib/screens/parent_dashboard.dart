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
    return Scaffold(
      appBar: AppBar(title: Text(strings.get('forParents'))),
      body: Container(
        decoration: BoxDecoration(gradient: KidsTheme.bgFor(widget.state.isDark)),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _StatsGrid(p: p),
            const SizedBox(height: 16),
            _Section(
              icon: 'mic',
              title: 'Reciter',
              child: RadioGroup<String>(
                groupValue: p.reciterEdition,
                onChanged: (v) =>
                    setState(() => widget.state.setReciter(v!)),
                child: Column(
                  children: AudioPackManager.editions
                      .map((e) => RadioListTile<String>(
                            title: Text(
                                AudioPackManager.editionNames[e] ?? e),
                            value: e,
                          ))
                      .toList(),
                ),
              ),
            ),
            _Section(
              icon: 'globe',
              title: 'Language',
              child: SegmentedButton<KidsLang>(
                segments: KidsLang.values
                    .map((l) =>
                        ButtonSegment(value: l, label: Text(l.label)))
                    .toList(),
                selected: {widget.state.lang},
                onSelectionChanged: (s) =>
                    setState(() => widget.state.setLang(s.first)),
              ),
            ),
            _Section(
              icon: 'bell',
              title: 'Daily Ayah reminder',
              child: SwitchListTile(
                title: const Text('Send every morning'),
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
              title: 'About',
              child: const Text(
                'Quran text: verified Uthmani script.\n'
                'Recitation: Islamic Network (alquran.cloud) free CDN — '
                'downloaded once, works offline. Copyrights belong to the '
                'reciters; bundled under their free redistribution terms.\n'
                'No accounts, no tracking, no ads in lessons.',
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Reset all progress?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await widget.state.resetProgress();
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          setState(() {});
                        }
                      },
                      child: const Text('Reset',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
              icon: const KidsIcon('trash', size: 24),
              label: const Text('Reset progress'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String icon;
  final String title;
  final Widget child;

  const _Section(
      {required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KidsIconLabel(icon, title,
                iconSize: 28,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
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
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          KidsIcon(c.$1, size: 30),
                          const SizedBox(height: 4),
                          Text(c.$2,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900)),
                          Text(c.$3,
                              textAlign: TextAlign.center,
                              style:
                                  const TextStyle(fontSize: 11)),
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
