import 'package:collection/collection.dart';
import 'package:slide/models/models.dart';
import 'package:slide/puzzle/puzzle.dart';

class PuzzleSolver {
  PuzzleSolver(this.initialState);

  final PuzzleState initialState;

  List<MoveDirection>? solve() {
    final frontier = PriorityQueue<_PuzzleNode>();
    final visitedStates = <PuzzleState>{};
    frontier.add(_PuzzleNode(initialState, null, null, 0));
    visitedStates.add(initialState);
    if (initialState.isCompleted) {
      return [];
    }
    while (frontier.isNotEmpty) {
      final current = frontier.removeFirst();
      for (var moveDirection in MoveDirection.values) {
        final nextState =
            current.state.withMoveAttempt(MoveAttempt(moveDirection));
        if (nextState.isCompleted) {
          return current.moves + [moveDirection];
        }
        if (!visitedStates.contains(nextState)) {
          visitedStates.add(nextState);
          frontier.add(_PuzzleNode(
              nextState, current, moveDirection, current.moveCount + 1));
        }
      }
    }
    return null;
  }
}

class _PuzzleNode extends Comparable<_PuzzleNode> {
  _PuzzleNode(this.state, this.parent, this.moveDirection, this.moveCount);

  final PuzzleState state;
  final _PuzzleNode? parent;
  final MoveDirection? moveDirection;
  final int moveCount;

  List<MoveDirection> get moves =>
      (parent?.moves ?? []) + (moveDirection != null ? [moveDirection!] : []);
  bool get isGoal => state.isCompleted;

  @override
  int compareTo(_PuzzleNode other) {
    return moveCount - other.moveCount;
  }
}
