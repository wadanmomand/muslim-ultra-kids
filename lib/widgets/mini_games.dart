import 'package:flutter/material.dart';

import '../engine/audio_service.dart';
import '../engine/models.dart';
import '../engine/sfx.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import 'kids_icon.dart';

/// Shared bits for the four lesson mini-games (Phase 2).
/// Each game reports onDone(true/false); scoring counts first-try success.

class _OptionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _OptionChip({required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.white,
          foregroundColor: KidsTheme.ink,
          textStyle: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        ),
        onPressed: () {
          Sfx.pop();
          onTap();
        },
        child: Text(label, textDirection: TextDirection.rtl),
      ),
    );
  }
}

/// Big display text for a step (letter or ayah).
class StepDisplay extends StatelessWidget {
  final LessonStep step;

  const StepDisplay({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        children: [
          if (step.text != null)
            Text(
              step.text!,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w700),
            ),
          if (step.transliteration != null) ...[
            const SizedBox(height: 8),
            Text(
              step.transliteration!,
              style: const TextStyle(
                  fontSize: 20, color: KidsTheme.tealDark,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}

/// Type 1: listen to the recitation, then tap "I did it".
/// Audio is local-first (downloaded pack) with CDN streaming fallback.
class ListenRepeatGame extends StatefulWidget {
  final LessonStep step;
  final AudioService audio;
  final String reciterEdition;
  final KidsStrings strings;
  final void Function(bool correct) onDone;

  const ListenRepeatGame({
    super.key,
    required this.step,
    required this.audio,
    required this.reciterEdition,
    required this.strings,
    required this.onDone,
  });

  @override
  State<ListenRepeatGame> createState() => _ListenRepeatGameState();
}

class _ListenRepeatGameState extends State<ListenRepeatGame> {
  bool _playing = false;
  bool _hasAudio = false;

  @override
  void initState() {
    super.initState();
    widget.audio
        .resolve(widget.step, widget.reciterEdition)
        .then((src) => mounted ? setState(() => _hasAudio = src != null) : null);
  }

  Future<void> _listen() async {
    final src =
        await widget.audio.resolve(widget.step, widget.reciterEdition);
    if (src == null || !mounted) return;
    setState(() => _playing = true);
    try {
      await widget.audio.play(src);
    } finally {
      if (mounted) setState(() => _playing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StepDisplay(step: widget.step),
        if (_hasAudio)
          ElevatedButton.icon(
            onPressed: _playing ? null : _listen,
            icon: KidsIcon(_playing ? 'hourglass' : 'speaker', size: 28),
            label: Text(widget.strings.get('listen')),
          ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            Sfx.star();
            widget.onDone(true);
          },
          child: KidsIconLabel(
              'star', widget.strings.get('repeatAfterMe'),
              iconSize: 28),
        ),
      ],
    );
  }
}

/// Type 2: hear/read the prompt, tap the matching option.
class LetterMatchGame extends StatefulWidget {
  final LessonStep step;
  final KidsStrings strings;
  final void Function(bool correct) onDone;

  const LetterMatchGame({
    super.key,
    required this.step,
    required this.strings,
    required this.onDone,
  });

  @override
  State<LetterMatchGame> createState() => _LetterMatchGameState();
}

class _LetterMatchGameState extends State<LetterMatchGame> {
  int _attempts = 0;
  String? _wrong;

  @override
  Widget build(BuildContext context) {
    final options =
        (widget.step.data['options'] as List?)?.cast<String>() ?? [];
    final answer = widget.step.data['answer'] as String?;
    return Column(
      children: [
        if (widget.step.transliteration != null)
          Text(
            widget.step.transliteration!,
            style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: KidsTheme.tealDark),
          ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          children: options.map((o) {
            final isWrong = _wrong == o;
            return _OptionChip(
              label: o,
              color: isWrong ? const Color(0xFFFFCDD2) : null,
              onTap: () {
                setState(() => _attempts++);
                if (o == answer) {
                  Sfx.star();
                  widget.onDone(_attempts == 1);
                } else {
                  Sfx.error();
                  setState(() => _wrong = o);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Type 3: tap the ayat chips in the correct order.
class AyahOrderGame extends StatefulWidget {
  final LessonStep step;
  final List<String> correctOrder;
  final KidsStrings strings;
  final void Function(bool correct) onDone;

  const AyahOrderGame({
    super.key,
    required this.step,
    required this.correctOrder,
    required this.strings,
    required this.onDone,
  });

  @override
  State<AyahOrderGame> createState() => _AyahOrderGameState();
}

class _AyahOrderGameState extends State<AyahOrderGame> {
  final List<String> _picked = [];
  int _attempts = 0;

  @override
  Widget build(BuildContext context) {
    final shuffled =
        (widget.step.data['shuffled'] as List?)?.cast<String>() ?? [];
    final remaining =
        shuffled.where((s) => !_picked.contains(s)).toList();
    return Column(
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 90),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Wrap(
            children: _picked
                .map((p) => Chip(
                      label: Text(p, textDirection: TextDirection.rtl),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          children: remaining
              .map((s) => _OptionChip(
                    label: s,
                    onTap: () {
                      setState(() => _picked.add(s));
                      if (_picked.length == widget.correctOrder.length) {
                        _attempts++;
                        final ok = _picked.join('|') ==
                            widget.correctOrder.join('|');
                        if (ok) {
                          Sfx.star();
                          widget.onDone(_attempts == 1);
                        } else {
                          Sfx.error();
                          setState(_picked.clear);
                        }
                      }
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }
}

/// Type 4: fill the missing word from options.
class MissingWordGame extends StatefulWidget {
  final LessonStep step;
  final KidsStrings strings;
  final void Function(bool correct) onDone;

  const MissingWordGame({
    super.key,
    required this.step,
    required this.strings,
    required this.onDone,
  });

  @override
  State<MissingWordGame> createState() => _MissingWordGameState();
}

class _MissingWordGameState extends State<MissingWordGame> {
  int _attempts = 0;

  @override
  Widget build(BuildContext context) {
    final sentence = widget.step.data['sentence'] as String? ?? '___';
    final options =
        (widget.step.data['options'] as List?)?.cast<String>() ?? [];
    final answer = widget.step.data['answer'] as String?;
    return Column(
      children: [
        Text(
          sentence,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          children: options
              .map((o) => _OptionChip(
                    label: o,
                    onTap: () {
                      _attempts++;
                      if (o == answer) {
                        Sfx.star();
                        widget.onDone(_attempts == 1);
                      } else {
                        Sfx.error();
                      }
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }
}
