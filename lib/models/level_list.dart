import 'package:collection/collection.dart';
import 'package:slide/level/level.dart';

class LevelList {
  final List<LevelData> levels;

  LevelList(this.levels);

  LevelData? getLevelWithId(String id) {
    return levels.where((level) => level.name == id).firstOrNull;
  }

  LevelData? getLevelAfterId(String id) {
    return levels.skipWhile((level) => level.name != id).skip(1).firstOrNull;
  }
}
