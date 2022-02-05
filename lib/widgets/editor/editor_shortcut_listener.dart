import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slide/editor/bloc/level_editor_bloc.dart';

class EditorShortcutListener extends StatelessWidget {
  const EditorShortcutListener({
    Key? key,
    required this.levelEditorBloc,
    required this.child,
  }) : super(key: key);

  final LevelEditorBloc levelEditorBloc;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      autofocus: true,
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.keyQ):
            const EditorActionIntent(EditorToolSelected(EditorTool.move)),
        LogicalKeySet(LogicalKeyboardKey.keyW):
            const EditorActionIntent(EditorToolSelected(EditorTool.segment)),
        LogicalKeySet(LogicalKeyboardKey.keyE):
            const EditorActionIntent(EditorToolSelected(EditorTool.block)),
        LogicalKeySet(LogicalKeyboardKey.keyC):
            const EditorActionIntent(MapCleared()),
        LogicalKeySet(LogicalKeyboardKey.delete):
            const EditorActionIntent(SelectedEditorObjectDeleted()),
        LogicalKeySet(LogicalKeyboardKey.backspace):
            const EditorActionIntent(SelectedEditorObjectDeleted()),
        LogicalKeySet(LogicalKeyboardKey.keyG):
            const EditorActionIntent(GridToggled()),
        LogicalKeySet(LogicalKeyboardKey.enter):
            const EditorActionIntent(TestMapPressed()),
        LogicalKeySet(LogicalKeyboardKey.space):
            const EditorActionIntent(TestMapPressed()),
      },
      actions: {
        EditorActionIntent:
            CallbackAction<EditorActionIntent>(onInvoke: (intent) {
          return levelEditorBloc.add(intent.event);
        }),
      },
      child: child,
    );
  }
}

class EditorActionIntent extends Intent {
  const EditorActionIntent(this.event);

  final LevelEditorEvent event;
}
