import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/puzzle/model/block.dart';
import 'package:slide/puzzle/model/position.dart';
import 'package:slide/puzzle/model/segment.dart';
import '../model/move_direction.dart';

part 'puzzle_state.dart';

class PuzzleBloc extends Bloc<PuzzleEvent, PuzzleState> {
  final PuzzleState initialState;

  PuzzleBloc(this.initialState) : super(initialState) {
    on<MoveAttempt>(_onMove);
    on<PuzzleReset>(_onReset);
  }

  void _onMove(MoveAttempt event, Emitter<PuzzleState> emit) {
    emit(state.withMoveAttempt(event));
  }

  void _onReset(PuzzleReset event, Emitter<PuzzleState> emit) {
    emit(initialState);
  }
}

abstract class PuzzleEvent {
  const PuzzleEvent();
}

class PuzzleReset extends PuzzleEvent {
  const PuzzleReset();
}

class MoveAttempt extends PuzzleEvent with EquatableMixin {
  const MoveAttempt(this.direction);

  final MoveDirection direction;

  Move blocked(PlacedBlock block) {
    return Move(block, direction, false);
  }

  Move moved(PlacedBlock block) {
    return Move(block, direction, true);
  }

  @override
  List<Object?> get props => [direction];
}

class Move extends MoveAttempt {
  const Move(this.block, MoveDirection direction, this.didMove)
      : super(direction);

  final PlacedBlock block;
  final bool didMove;

  @override
  List<Object?> get props => [block, direction, didMove];
}

extension on Segment {
  List<Segment> subtract(Segment segment) {
    if (segment.isVertical && isVertical && segment.start.x == start.x) {
      assert(start.y <= segment.start.y && end.y >= segment.end.y);
      return [
        Segment.vertical(x: start.x, start: start.y, end: segment.start.y),
        Segment.vertical(x: start.x, start: segment.end.y, end: end.y),
      ];
    } else if (segment.isHorizontal &&
        isHorizontal &&
        segment.start.y == start.y) {
      assert(start.x <= segment.start.x && end.x >= segment.end.x);
      return [
        Segment.horizontal(y: start.y, start: start.x, end: segment.start.x),
        Segment.horizontal(y: start.y, start: segment.end.x, end: end.x),
      ];
    } else {
      return [this];
    }
  }
}

extension MovePosition on Position {
  Position move(MoveDirection direction) {
    switch (direction) {
      case MoveDirection.up:
        return Position(x, y - 1);
      case MoveDirection.down:
        return Position(x, y + 1);
      case MoveDirection.left:
        return Position(x - 1, y);
      case MoveDirection.right:
        return Position(x + 1, y);
    }
  }
}

// abstract class PuzzleEvent {
//   const PuzzleEvent();
// }

// class ControlTransferred extends PuzzleEvent {
//   const ControlTransferred(this.target, this.move);
//   final PlacedBlock target;
//   final Move move;
// }

// class BlockMoved extends PuzzleEvent {
//   const BlockMoved(this.move);
//   final Move move;
// }