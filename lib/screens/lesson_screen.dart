import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../ads/ads_service.dart';
import '../engine/game_state.dart';
import '../engine/models.dart';
import '../engine/progress.dart';
import '../engine/sfx.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import '../widgets/companion.dart';
import '../widgets/kids_icon.dart';
import '../widgets/mini_games.dart';

/// Plays one lesson step-by-step, then shows the star result.
/// No interstitial ads here — Families rule (locked): lessons stay ad-free.
class LessonScreen extends StatefulWidget {
  final Lesson lesson;
  final GameState state;

  const LessonScreen({super.key, required this.lesson, required this.state});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _stepIndex = 0;
  int _correct = 0;

  void _onStepDone(bool correct) {
    if (correct) _correct++;
    if (_stepIndex + 1 < widget.lesson.steps.length) {
      setState(() => _stepIndex++);
    } else {
      _finish();
    }
  }

  void _finish() {
    final total = widget.lesson.steps.length;
    final stars = starsFor(correct: _correct, total: total);
    final xp = xpFor(correct: _correct, stars: stars);
    Sfx.success();
    widget.state.completeLesson(
      lessonId: widget.lesson.id,
      correct: _correct,
      total: total,
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResultDialog(
        stars: stars,
        xp: xp,
        onReplay: () {
          Navigator.of(context).pop(); // close dialog
          setState(() {
            _stepIndex = 0;
            _correct = 0;
          });
        },
        onMap: () {
          Navigator.of(context).pop(); // close dialog
          Navigator.of(context).pop(); // back to map
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = widget.state.strings;
    final step = widget.lesson.steps[_stepIndex];
    final total = widget.lesson.steps.length;

    Widget game;
    switch (widget.lesson.type) {
      case LessonType.listenRepeat:
        game = ListenRepeatGame(
          step: step,
          audio: widget.state.audio,
          reciterEdition: widget.state.progress.reciterEdition,
          strings: strings,
          onDone: _onStepDone,
        );
      case LessonType.letterMatch:
        game = LetterMatchGame(
            step: step, strings: strings, onDone: _onStepDone);
      case LessonType.ayahOrder:
        game = AyahOrderGame(
          step: step,
          correctOrder:
              widget.lesson.steps.map((s) => s.text ?? '').toList(),
          strings: strings,
          onDone: _onStepDone,
        );
      case LessonType.missingWord:
        game = MissingWordGame(
            step: step, strings: strings, onDone: _onStepDone);
      case LessonType.recitationChallenge:
        game = ListenRepeatGame(
          step: step,
          audio: widget.state.audio,
          reciterEdition: widget.state.progress.reciterEdition,
          strings: strings,
          onDone: _onStepDone,
        );
      case LessonType.revisionDuel:
        game = LetterMatchGame(
            step: step, strings: strings, onDone: _onStepDone);
    }

    return Scaffold(
      appBar: AppBar(
        title: _ProgressDots(index: _stepIndex, total: total),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: KidsTheme.bgFor(widget.state.isDark)),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              CompanionBubble(
                text: widget.lesson.instruction[strings.lang.code] ??
                    widget.lesson.instruction['en']!,
              ),
              const SizedBox(height: 12),
              game,
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  final int index;
  final int total;
  const _ProgressDots({required this.index, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final done = i < index;
        final current = i == index;
        return Container(
          width: current ? 26 : 12,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: done
                ? KidsTheme.gold
                : current
                    ? KidsTheme.teal
                    : KidsTheme.starGrey,
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _ResultDialog extends StatelessWidget {
  final int stars;
  final int xp;
  final VoidCallback onReplay;
  final VoidCallback onMap;

  const _ResultDialog({
    required this.stars,
    required this.xp,
    required this.onReplay,
    required this.onMap,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Companion(size: 84, happy: true),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final earned = i < stars;
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: earned ? 1 : 0.4),
                duration: Duration(milliseconds: 300 + i * 250),
                builder: (_, v, _) => Transform.scale(
                  scale: v,
                  child: Opacity(
                    opacity: earned ? 1.0 : 0.35,
                    child: const KidsIcon('star', size: 56),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            '+$xp XP',
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: KidsTheme.tealDark),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: onReplay,
                  child: const KidsIcon('replay', size: 28)),
              ElevatedButton(
                onPressed: onMap,
                style: ElevatedButton.styleFrom(
                    backgroundColor: KidsTheme.teal,
                    foregroundColor: Colors.white),
                child: const KidsIcon('map', size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Banner ad footer for map/home screens (lessons stay ad-free).
class BannerAdFooter extends StatefulWidget {
  const BannerAdFooter({super.key});

  @override
  State<BannerAdFooter> createState() => _BannerAdFooterState();
}

class _BannerAdFooterState extends State<BannerAdFooter> {
  BannerAd? _ad;

  @override
  void initState() {
    super.initState();
    _ad = KidsAds.createBanner(onLoaded: () {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null) return const SizedBox.shrink();
    return SafeArea(
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
