import 'package:slide/models/models.dart';

class LevelChapter {
  LevelChapter(this.name, this.description, this.levels);

  final String name;
  final String description;
  final List<LevelData> levels;
}
