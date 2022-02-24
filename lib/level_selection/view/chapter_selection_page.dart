import 'package:blocked/level_selection/level_selection.dart';
import 'package:blocked/models/models.dart';
import 'package:blocked/progress/util/progress_saver.dart';
import 'package:blocked/puzzle/puzzle.dart';
import 'package:blocked/routing/navigator_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ChapterSelectionPage extends StatelessWidget {
  const ChapterSelectionPage(this.chapters, {Key? key}) : super(key: key);

  final List<LevelChapter> chapters;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            onSelected: ((value) {
              if (value == 'clear_progress') {
                clearData();
              }
            }),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_progress',
                child: Text('Clear progress'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.read<NavigatorCubit>().navigateToEditor('');
        },
        label: const Text('Editor'),
        icon: const Icon(MdiIcons.vectorSquareEdit),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('blocked',
                    style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 32),
                Text('chapters',
                    style: Theme.of(context).textTheme.displaySmall),
              ],
            ),
          )),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 256,
                childAspectRatio: 1,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final chapter = chapters[index];
                  return LabeledPuzzleButton(
                    label: Text(
                      chapter.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    puzzle: Hero(
                      tag: chapter.levels.first.name,
                      child: BlocProvider(
                        create: (context) => LevelBloc(
                            chapter.levels.first.toLevel().initialState),
                        child: const StaticPuzzle(),
                      ),
                    ),
                    onPressed: () {
                      context
                          .read<NavigatorCubit>()
                          .navigateToLevelSelection(chapter.name);
                    },
                  );
                },
                childCount: chapters.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
