import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/puzzle/puzzle.dart';
import 'package:slide/solver/solver.dart';

class BoardControls extends StatelessWidget {
  const BoardControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCompleted =
        context.select((PuzzleBloc bloc) => bloc.state.isCompleted);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to puzzle selection (Esc)',
          onPressed: () {
            context.read<PuzzleBloc>().add(const PuzzleExited());
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Reset (R)',
          onPressed: () {
            context.read<PuzzleBloc>().add(const PuzzleReset());
          },
        ),
        TextButton(
          child: const Text('Solve'),
          onPressed: () {
            final moves =
                PuzzleSolver(context.read<PuzzleBloc>().initialState.puzzle)
                    .solve();
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: moves != null
                    ? Text('${moves.map((e) => e.name)}')
                    : const Text('No solution found'),
                duration: const Duration(seconds: 60),
              ),
            );
          },
        ),
        if (isCompleted) ...{
          const Spacer(),
          ElevatedButton.icon(
            label: const Text('Next (Enter)'),
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              context.read<PuzzleBloc>().add(const NextPuzzle());
              ScaffoldMessenger.of(context).clearSnackBars();
            },
          ),
        }
      ],
    );
  }
}
