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
    // final levels = context.select((LevelBloc bloc) => bloc.levels);
    return Scaffold(
      body: CustomScrollView(
        shrinkWrap: true,
        primary: false,
        slivers: [
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Levels', style: Theme.of(context).textTheme.headline4),
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
                  return ElevatedButton(
                    clipBehavior: Clip.antiAlias,
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      side: BorderSide(
                        color: Colors.grey[500]!,
                        width: 4.0,
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      // Launch route
                      context
                          .read<NavigationCubit>()
                          .navigateToLevel(levelData.name);
                    },
                    child: Ink(
                      // width: 64.0,
                      // height: 64.0,
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.circular(4.0),
                      //   border: Border.all(
                      //     color: Colors.grey[500]!,
                      //     width: 4.0,
                      //   ),
                      // ),
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Row(
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Center(
                                child: FittedBox(
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
                            const SizedBox(width: 32.0),
                            Text(
                              levelData.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5
                                  ?.copyWith(
                                    color: Colors.grey.shade700,
                                  ),
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
