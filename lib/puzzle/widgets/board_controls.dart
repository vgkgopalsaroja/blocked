import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/puzzle/puzzle.dart';

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
        if (isCompleted) ...{
          const Spacer(),
          ElevatedButton.icon(
            label: const Text('Next (Enter)'),
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              context.read<PuzzleBloc>().add(const NextPuzzle());
            },
          ),
        }
      ],
    );
  }
}
