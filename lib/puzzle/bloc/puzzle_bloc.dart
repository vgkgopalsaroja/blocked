import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/level/level.dart';
import 'package:slide/models/models.dart';

part 'puzzle_state.dart';
part 'puzzle_event.dart';

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
