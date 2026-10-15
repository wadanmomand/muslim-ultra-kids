import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_ultra_kids/engine/lesson_loader.dart';
import 'package:muslim_ultra_kids/engine/models.dart';
import 'package:muslim_ultra_kids/engine/progress.dart';
import 'package:muslim_ultra_kids/l10n/strings.dart';
import 'package:muslim_ultra_kids/engine/audio_pack.dart';
import 'package:muslim_ultra_kids/engine/daily_ayah.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('starsFor', () {
    test('3 stars at >= 90%', () {
      expect(starsFor(correct: 9, total: 10), 3);
      expect(starsFor(correct: 10, total: 10), 3);
    });
    test('2 stars at >= 70%', () {
      expect(starsFor(correct: 7, total: 10), 2);
    });
    test('1 star at >= 40%', () {
      expect(starsFor(correct: 4, total: 10), 1);
    });
    test('0 stars below 40% and empty', () {
      expect(starsFor(correct: 3, total: 10), 0);
      expect(starsFor(correct: 0, total: 0), 0);
    });
  });

  group('xpFor', () {
    test('10 per correct + 5 per star', () {
      expect(xpFor(correct: 8, stars: 2), 90);
    });
  });

  group('Progress.completeLesson', () {
    test('records best stars and xp', () {
      final p = const Progress().completeLesson(
        lessonId: 'qaida-lesson-0',
        correct: 9,
        total: 10,
        today: '2026-10-12',
      );
      expect(p.bestStars['qaida-lesson-0'], 3);
      expect(p.xp, 9 * 10 + 3 * 5);
      expect(p.streakDays, 1);
    });

    test('keeps higher stars on replay', () {
      var p = const Progress().completeLesson(
        lessonId: 'qaida-lesson-0',
        correct: 5,
        total: 10,
        today: '2026-10-12',
      );
      expect(p.bestStars['qaida-lesson-0'], 1);
      p = p.completeLesson(
        lessonId: 'qaida-lesson-0',
        correct: 10,
        total: 10,
        today: '2026-10-12',
      );
      expect(p.bestStars['qaida-lesson-0'], 3);
    });

    test('streak grows on consecutive days, resets on gap', () {
      var p = const Progress().completeLesson(
        lessonId: 'l1',
        correct: 10,
        total: 10,
        today: '2026-10-10',
      );
      expect(p.streakDays, 1);
      p = p.completeLesson(
        lessonId: 'l2',
        correct: 10,
        total: 10,
        today: '2026-10-11',
      );
      expect(p.streakDays, 2);
      p = p.completeLesson(
        lessonId: 'l3',
        correct: 10,
        total: 10,
        today: '2026-10-20',
      );
      expect(p.streakDays, 1);
    });

    test('same-day replay does not inflate streak', () {
      var p = const Progress().completeLesson(
        lessonId: 'l1',
        correct: 10,
        total: 10,
        today: '2026-10-12',
      );
      p = p.completeLesson(
        lessonId: 'l2',
        correct: 10,
        total: 10,
        today: '2026-10-12',
      );
      expect(p.streakDays, 1);
    });
  });

  group('Progress.isNodeUnlocked', () {
    test('first node always unlocked; next needs 1 star', () {
      const p = Progress();
      expect(p.isNodeUnlocked(nodeOrder: 0, worldId: 'qaida'), isTrue);
      expect(p.isNodeUnlocked(nodeOrder: 1, worldId: 'qaida'), isFalse);

      final p2 = p.completeLesson(
        lessonId: 'qaida-lesson-0',
        correct: 5,
        total: 10,
        today: '2026-10-12',
      );
      expect(p2.isNodeUnlocked(nodeOrder: 1, worldId: 'qaida'), isTrue);
    });
  });

  group('LessonStep.audioUrl', () {
    test('builds Islamic Network CDN url', () {
      const step = LessonStep(globalAyahNumber: 262);
      expect(
        step.audioUrl('ar.alafasy'),
        'https://cdn.islamic.network/quran/audio/64/ar.alafasy/262.mp3',
      );
      expect(
        step.audioUrl('ar.abdulbasitmurattal', bitrate: 128),
        'https://cdn.islamic.network/quran/audio/128/ar.abdulbasitmurattal/262.mp3',
      );
    });
    test('null when no ayah', () {
      expect(const LessonStep().audioUrl('ar.alafasy'), isNull);
    });
  });

  group('LessonLoader', () {
    const valid = '''
{"worlds":[{"id":"w","title":{"en":"W"},"nodes":[
{"id":"n0","worldId":"w","order":0,"lessonId":"w-lesson-0"},
{"id":"n1","worldId":"w","order":1,"lessonId":"w-lesson-1"}]}],
"lessons":[
{"id":"w-lesson-0","worldId":"w","type":"listenRepeat",
"instruction":{"en":"x"},"steps":[{"text":"ا"}]},
{"id":"w-lesson-1","worldId":"w","type":"letterMatch",
"instruction":{"en":"y"},"steps":[]}]}
''';

    test('loads valid pack', () async {
      final loader = LessonLoader(readAsset: (_) async => valid);
      final pack = await loader.load('x.json');
      expect(pack.worlds.length, 1);
      expect(pack.lessonsById.length, 2);
      expect(
        pack.lessonForNode(pack.worlds.first.nodes.first).id,
        'w-lesson-0',
      );
    });

    test('rejects duplicate lesson ids', () async {
      final dup = valid.replaceAll('"w-lesson-1"', '"w-lesson-0"');
      final loader = LessonLoader(readAsset: (_) async => dup);
      expect(() => loader.load('x.json'), throwsFormatException);
    });

    test('rejects node pointing at missing lesson', () async {
      final bad = valid.replaceAll('"lessonId":"w-lesson-1"', '"lessonId":"nope"');
      final loader = LessonLoader(readAsset: (_) async => bad);
      expect(() => loader.load('x.json'), throwsFormatException);
    });
  });

  group('KidsStrings', () {
    test('every key translated in all languages', () {
      for (final entry in KidsStrings.table.entries) {
        for (final lang in KidsLang.values) {
          expect(
            entry.value[lang],
            isNotNull,
            reason: 'key ${entry.key} missing ${lang.code}',
          );
          expect(entry.value[lang]!.isNotEmpty, isTrue);
        }
      }
    });
  });

  group('Progress JSON round-trip (Hive persistence)', () {
    test('toJson/fromJson preserves all fields', () {
      final p = Progress(
        bestStars: {'qaida-0': 3, 'qaida-1': 2},
        xp: 150,
        streakDays: 4,
        lastActiveDay: '2026-10-12',
        reciterEdition: 'ar.abdulbasitmurattal',
      );
      final back = Progress.fromJson(p.toJson());
      expect(back.bestStars, {'qaida-0': 3, 'qaida-1': 2});
      expect(back.xp, 150);
      expect(back.streakDays, 4);
      expect(back.lastActiveDay, '2026-10-12');
      expect(back.reciterEdition, 'ar.abdulbasitmurattal');
    });

    test('fromJson tolerates missing/corrupt data', () {
      final back = Progress.fromJson({});
      expect(back.xp, 0);
      expect(back.reciterEdition, 'ar.alafasy');
    });

    test('stats helpers', () {
      final p = Progress(
        bestStars: {'a': 3, 'b': 0, 'c': 2},
        xp: 50,
        streakDays: 1,
        lastActiveDay: '2026-10-12',
      );
      expect(p.lessonsCompleted, 2);
      expect(p.totalStars, 5);
    });
  });

  group('AudioPackManager.neededAyahs', () {
    test('collects global ayah numbers, skips letter steps', () {
      final lessons = {
        'l1': Lesson(
          id: 'l1',
          worldId: 'w',
          type: LessonType.listenRepeat,
          instruction: const {'en': 'x'},
          steps: [
            LessonStep(text: 'x', globalAyahNumber: 1),
            LessonStep(text: 'y', globalAyahNumber: 6222),
            const LessonStep(text: 'ب'), // letter: no ayah
          ],
        ),
      };
      expect(AudioPackManager.neededAyahs(lessons), {1, 6222});
    });
  });

  group('ayahForDate', () {
    test('deterministic for the same date', () {
      final d = DateTime(2026, 10, 12);
      expect(ayahForDate(d).text, ayahForDate(d).text);
    });

    test('all entries have meanings in 3 languages', () {
      for (final a in dailyAyahs) {
        for (final lang in KidsLang.values) {
          expect(a.meaningIn(lang.code).isNotEmpty, isTrue);
        }
      }
    });

    test('30 daily ayahs in rotation', () {
      expect(dailyAyahs.length, 30);
    });
  });

  group('Full content packs (bundled assets)', () {
    test('qaida pack: 30 lessons, 30 nodes, boss quizzes', () async {
      final raw = await rootBundle.loadString('assets/lessons/qaida.json');
      final pack =
          ContentPack.parse(jsonDecode(raw) as Map<String, dynamic>);
      expect(pack.worlds.length, 1);
      expect(pack.worlds.first.id, 'qaida');
      expect(pack.lessonsById.length, 30);
      expect(pack.worlds.first.nodes.length, 30);
      // every node resolves to a real lesson (loader validates this too)
      for (final node in pack.worlds.first.nodes) {
        expect(pack.lessonForNode(node).id, node.lessonId);
      }
      // boss crowns on the two quizzes + final lesson
      final bosses = pack.worlds.first.nodes.where((n) => n.isBoss);
      expect(bosses.length, 3);
      // 28 letters taught (L29 covers the last two in one lesson)
      final taughtLetters = <String>{};
      for (final l in pack.lessonsById.values) {
        for (final s in l.steps) {
          final name = s.data['letterName'];
          if (name is String) taughtLetters.add(name);
        }
      }
      expect(taughtLetters.length, 28);
    });

    test('juz amma pack: 76 lessons, 571 ayahs with audio numbers', () async {
      final raw = await rootBundle.loadString('assets/lessons/juz_amma.json');
      final pack =
          ContentPack.parse(jsonDecode(raw) as Map<String, dynamic>);
      expect(pack.worlds.length, 1);
      expect(pack.lessonsById.length, 76);
      expect(pack.worlds.first.nodes.length, 76);
      var ayahCount = 0;
      for (final lesson in pack.lessonsById.values) {
        if (lesson.worldId == 'juzAmma' &&
            lesson.type == LessonType.listenRepeat) {
          for (final s in lesson.steps) {
            expect(s.text, isNotEmpty);
            expect(s.globalAyahNumber, isNotNull);
            expect(s.globalAyahNumber! > 0, isTrue);
            expect(s.meaning['en'], isNotEmpty);
            ayahCount++;
          }
        }
      }
      expect(ayahCount, 571);
      // Al-Fatiha keeps its Bismillah as ayah 1; others are stripped
      final fatiha = pack.lessonsById['juz-surah-001']!;
      expect(fatiha.steps.first.text, contains('بِسْمِ'));
      final ikhlas = pack.lessonsById['juz-surah-112']!;
      expect(ikhlas.steps.first.text, isNot(contains('بِسْمِ')));
    });
  });
}
