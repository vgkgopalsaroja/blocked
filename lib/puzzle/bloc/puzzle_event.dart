part of 'puzzle_bloc.dart';

abstract class PuzzleEvent {
  const PuzzleEvent();
}

class PuzzleReset extends PuzzleEvent {
  const PuzzleReset();
}

class PuzzleExited extends PuzzleEvent {
  const PuzzleExited();
}

class NextPuzzle extends PuzzleEvent {
  const NextPuzzle();
}

class MoveAttempt extends PuzzleEvent {
  const MoveAttempt(this.direction);

  final MoveDirection direction;

  Move blocked(PlacedBlock block) {
    return Move._(block, direction, false);
  }

  Move moved(PlacedBlock block) {
    return Move._(block, direction, true);
  }
}

class Move extends MoveAttempt {
  const Move._(this.block, MoveDirection direction, this.didMove)
      : super(direction);

  final PlacedBlock block;
  final bool didMove;
}
