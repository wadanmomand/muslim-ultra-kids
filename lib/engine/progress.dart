// Muslim Ultra Kids — progress engine: XP, stars, streaks, unlocks.
// Pure Dart: no Flutter imports, fully unit-testable.

/// Stars earned per lesson completion (0-3).
int starsFor({required int correct, required int total}) {
  if (total <= 0) return 0;
  final ratio = correct / total;
  if (ratio >= 0.9) return 3;
  if (ratio >= 0.7) return 2;
  if (ratio >= 0.4) return 1;
  return 0;
}

/// XP: 10 per correct answer + completion bonus by stars.
int xpFor({required int correct, required int stars}) =>
    correct * 10 + stars * 5;

/// A child's profile progress. Persisted with Hive in Phase 3;
/// this class holds the pure rules.
class Progress {
  /// lessonId -> best stars (0-3).
  final Map<String, int> bestStars;

  /// Total XP earned.
  final int xp;

  /// Consecutive days with at least one completed lesson.
  final int streakDays;

  /// Last day (yyyy-MM-dd) a lesson was completed, for streak math.
  final String? lastActiveDay;

  /// Chosen reciter edition id, e.g. 'ar.alafasy'.
  final String reciterEdition;

  const Progress({
    this.bestStars = const {},
    this.xp = 0,
    this.streakDays = 0,
    this.lastActiveDay,
    this.reciterEdition = 'ar.alafasy',
  });

  /// Record a completed lesson. Returns the updated progress.
  Progress completeLesson({
    required String lessonId,
    required int correct,
    required int total,
    required String today, // yyyy-MM-dd
  }) {
    final stars = starsFor(correct: correct, total: total);
    final updated = Map<String, int>.of(bestStars);
    final prev = updated[lessonId] ?? 0;
    if (stars > prev) updated[lessonId] = stars;

    var streak = streakDays;
    if (lastActiveDay != today) {
      final yesterday = _dayBefore(today);
      streak = (lastActiveDay == yesterday) ? streak + 1 : 1;
    }

    return Progress(
      bestStars: updated,
      xp: xp + xpFor(correct: correct, stars: stars),
      streakDays: streak,
      lastActiveDay: today,
      reciterEdition: reciterEdition,
    );
  }

  /// Map nodes unlock in order: node N unlocks when node N-1 has >= 1 star.
  bool isNodeUnlocked({required int nodeOrder, required String worldId}) {
    if (nodeOrder == 0) return true;
    // Lesson ids follow '<worldId>-lesson-<order>' convention.
    final prevLessonId = '$worldId-lesson-${nodeOrder - 1}';
    return (bestStars[prevLessonId] ?? 0) >= 1;
  }

  Progress copyWith({String? reciterEdition}) => Progress(
        bestStars: bestStars,
        xp: xp,
        streakDays: streakDays,
        lastActiveDay: lastActiveDay,
        reciterEdition: reciterEdition ?? this.reciterEdition,
      );

  /// Lessons completed with at least 1 star.
  int get lessonsCompleted =>
      bestStars.values.where((s) => s >= 1).length;

  /// Total stars across all lessons.
  int get totalStars => bestStars.values.fold(0, (a, b) => a + b);

  Map<String, dynamic> toJson() => {
        'bestStars': bestStars,
        'xp': xp,
        'streakDays': streakDays,
        'lastActiveDay': lastActiveDay,
        'reciterEdition': reciterEdition,
      };

  factory Progress.fromJson(Map<String, dynamic> json) => Progress(
        bestStars: (json['bestStars'] as Map? ?? {})
            .map((k, v) => MapEntry(k as String, (v as num).toInt())),
        xp: (json['xp'] as num?)?.toInt() ?? 0,
        streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
        lastActiveDay: json['lastActiveDay'] as String?,
        reciterEdition: json['reciterEdition'] as String? ?? 'ar.alafasy',
      );

  static String _dayBefore(String yyyyMmDd) {
    final parts = yyyyMmDd.split('-').map(int.parse).toList();
    final d = DateTime(parts[0], parts[1], parts[2]).subtract(
      const Duration(days: 1),
    );
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }
}
