import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/level_shortcut_listener.dart';
import 'package:slide/puzzle/bloc/puzzle_bloc.dart';
import 'package:slide/puzzle/level.dart';
import 'package:slide/widgets/puzzle/puzzle.dart';
import 'package:slide/widgets/puzzle/board_controls.dart';

class LevelPage extends StatelessWidget {
  const LevelPage(this.level,
      {Key? key, required this.onExit, required this.onNext})
      : super(key: key);

  final Level level;
  final VoidCallback onExit;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PuzzleBloc(level.initialState, onExit: onExit, onNext: onNext),
      child: Builder(builder: (context) {
        return LevelShortcutListener(
          puzzleBloc: context.read<PuzzleBloc>(),
          child: Scaffold(
            body: BlocBuilder<PuzzleBloc, PuzzleState>(
              buildWhen: (previous, current) {
                return previous.isCompleted != current.isCompleted;
              },
              builder: (context, state) {
                final levelName = level.name;
                final levelHint = level.hint;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: IntrinsicWidth(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(levelName,
                              style: Theme.of(context).textTheme.displaySmall),
                          if (levelHint != null)
                            Text(levelHint,
                                style: Theme.of(context).textTheme.titleLarge),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32.0),
                            child: Center(
                              child: FittedBox(
                                child: Hero(
                                  tag: level.name,
                                  flightShuttleBuilder: (
                                    BuildContext flightContext,
                                    Animation<double> animation,
                                    HeroFlightDirection flightDirection,
                                    BuildContext fromHeroContext,
                                    BuildContext toHeroContext,
                                  ) {
                                    final Hero toHero =
                                        toHeroContext.widget as Hero;
                                    return BlocProvider.value(
                                      value: context.read<PuzzleBloc>(),
                                      child: Material(
                                        type: MaterialType.transparency,
                                        child: toHero.child,
                                      ),
                                    );
                                  },
                                  child: const Puzzle(),
                                ),
                              ),
                            ),
                          ),
                          const BoardControls(),
                        ],
                      ),
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
