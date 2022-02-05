import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/puzzle/model/block.dart';
import 'package:slide/puzzle/model/position.dart';
import 'package:slide/puzzle/model/segment.dart';
import '../model/move_direction.dart';

part 'puzzle_state.dart';

class PuzzleBloc extends Bloc<PuzzleEvent, PuzzleState> {
  final PuzzleState initialState;
  final VoidCallback onNext;
  final VoidCallback onExit;

  PuzzleBloc(this.initialState, {required this.onNext, required this.onExit})
      : super(initialState) {
    on<MoveAttempt>(_onMove);
    on<PuzzleReset>(_onReset);
    on<PuzzleExited>(_onExit);
    on<NextPuzzle>(_onNext);
  }

  void _onMove(MoveAttempt event, Emitter<PuzzleState> emit) {
    if (!state.isCompleted) {
      emit(state.withMoveAttempt(event));
    }
  }

  void _onReset(PuzzleReset event, Emitter<PuzzleState> emit) {
    emit(initialState);
  }

  void _onNext(NextPuzzle event, Emitter<PuzzleState> emit) {
    if (state.isCompleted) {
      onNext.call();
    }
  }

  void _onExit(PuzzleExited event, Emitter<PuzzleState> emit) {
    onExit.call();
  }
}

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
