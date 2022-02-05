import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/puzzle/bloc/puzzle_bloc.dart';
import 'package:slide/puzzle/level_reader.dart';
import 'package:slide/routing/navigator_bloc.dart';
import 'package:slide/widgets/puzzle/puzzle.dart';

class LevelSelectionPage extends StatelessWidget {
  const LevelSelectionPage(this.levels, {Key? key}) : super(key: key);

  final List<LevelData> levels;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  final levelData = levels[index];
                  return OutlinedButton(
                    clipBehavior: Clip.antiAlias,
                    onPressed: () {
                      context
                          .read<NavigationCubit>()
                          .navigateToLevel(levelData.name);
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
                                    tag: levelData.name,
                                    child: BlocProvider(
                                      create: (context) => PuzzleBloc(
                                          levelData.toLevel().initialState,
                                          onExit: () {},
                                          onNext: () {}),
                                      child: const Puzzle(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 32.0),
                            Text(
                              levelData.name,
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
