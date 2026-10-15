import 'package:flutter/foundation.dart';

import '../l10n/strings.dart';
import 'audio_pack.dart';
import 'audio_service.dart';
import 'lesson_loader.dart';
import 'models.dart';
import 'progress.dart';
import 'progress_store.dart';

/// App-level game state: content, progress, language, reciter, audio.
/// Persistence is on-device Hive (Phase 3). No backend.
class GameState extends ChangeNotifier {
  final LessonLoader loader;
  final ProgressStore store = ProgressStore();
  final AudioPackManager audioPacks = AudioPackManager();
  late final AudioService audio;

  GameState({LessonLoader? loader}) : loader = loader ?? LessonLoader() {
    audio = AudioService(audioPacks);
  }

  KidsLang lang = KidsLang.en;
  Progress progress = const Progress();
  List<World> worlds = [];
  Map<String, Lesson> lessons = {};
  bool loaded = false;
  bool audioReady = false;
  String? loadError;

  KidsStrings get strings => KidsStrings(lang);

  /// Ayahs the bundled lessons need (for the first-launch download).
  Set<int> get neededAyahs => AudioPackManager.neededAyahs(lessons);

  bool get needsAudioDownload =>
      loaded && neededAyahs.isNotEmpty && !audioPacks.isComplete;

  String today() {
    final n = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${n.year}-${two(n.month)}-${two(n.day)}';
  }

  Future<void> init() async {
    await store.init();
    progress = store.load();
    final savedLang = store.getSetting('lang');
    if (savedLang != null) {
      try {
        lang = KidsLang.values.byName(savedLang);
      } catch (_) {}
    }
    await audioPacks.init();
    await loadContent();
    audioReady = audioPacks.isComplete;
    notifyListeners();
  }

  Future<void> loadContent() async {
    try {
      const packs = [
        'assets/lessons/qaida.json',
        'assets/lessons/juz_amma.json',
      ];
      final allWorlds = <World>[];
      final allLessons = <String, Lesson>{};
      for (final path in packs) {
        final pack = await loader.load(path);
        allWorlds.addAll(pack.worlds);
        allLessons.addAll(pack.lessonsById);
      }
      worlds = allWorlds;
      lessons = allLessons;
      loaded = true;
    } catch (e) {
      loadError = e.toString();
    }
    notifyListeners();
  }

  void setLang(KidsLang l) {
    lang = l;
    store.setSetting('lang', l.code);
    notifyListeners();
  }

  void setReciter(String edition) {
    progress = progress.copyWith(reciterEdition: edition);
    store.save(progress);
    notifyListeners();
  }

  void completeLesson({
    required String lessonId,
    required int correct,
    required int total,
  }) {
    progress = progress.completeLesson(
      lessonId: lessonId,
      correct: correct,
      total: total,
      today: today(),
    );
    store.save(progress);
    notifyListeners();
  }

  Future<void> resetProgress() async {
    progress = const Progress();
    await store.clear();
    notifyListeners();
  }

  Future<void> markAudioReady() async {
    audioReady = true;
    notifyListeners();
  }

  Lesson lessonForNode(MapNode node) => lessons[node.lessonId]!;
}
