import 'package:async/async.dart';
import 'package:blocked/models/models.dart';
import 'package:blocked/puzzle/puzzle.dart';
import 'package:blocked/solver/solver.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'puzzle_solver_event.dart';
part 'puzzle_solver_state.dart';

class PuzzleSolverBloc extends Bloc<PuzzleSolverEvent, PuzzleSolverState> {
  PuzzleSolverBloc(this.levelBloc) : super(const PuzzleSolverState.initial()) {
    on<SolutionViewed>(_onSolutionViewed);
    on<SolutionPlayed>(_onSolutionPlayed);
    on<SolutionHidden>(_onSolutionHidden);
  }

  final LevelBloc levelBloc;

  void _onSolutionViewed(
      SolutionViewed event, Emitter<PuzzleSolverState> emit) {
    emit(state
        .copyWithSolutionFor(levelBloc.initialState.puzzle)
        .copyWithSolutionViewed(true));
  }

  void _onSolutionPlayed(
      SolutionPlayed event, Emitter<PuzzleSolverState> emit) {
    final newState = state.copyWithSolutionFor(levelBloc.initialState.puzzle);
    final moves = newState.solution!;

    Future<void> runSolution() async {
      final isInitialState =
          levelBloc.state.puzzle == levelBloc.initialState.puzzle;

      if (!isInitialState) {
        levelBloc.add(const LevelReset());
        await Future.delayed(kSlideDuration * 1.5);
      }

      for (var move in moves) {
        levelBloc.add(MoveAttempt(move));
        await Future.delayed(kSlideDuration * 1.5);
      }
    }

    // Create cancellable operation
    final solutionPlayback = CancelableOperation.fromFuture(runSolution());
    emit(newState.copyWithSolutionPlaying(solutionPlayback));
  }

  void _onSolutionHidden(
      SolutionHidden event, Emitter<PuzzleSolverState> emit) {
    emit(state.copyWithSolutionViewed(false));
  }

  @override
  Future<void> close() async {
    await state.solutionPlayback?.cancel();
    return super.close();
  }
}
