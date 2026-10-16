import 'package:flutter/material.dart';

import '../engine/game_state.dart';
import '../engine/models.dart';
import '../engine/sfx.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import '../widgets/bubble_text.dart';
import '../widgets/kids_drawer.dart';
import '../widgets/kids_icon.dart';
import 'download_screen.dart';
import 'lesson_screen.dart';

/// Adventure map: worlds as sections, lessons as nodes on a winding path.
/// Banner ad in the footer; lessons themselves stay ad-free.
class MapScreen extends StatelessWidget {
  final GameState state;

  /// When set, the map auto-scrolls to this world (tapped from the home page).
  final String? focusWorldId;

  const MapScreen({super.key, required this.state, this.focusWorldId});

  @override
  Widget build(BuildContext context) {
    final strings = state.strings;
    return Scaffold(
      drawer: KidsMenuDrawer(state: state),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(builder: (ctx) => const MenuButton()),
        title: BubbleText(strings.get('appName'), fontSize: 24),
      ),
      body: Stack(
        children: [
          // 3D garden art background (fixed while the nodes scroll above).
          Positioned.fill(
            child: Image.asset(
              'assets/art/map_3d_bg.webp',
              fit: BoxFit.cover,
            ),
          ),
          if (state.isDark)
            Positioned.fill(
              child:
                  Container(color: Colors.black.withValues(alpha: 0.28)),
            ),
          Column(
            children: [
              Expanded(
                child: _MapBody(state: state, focusWorldId: focusWorldId),
              ),
              const BannerAdFooter(),
            ],
          ),
        ],
      ),
    );
  }
}


class _MapBody extends StatefulWidget {
  final GameState state;
  const _MapBody({required this.state, this.focusWorldId});

  /// When set, the map auto-scrolls to this world (tapped from the home page).
  final String? focusWorldId;

  @override
  State<_MapBody> createState() => _MapBodyState();
}

class _MapBodyState extends State<_MapBody> {
  final Map<String, GlobalKey> _worldKeys = {};
  bool _focusScrolled = false;
  /// Session flag: after the user skips the audio prompt once, don't nag
  /// again until the next app launch. (A persistent "Download" button stays
  /// in the World 2 header while the pack is missing.)
  bool _promptDismissed = false;

  GameState get state => widget.state;

  /// Opens a lesson. The first tap on a Juz Amma lesson (per launch) shows
  /// the one-time recitation download prompt — only World 2 needs the MP3s;
  /// World 1 (Qaida) uses on-device TTS, so the app opens straight into play.
  void _openLesson(BuildContext context, MapNode node) {
    Sfx.pop();
    final lesson = state.lessonForNode(node);
    void pushLesson() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LessonScreen(lesson: lesson, state: state),
        ),
      );
    }

    if (node.worldId == 'juzAmma' &&
        state.needsAudioDownload &&
        !_promptDismissed) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DownloadScreen(
            state: state,
            onDone: () {
              if (mounted) setState(() => _promptDismissed = true);
              Navigator.of(context).pop();
              pushLesson();
            },
          ),
        ),
      );
      return;
    }
    pushLesson();
  }

  void _openAudioDownload(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DownloadScreen(
          state: state,
          onDone: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!state.loaded) {
      if (state.loadError != null) {
        return Center(
            child: KidsIconLabel('sad', state.loadError!, iconSize: 40));
      }
      return const Center(child: CircularProgressIndicator());
    }
    if (!_focusScrolled) {
      _focusScrolled = true;
      final focus = widget.focusWorldId;
      if (focus != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final key = _worldKeys[focus];
          if (key?.currentContext != null) {
            Scrollable.ensureVisible(key!.currentContext!,
                duration: const Duration(milliseconds: 600),
                alignment: 0.1);
          }
        });
      }
    }
    // Lesson nodes scroll over the fixed 3D garden art (set on MapScreen).
    return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: state.worlds.length,
          itemBuilder: (context, wi) {
            final world = state.worlds[wi];
            final key = _worldKeys.putIfAbsent(world.id, () => GlobalKey());
            return Column(
              key: key,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(
                children: [
                  Expanded(
                    child: BubbleText(
                      world.titleIn(state.lang.code),
                      fontSize: 30,
                      textAlign: TextAlign.left,
                      gradientColors: const [
                        Color(0xFFFFFFFF),
                        Color(0xFFDFF3FF),
                        Color(0xFFBFE3F5),
                      ],
                      outlineColor: KidsTheme.tealDark,
                      depthColor: const Color(0xFF0E5A54),
                    ),
                  ),
                  if (world.id == 'juzAmma' && state.needsAudioDownload)
                    TextButton.icon(
                      onPressed: () => _openAudioDownload(context),
                      icon: const KidsIcon('download', size: 26),
                      label: const Text('Download',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800)),
                    ),
                ],
              ),
            ),
            ...world.nodes.map((n) {
              final idx = world.nodes.indexOf(n);
              final prevId = idx > 0 ? world.nodes[idx - 1].lessonId : null;
              return _NodeRow(
                state: state,
                node: n,
                unlocked: state.progress.isNodeUnlocked(
                  lessonId: n.lessonId,
                  prevLessonId: prevId,
                ),
                onOpenLesson: _openLesson,
              );
            }),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}

/// One shared white pill holding 1-3 big bare 3D stars (no per-star badges,
/// so the stars stay large enough to read as 3D). The star PNGs have baked
/// white backgrounds that blend into the pill.
class _StarPill extends StatelessWidget {
  final int count;
  const _StarPill({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFE9EEF5)],
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          count.clamp(1, 3),
          (_) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: ClipOval(
              child: Image(
                image: AssetImage('assets/icons/star.png'),
                width: 30,
                height: 30,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NodeRow extends StatelessWidget {  final GameState state;
  final MapNode node;
  final bool unlocked;
  final void Function(BuildContext context, MapNode node) onOpenLesson;

  const _NodeRow({
    required this.state,
    required this.node,
    required this.unlocked,
    required this.onOpenLesson,
  });

  @override
  Widget build(BuildContext context) {
    // Winding path: alternate left / center / right.
    final align = switch (node.order % 3) {
      0 => Alignment.centerLeft,
      1 => Alignment.center,
      _ => Alignment.centerRight,
    };
    final stars = state.progress.bestStars[node.lessonId] ?? 0;

    return Align(
      alignment: align,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
        child: GestureDetector(
          onTap: unlocked
              ? () => onOpenLesson(context, node)
              : () => Sfx.error(),
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: unlocked
                        ? const [
                            Color(0xFFFFD964),
                            KidsTheme.gold,
                            KidsTheme.goldDark
                          ]
                        : const [Color(0xFFE3E8EF), Color(0xFFC3CCD8)],
                  ),
                  border: Border.all(
                    color: node.isBoss ? KidsTheme.tealDark : Colors.white,
                    width: node.isBoss ? 5 : 4,
                  ),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4)),
                    BoxShadow(
                        color: Colors.white54,
                        blurRadius: 3,
                        offset: Offset(0, -3)),
                  ],
                ),
                child: Center(
                  child: unlocked
                      ? (stars > 0
                          ? _StarPill(count: stars)
                          : Text('${node.order + 1}',
                              style: const TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.w800)))
                      : const KidsIcon('lock', size: 56),
                ),
              ),
              if (node.isBoss && unlocked)
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: KidsIcon('crown', size: 34),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
