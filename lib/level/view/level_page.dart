import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/models/models.dart';
import 'package:slide/puzzle/puzzle.dart';

class LevelPage extends StatelessWidget {
  const LevelPage(
    this.level, {
    Key? key,
    required this.onExit,
    required this.onNext,
    required this.boardControls,
  }) : super(key: key);

  final Level level;
  final VoidCallback onExit;
  final VoidCallback onNext;
  final Widget boardControls;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PuzzleBloc(level.initialState, onExit: onExit, onNext: onNext),
      child: Builder(builder: (context) {
        return PuzzleShortcutListener(
          puzzleBloc: context.read<PuzzleBloc>(),
          child: BlocBuilder<PuzzleBloc, LevelState>(
            buildWhen: (previous, current) {
              return previous.isCompleted != current.isCompleted;
            },
            builder: (context, state) {
              final levelName = level.name;
              final levelHint = level.hint;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: IntrinsicHeight(
                    child: IntrinsicWidth(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(levelName,
                              style: Theme.of(context).textTheme.displaySmall),
                          if (levelHint != null)
                            Text(levelHint,
                                style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 32),
                          Expanded(
                            child: Center(
                              child: FittedBox(
                                child: Hero(
                                  tag: 'puzzle',
                                  flightShuttleBuilder: (
                                    BuildContext flightContext,
                                    Animation<double> animation,
                                    HeroFlightDirection flightDirection,
                                    BuildContext fromHeroContext,
                                    BuildContext toHeroContext,
                                  ) {
                                    final toHero =
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
                          const SizedBox(height: 32),
                          Hero(
                            tag: 'puzzle_controls',
                            flightShuttleBuilder: (
                              BuildContext flightContext,
                              Animation<double> animation,
                              HeroFlightDirection flightDirection,
                              BuildContext fromHeroContext,
                              BuildContext toHeroContext,
                            ) {
                              final toHero = toHeroContext.widget as Hero;
                              return BlocProvider.value(
                                value: context.read<PuzzleBloc>(),
                                child: Material(
                                  type: MaterialType.transparency,
                                  child: toHero.child,
                                ),
                              );
                            },
                            child: boardControls,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
