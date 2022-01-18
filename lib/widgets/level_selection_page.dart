import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/puzzle/bloc/puzzle_bloc.dart';
import 'package:slide/level/bloc/level_bloc.dart';
import 'package:slide/widgets/board.dart';

class LevelSelectionPage extends StatelessWidget {
  const LevelSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final levels = context.select((LevelBloc bloc) => bloc.levels);
    return Scaffold(
      body: CustomScrollView(
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
                  return Material(
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(4.0),
                    elevation: 8,
                    child: InkWell(
                      child: Ink(
                        // width: 64.0,
                        // height: 64.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(
                            color: Colors.grey[500]!,
                            width: 4.0,
                          ),
                        ),
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
                                          levelData.toLevel().initialState),
                                      child: const Board(),
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
                      onTap: () {
                        // Launch route
                        context.read<LevelBloc>().add(LevelChosen(levelData));
                      },
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
