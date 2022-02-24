import 'dart:math';

import 'package:blocked/models/models.dart';
import 'package:blocked/puzzle/puzzle.dart';
import 'package:collection/collection.dart';

class PuzzleSolver {
  PuzzleSolver(this.initialState);

  final PuzzleState initialState;

  List<MoveDirection>? solve() {
    final frontier = PriorityQueue<_PuzzleNode>();
    final visitedStates = <PuzzleState>{};
    frontier.add(_PuzzleNode(initialState, null, null, 0, h(initialState)));
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
          frontier.add(_PuzzleNode(nextState, current, moveDirection,
              current.moveCount + 1, h(nextState)));
        }
      }
    }
    return null;
  }

  int h(PuzzleState state) {
    final mainBlock = state.mainBlock;
    final controlledBlock = state.controlledBlock;
    final distanceToControlledBlock =
        getManhattanDistance(mainBlock.position, controlledBlock.position);
    final minDistanceX = min(mainBlock.left + 1, state.width - mainBlock.right);
    final minDistanceY =
        min(mainBlock.top + 1, state.height - mainBlock.bottom);
    final mainBlockMinDistanceToWall = min(minDistanceX, minDistanceY);
    return distanceToControlledBlock + mainBlockMinDistanceToWall;
  }

  int getManhattanDistance(Position position1, Position position2) {
    return (position1.x - position2.x).abs() +
        (position1.y - position2.y).abs();
  }
}

class _PuzzleNode extends Comparable<_PuzzleNode> {
  _PuzzleNode(
      this.state, this.parent, this.moveDirection, this.moveCount, this.hValue);

  final PuzzleState state;
  final _PuzzleNode? parent;
  final MoveDirection? moveDirection;
  final int moveCount;
  final int hValue;

  List<MoveDirection> get moves =>
      (parent?.moves ?? []) + (moveDirection != null ? [moveDirection!] : []);
  bool get isGoal => state.isCompleted;

  @override
  int compareTo(_PuzzleNode other) {
    return (moveCount - other.moveCount) + (hValue - other.hValue);
  }
}
