import 'package:blocked/progress/util/progress_saver.dart';
import 'package:blocked/routing/navigator_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
                    FutureBuilder<bool>(
                      future: hasProgress(),
                      builder: (context, snapshot) {
                        final hasProgress = snapshot.data ?? false;
                        return ElevatedButton.icon(
                          onPressed: () async {
                            final level = await getFirstUncompletedLevel();
                            context
                                .read<NavigatorCubit>()
                                .navigateToLevel(level[0], level[1]);
                          },
                          icon: const Icon(MdiIcons.play),
                          label: Text(hasProgress ? 'Continue' : 'Start'),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        context
                            .read<NavigatorCubit>()
                            .navigateToChapterSelection();
                      },
                      icon: const Icon(MdiIcons.viewGridOutline),
                      label: const Text('Chapters'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      icon: const Icon(MdiIcons.vectorSquareEdit),
                      onPressed: () {
                        context.read<NavigatorCubit>().navigateToEditor('');
                      },
                      label: const Text('Editor'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
