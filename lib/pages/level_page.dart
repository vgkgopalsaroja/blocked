import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/level_shortcut_listener.dart';
import 'package:slide/puzzle/bloc/puzzle_bloc.dart';
import 'package:slide/puzzle/level.dart';
import 'package:slide/level/bloc/level_bloc.dart';
import 'package:slide/widgets/puzzle/puzzle.dart';
import 'package:slide/widgets/puzzle/board_controls.dart';

class LevelPage extends StatelessWidget {
  const LevelPage(this.level, {Key? key, this.onExit, this.onNext})
      : super(key: key);

  final Level level;
  final VoidCallback? onExit;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PuzzleBloc(level.initialState, onExit: onExit),
      child: Builder(builder: (context) {
        return LevelShortcutListener(
          puzzleBloc: context.watch<PuzzleBloc>(),
          child: Scaffold(
            body: BlocBuilder<PuzzleBloc, PuzzleState>(
              builder: (context, state) {
                final isCompleted =
                    context.read<PuzzleBloc>().state.isCompleted;
                final levelName = level.name;
                final levelHint = level.hint;

                if (isCompleted) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Level $levelName completed!'),
                        TextButton.icon(
                          label: const Text('Next'),
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () {
                            onNext?.call();
                          },
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(level.name,
                            style: Theme.of(context).textTheme.headline6),
                        if (levelHint != null)
                          Text(levelHint,
                              style: Theme.of(context).textTheme.subtitle1),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: FittedBox(child: Puzzle()),
                        ),
                        const IntrinsicWidth(child: BoardControls()),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
