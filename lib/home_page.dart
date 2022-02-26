
import 'package:blocked/home_page_background.dart';
import 'package:blocked/progress/progress.dart';
import 'package:blocked/routing/routing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButtonTheme(
      data: OutlinedButtonThemeData(
        style: Theme.of(context).outlinedButtonTheme.style?.merge(
              OutlinedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
            ),
      ),
      child: Scaffold(
        body: Stack(
          children: [
            const HomePageBackground(),
            Center(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('blocked',
                              style: Theme.of(context).textTheme.displayMedium),
                          const SizedBox(height: 32),
                          StreamBuilder<bool>(
                            stream: hasProgressStream(),
                            builder: (context, snapshot) {
                              final hasProgress = snapshot.data ?? false;
                              return ElevatedButton.icon(
                                icon: const Icon(MdiIcons.play),
                                label: Text(hasProgress ? 'Continue' : 'Start'),
                                onPressed: () async {
                                  final level =
                                      await getFirstUncompletedLevel();
                                  context
                                      .read<NavigatorCubit>()
                                      .navigateToLevel(level[0], level[1]);
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            icon: const Icon(MdiIcons.viewGridOutline),
                            label: const Text('Chapters'),
                            onPressed: () {
                              context
                                  .read<NavigatorCubit>()
                                  .navigateToChapterSelection();
                            },
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            icon: const Icon(MdiIcons.vectorSquareEdit),
                            label: const Text('Editor'),
                            onPressed: () {
                              context
                                  .read<NavigatorCubit>()
                                  .navigateToEditor('');
                            },
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.settings),
                            label: const Text('Settings'),
                            onPressed: () {
                              context
                                  .read<NavigatorCubit>()
                                  .navigateToSettings();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
