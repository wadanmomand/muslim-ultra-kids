// Muslim Ultra Kids — lesson engine models (Phase 1).
// Pure Dart: no Flutter imports, fully unit-testable.

/// The six lesson activity types from the game plan.
enum LessonType {
  listenRepeat,
  letterMatch,
  ayahOrder,
  missingWord,
  recitationChallenge,
  revisionDuel,
}

/// One node on the adventure map.
class MapNode {
  final String id;
  final String worldId;
  final int order;
  final String lessonId;
  final bool isBoss;

  const MapNode({
    required this.id,
    required this.worldId,
    required this.order,
    required this.lessonId,
    this.isBoss = false,
  });

  factory MapNode.fromJson(Map<String, dynamic> json) => MapNode(
        id: json['id'] as String,
        worldId: json['worldId'] as String,
        order: json['order'] as int,
        lessonId: json['lessonId'] as String,
        isBoss: json['isBoss'] as bool? ?? false,
      );
}

/// A world on the adventure map (Qaida / Juz Amma).
class World {
  final String id;
  final Map<String, String> title; // lang code -> title
  final List<MapNode> nodes;

  const World({required this.id, required this.title, required this.nodes});

  String titleIn(String langCode) => title[langCode] ?? title['en'] ?? id;

  factory World.fromJson(Map<String, dynamic> json) => World(
        id: json['id'] as String,
        title: Map<String, String>.from(json['title'] as Map),
        nodes: (json['nodes'] as List)
            .map((n) => MapNode.fromJson(n as Map<String, dynamic>))
            .toList(),
      );
}

/// One lesson's content. Quranic text fields carry exact script;
/// translations verified per the religious-accuracy rules.
class Lesson {
  final String id;
  final String worldId;
  final LessonType type;
  final Map<String, String> instruction; // lang -> instruction text
  final List<LessonStep> steps;

  const Lesson({
    required this.id,
    required this.worldId,
    required this.type,
    required this.instruction,
    required this.steps,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'] as String,
        worldId: json['worldId'] as String,
        type: LessonType.values.byName(json['type'] as String),
        instruction: Map<String, String>.from(json['instruction'] as Map),
        steps: (json['steps'] as List)
            .map((s) => LessonStep.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}

/// A single step inside a lesson.
class LessonStep {
  /// For Qaida: the letter/word. For Quran: exact ayah text (Uthmani).
  final String? text;

  /// 1-based ayah number inside the lesson's surah (Quran lessons).
  final int? ayahNumber;

  /// Global ayah number (1-6236) -> Islamic Network CDN audio file.
  final int? globalAyahNumber;

  /// Meaning per language, e.g. {'en': ..., 'ur': ..., 'ar': ...}.
  final Map<String, String> meaning;

  /// Transliteration for pre-readers.
  final String? transliteration;

  /// Step-specific payload (options for matching, shuffled order, etc.).
  final Map<String, dynamic> data;

  const LessonStep({
    this.text,
    this.ayahNumber,
    this.globalAyahNumber,
    this.meaning = const {},
    this.transliteration,
    this.data = const {},
  });

  factory LessonStep.fromJson(Map<String, dynamic> json) => LessonStep(
        text: json['text'] as String?,
        ayahNumber: json['ayahNumber'] as int?,
        globalAyahNumber: json['globalAyahNumber'] as int?,
        meaning: json['meaning'] == null
            ? const {}
            : Map<String, String>.from(json['meaning'] as Map),
        transliteration: json['transliteration'] as String?,
        data: json['data'] == null
            ? const {}
            : Map<String, dynamic>.from(json['data'] as Map),
      );

  /// CDN audio URL for this step's ayah (Islamic Network, locked source).
  /// Edition e.g. 'ar.alafasy' or 'ar.abdulbasitmurattal', bitrate 64.
  String? audioUrl(String edition, {int bitrate = 64}) {
    final n = globalAyahNumber;
    if (n == null) return null;
    return 'https://cdn.islamic.network/quran/audio/$bitrate/$edition/$n.mp3';
  }
}
