import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:slide/editor/editor.dart';
import 'package:slide/level/level.dart';
import 'package:slide/models/models.dart';
import 'package:slide/routing/routing.dart';

class GeneratedLevelPage extends StatelessWidget {
  const GeneratedLevelPage(this.mapString, {Key? key}) : super(key: key);

  final String mapString;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Clipboard.setData(
            ClipboardData(
                text:
                    'https://slide.jeffsieu.com/#/editor/generated/${encodeMapString(mapString)}'),
          );
        },
        icon: const Icon(MdiIcons.contentCopy),
        label: const Text('Copy link'),
      ),
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
        boardControls: GeneratedBoardControls(mapString),
      ),
    );
  }
}