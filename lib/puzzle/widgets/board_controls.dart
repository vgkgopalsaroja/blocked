import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/models/puzzle/puzzle.dart';
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

            IconData directionToIcon(MoveDirection direction) {
              switch (direction) {
                case MoveDirection.up:
                  return Icons.arrow_upward;
                case MoveDirection.down:
                  return Icons.arrow_downward;
                case MoveDirection.left:
                  return Icons.arrow_back;
                case MoveDirection.right:
                  return Icons.arrow_forward;
              }
            }

            Scaffold.of(context).showBottomSheet(
              (context) => moves != null
                  ? ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => Icon(
                        directionToIcon(moves[index]),
                      ),
                      itemCount: moves.length,
                    )
                  : Text('No solution found'),
              constraints: BoxConstraints(
                maxHeight: 48,
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
            },
          ),
        }
      ],
    );
  }
}
