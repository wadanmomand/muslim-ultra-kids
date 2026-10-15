import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'models.dart';

/// Loads and validates lesson content JSON from bundled assets.
/// Schema: { "worlds": [World], "lessons": [Lesson] }
class LessonLoader {
  final Future<String> Function(String path) readAsset;

  LessonLoader({Future<String> Function(String path)? readAsset})
      : readAsset = readAsset ?? rootBundle.loadString;

  Future<ContentPack> load(String assetPath) async {
    final raw = await readAsset(assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return ContentPack.parse(json);
  }
}

/// Validated, ready-to-use content.
class ContentPack {
  final List<World> worlds;
  final Map<String, Lesson> lessonsById;

  ContentPack({required this.worlds, required this.lessonsById});

  factory ContentPack.parse(Map<String, dynamic> json) {
    final worlds = (json['worlds'] as List)
        .map((w) => World.fromJson(w as Map<String, dynamic>))
        .toList();
    final lessons = (json['lessons'] as List)
        .map((l) => Lesson.fromJson(l as Map<String, dynamic>))
        .toList();

    final byId = <String, Lesson>{};
    for (final lesson in lessons) {
      if (byId.containsKey(lesson.id)) {
        throw FormatException('Duplicate lesson id: ${lesson.id}');
      }
      byId[lesson.id] = lesson;
    }

    // Every map node must point at a real lesson.
    for (final world in worlds) {
      for (final node in world.nodes) {
        if (!byId.containsKey(node.lessonId)) {
          throw FormatException(
            'Node ${node.id} references missing lesson ${node.lessonId}',
          );
        }
      }
    }

    return ContentPack(worlds: worlds, lessonsById: byId);
  }

  Lesson lessonForNode(MapNode node) => lessonsById[node.lessonId]!;
}
