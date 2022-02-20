import 'package:slide/puzzle/puzzle.dart';

class Level {
  const Level(this.name, {this.hint, required this.initialState});

  final String name;
  final String? hint;
  final LevelState initialState;
}
