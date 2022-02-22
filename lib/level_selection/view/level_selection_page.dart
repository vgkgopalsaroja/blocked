import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/level_selection/level_selection.dart';
import 'package:slide/models/models.dart';
import 'package:slide/puzzle/puzzle.dart';
import 'package:slide/routing/routing.dart';

class LevelSelectionPage extends StatelessWidget {
  LevelSelectionPage(Iterable<LevelData> levelData, {Key? key})
      : levels = levelData.map((data) => data.toLevel()).toList(),
        super(key: key);

  final List<Level> levels;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BackButton(),
                Text('levels', style: Theme.of(context).textTheme.displaySmall),
              ],
            ),
          )),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 1,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final level = levels[index];
                  final initialLevelState = level.initialState;
                  return Builder(
                    builder: (context) {
                      return LabeledPuzzleButton(
                        onPressed: () {
                          context
                              .read<NavigatorCubit>()
                              .navigateToLevel(level.name);
                        },
                        puzzle: Hero(
                          tag: context.select((NavigatorCubit cubit) {
                            final latestLevelName = cubit.latestLevelName;
                            return latestLevelName == level.name
                                ? 'puzzle'
                                : level.name;
                          }),
                          child: BlocProvider(
                            create: (context) => LevelBloc(initialLevelState),
                            child: const StaticPuzzle(),
                          ),
                        ),
                        label: Text(
                          level.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      );
                    },
                  );
                },
                childCount: levels.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
