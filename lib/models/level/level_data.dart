import 'package:slide/level/level.dart';
import 'package:slide/models/models.dart';

class LevelData {
  const LevelData({
    required this.name,
    this.hint,
    required this.map,
  });

  final String name;
  final String? hint;
  final String map;

  Level toLevel() {
    return Level(
      name,
      hint: hint,
      initialState: LevelReader.parseLevel(map),
    );
  }
}
