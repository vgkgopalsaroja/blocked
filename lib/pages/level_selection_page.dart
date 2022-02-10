import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:slide/puzzle/bloc/puzzle_bloc.dart';
import 'package:slide/puzzle/level_reader.dart';
import 'package:slide/routing/navigator_cubit.dart';
import 'package:slide/widgets/puzzle/puzzle.dart';

import '../puzzle/level.dart';

class LevelSelectionPage extends StatelessWidget {
  LevelSelectionPage(Iterable<LevelData> levelData, {Key? key})
      : levels = levelData.map((data) => data.toLevel()).toList(),
        super(key: key);

  final List<Level> levels;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.read<NavigatorCubit>().navigateToEditor('');
        },
        label: const Text('Editor'),
        icon: const Icon(MdiIcons.vectorSquareEdit),
      ),
      body: CustomScrollView(
        shrinkWrap: true,
        primary: false,
        slivers: [
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('slide', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 32),
                Text('levels', style: Theme.of(context).textTheme.displaySmall),
              ],
            ),
          )),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final level = levels[index];
                  final initialLevelState = level.initialState;
                  return OutlinedButton(
                    clipBehavior: Clip.antiAlias,
                    onPressed: () {
                      context
                          .read<NavigatorCubit>()
                          .navigateToLevel(level.name);
                    },
                    child: Ink(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Row(
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Center(
                                child: FittedBox(
                                  child: Hero(
                                    tag: level.name,
                                    child: BlocProvider(
                                      create: (context) => PuzzleBloc(
                                          initialLevelState,
                                          onExit: () {},
                                          onNext: () {}),
                                      child: const StaticPuzzle(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 32.0),
                            Text(
                              level.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
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
