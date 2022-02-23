import 'package:flutter/material.dart';
import 'package:slide/level/level.dart';
import 'package:slide/models/models.dart';
import 'package:slide/puzzle/puzzle.dart';

class GeneratedLevelPage extends StatelessWidget {
  const GeneratedLevelPage(this.mapString, {Key? key}) : super(key: key);

  final String mapString;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LevelPage(
        Level(
          'Generated level',
          initialState: LevelReader.parseLevel(mapString),
        ),
        onExit: () {
          Navigator.of(context).pop();
        },
        onNext: () {
          Navigator.of(context).pop();
        },
        boardControls: BoardControls.generated(mapString),
      ),
    );
  }
}
