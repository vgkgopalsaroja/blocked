import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slide/puzzle/level.dart';
import 'package:slide/level/bloc/level_bloc.dart';

class LevelSelectionPage extends StatelessWidget {
  const LevelSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text('Levels', style: Theme.of(context).textTheme.headline5),
            Center(
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (var level in Levels.levels) ...{
                    Material(
                      clipBehavior: Clip.antiAlias,
                      borderRadius: BorderRadius.circular(4.0),
                      elevation: 8,
                      child: InkWell(
                        child: Ink(
                          width: 64.0,
                          height: 64.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(
                              color: Colors.grey[500]!,
                              width: 4.0,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Center(
                              child: Text(level.name,
                                  style:
                                      Theme.of(context).textTheme.headline6)),
                        ),
                        onTap: () {
                          // Launch route

                          context.read<LevelBloc>().add(LevelChosen(level));
                        },
                      ),
                    ),
                  },
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
