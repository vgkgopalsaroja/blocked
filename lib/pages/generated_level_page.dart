import 'package:flutter/material.dart';
import 'package:slide/pages/level_page.dart';
import 'package:slide/puzzle/level.dart';
import 'package:slide/puzzle/level_reader.dart';

class GeneratedLevelPage extends StatelessWidget {
  const GeneratedLevelPage(this.mapString, {Key? key}) : super(key: key);

  final String mapString;

  @override
  Widget build(BuildContext context) {
    return LevelPage(
      Level(
        'Generated level',
        initialState: LevelReader.parseLevel(mapString),
      ),
      onExit: () {
        Navigator.of(context).pop();
        // outerContext.read<LevelEditorBloc>().add(const TestMapExited());
      },
      onNext: () {
        Navigator.of(context).pop();
        // outerContext.read<LevelEditorBloc>().add(const TestMapExited());
      },
    );
  }
}
