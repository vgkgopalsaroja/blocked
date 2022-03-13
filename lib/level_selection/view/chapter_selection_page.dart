import 'package:blocked/background/background.dart';
import 'package:blocked/level/level.dart';
import 'package:blocked/level_selection/level_selection.dart';
import 'package:blocked/models/models.dart';
import 'package:blocked/puzzle/puzzle.dart';
import 'package:blocked/routing/routing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChapterSelectionPage extends StatelessWidget {
  const ChapterSelectionPage(this.chapters, {Key? key}) : super(key: key);

  final List<LevelChapter> chapters;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const RotatingPuzzleBackground(),
          CustomScrollView(
            slivers: [
              const SliverAppBar(
                pinned: true,
              ),
              SliverToBoxAdapter(
                  child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'app_title',
                      child: Text('blocked',
                          style: Theme.of(context).textTheme.displayMedium),
                    ),
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
        ],
      ),
    );
  }
}
