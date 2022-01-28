import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/puzzle/bloc/puzzle_bloc.dart';
import 'package:slide/level/bloc/level_bloc.dart';

class BoardControls extends StatelessWidget {
  const BoardControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      ],
    );
  }
}
