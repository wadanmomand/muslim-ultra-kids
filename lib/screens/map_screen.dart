import 'package:flutter/material.dart';

import '../engine/daily_ayah.dart';
import '../engine/game_state.dart';
import '../engine/models.dart';
import '../engine/sfx.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import '../widgets/kids_icon.dart';
import 'lesson_screen.dart';
import 'parent_dashboard.dart';

/// Adventure map: worlds as sections, lessons as nodes on a winding path.
/// Banner ad in the footer; lessons themselves stay ad-free.
class MapScreen extends StatelessWidget {
  final GameState state;

  const MapScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final strings = state.strings;
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.get('appName')),
        actions: [
          _XpChip(xp: state.progress.xp),
          IconButton(
            tooltip: strings.get('forParents'),
            icon: const KidsIcon('family', size: 36),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => ParentGate(state: state),
            ),
          ),
          PopupMenuButton<KidsLang>(
            icon: const KidsIcon('globe', size: 36),
            onSelected: state.setLang,
            itemBuilder: (_) => KidsLang.values
                .map((l) => PopupMenuItem(value: l, child: Text(l.label)))
                .toList(),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: KidsTheme.skyGradient),
        child: Column(
          children: [
            _AyahOfTheDayCard(state: state),
            Expanded(child: _MapBody(state: state)),
            const BannerAdFooter(),
          ],
        ),
      ),
    );
  }
}

/// Ayah of the Day card: bundled ayah + meaning + recitation playback.
class _AyahOfTheDayCard extends StatefulWidget {
  final GameState state;
  const _AyahOfTheDayCard({required this.state});

  @override
  State<_AyahOfTheDayCard> createState() => _AyahOfTheDayCardState();
}

class _AyahOfTheDayCardState extends State<_AyahOfTheDayCard> {
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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
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
                  iconSize: 22,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: KidsTheme.tealDark),
                ),
                const SizedBox(height: 4),
                Text(
                  ayah.text,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  ayah.meaningIn(strings.lang.code),
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
          IconButton(
            iconSize: 48,
            onPressed: _playing ? null : () => _play(ayah),
            icon: KidsIcon(_playing ? 'hourglass' : 'speaker', size: 48),
          ),
        ],
      ),
    );
  }
}

class _XpChip extends StatelessWidget {  final int xp;
  const _XpChip({required this.xp});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: KidsTheme.gold,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const KidsIcon('lightning', size: 22),
          const SizedBox(width: 4),
          Text(
            '$xp',
            style: const TextStyle(
                fontWeight: FontWeight.w800, color: KidsTheme.ink),
          ),
        ],
      ),
    );
  }
}

class _MapBody extends StatelessWidget {
  final GameState state;
  const _MapBody({required this.state});

  @override
  Widget build(BuildContext context) {
    if (!state.loaded) {
      if (state.loadError != null) {
        return Center(
            child: KidsIconLabel('sad', state.loadError!, iconSize: 40));
      }
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: state.worlds.length,
      itemBuilder: (_, wi) {
        final world = state.worlds[wi];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Text(
                world.titleIn(state.lang.code),
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: KidsTheme.ink),
              ),
            ),
            ...world.nodes.map((n) => _NodeRow(state: state, node: n)),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}

class _NodeRow extends StatelessWidget {
  final GameState state;
  final MapNode node;

  const _NodeRow({required this.state, required this.node});

  @override
  Widget build(BuildContext context) {
    // Winding path: alternate left / center / right.
    final align = switch (node.order % 3) {
      0 => Alignment.centerLeft,
      1 => Alignment.center,
      _ => Alignment.centerRight,
    };
    final unlocked =
        state.progress.isNodeUnlocked(nodeOrder: node.order, worldId: node.worldId);
    final stars =
        state.progress.bestStars['${node.worldId}-lesson-${node.order}'] ?? 0;

    return Align(
      alignment: align,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
        child: GestureDetector(
          onTap: unlocked
              ? () {
                  Sfx.pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LessonScreen(
                        lesson: state.lessonForNode(node),
                        state: state,
                      ),
                    ),
                  );
                }
              : () => Sfx.error(),
          child: Column(
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: unlocked ? KidsTheme.gold : KidsTheme.starGrey,
                  border: Border.all(
                    color: node.isBoss ? KidsTheme.tealDark : Colors.white,
                    width: node.isBoss ? 5 : 4,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 6)
                  ],
                ),
                child: Center(
                  child: unlocked
                      ? (stars > 0
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                  stars,
                                  (_) => const Padding(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 1),
                                        child: KidsIcon('star', size: 20),
                                      )))
                          : Text('${node.order + 1}',
                              style: const TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.w800)))
                      : const KidsIcon('lock', size: 34),
                ),
              ),
              if (node.isBoss && unlocked)
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: KidsIcon('crown', size: 26),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
