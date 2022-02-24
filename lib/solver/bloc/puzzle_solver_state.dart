part of 'puzzle_solver_bloc.dart';

class PuzzleSolverState {
  const PuzzleSolverState.initial()
      : solution = null,
        hasSolutionResult = false,
        isSolutionViewed = false,
        solutionPlayback = null;
  const PuzzleSolverState({
    required this.solution,
    required this.hasSolutionResult,
    required this.isSolutionViewed,
    required this.solutionPlayback,
  });

  final List<MoveDirection>? solution;
  final bool hasSolutionResult;
  final bool isSolutionViewed;
  final CancelableOperation? solutionPlayback;

  PuzzleSolverState copyWithSolutionFor(PuzzleState puzzleState) {
    if (hasSolutionResult) {
      return this;
    }
    final puzzleSolver = PuzzleSolver(puzzleState);
    return PuzzleSolverState(
        solution: puzzleSolver.solve(),
        hasSolutionResult: true,
        isSolutionViewed: isSolutionViewed,
        solutionPlayback: null);
  }

  PuzzleSolverState copyWithSolutionPlaying(
      CancelableOperation solutionPlayback) {
    return PuzzleSolverState(
        solution: solution,
        hasSolutionResult: hasSolutionResult,
        isSolutionViewed: isSolutionViewed,
        solutionPlayback: solutionPlayback);
  }

  PuzzleSolverState copyWithSolutionViewed({required bool viewed}) {
    return PuzzleSolverState(
        solution: solution,
        hasSolutionResult: hasSolutionResult,
        isSolutionViewed: viewed,
        solutionPlayback: solutionPlayback);
  }
}
