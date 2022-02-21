import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:slide/models/models.dart';
import 'package:slide/routing/navigator_cubit.dart';

class ChapterSelectionPage extends StatelessWidget {
  const ChapterSelectionPage(this.chapters, {Key? key}) : super(key: key);

  final List<LevelChapter> chapters;

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
        slivers: [
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('slide', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 32),
                Text('chapters',
                    style: Theme.of(context).textTheme.displaySmall),
              ],
            ),
          )),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final chapter = chapters[index];
                return ListTile(
                  title: Text(chapter.name),
                  onTap: () {
                    context
                        .read<NavigatorCubit>()
                        .navigateToLevelSelection(chapter.name);
                  },
                );
              },
              childCount: chapters.length,
            ),
          ),
        ],
      ),
    );
  }
}
