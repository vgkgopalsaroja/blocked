import 'package:slide/puzzle/bloc/puzzle_bloc.dart';

class Level {
  const Level(this.name, {this.hint, required this.initialState});

  final String name;
  final String? hint;
  final PuzzleState initialState;
}
