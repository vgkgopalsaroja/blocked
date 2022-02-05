import 'package:flutter/material.dart';
import 'package:slide/editor/bloc/level_editor_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditorToolbar extends StatelessWidget {
  const EditorToolbar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LevelEditorBloc levelEditorBloc = context.read<LevelEditorBloc>();
    final EditorTool selectedTool =
        context.select((LevelEditorBloc bloc) => bloc.state.selectedTool);
    final EditorObject? selectedObject =
        context.select((LevelEditorBloc bloc) => bloc.state.selectedObject);

    return Material(
      elevation: 8.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (selectedObject is EditorBlock) ...{
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      levelEditorBloc.add(MainEditorBlockSet(context
                          .read<LevelEditorBloc>()
                          .state
                          .selectedObject as EditorBlock));
                    },
                    child: const Text('Set main'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      levelEditorBloc.add(ControlledEditorBlockSet(context
                          .read<LevelEditorBloc>()
                          .state
                          .selectedObject as EditorBlock));
                    },
                    child: const Text('Set controlled'),
                  ),
                ],
              ),
            },
            Wrap(
              // mainAxisSize: MainAxisSize.min,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.pan_tool),
                  label: const Text('Select (Q)'),
                  onPressed: () {
                    levelEditorBloc
                        .add(const EditorToolSelected(EditorTool.move));
                  },
                  style: selectedTool == EditorTool.move
                      ? TextButton.styleFrom(
                          primary: Theme.of(context).colorScheme.onPrimary,
                          backgroundColor: Theme.of(context).primaryColor,
                        )
                      : null,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.brush_rounded),
                  label: const Text('Wall/Exit (W)'),
                  onPressed: () {
                    levelEditorBloc
                        .add(const EditorToolSelected(EditorTool.segment));
                  },
                  style: selectedTool == EditorTool.segment
                      ? TextButton.styleFrom(
                          primary: Theme.of(context).colorScheme.onPrimary,
                          backgroundColor: Theme.of(context).primaryColor,
                        )
                      : null,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.brush_rounded),
                  label: const Text('Block (E)'),
                  onPressed: () {
                    levelEditorBloc
                        .add(const EditorToolSelected(EditorTool.block));
                  },
                  style: selectedTool == EditorTool.block
                      ? TextButton.styleFrom(
                          primary: Theme.of(context).colorScheme.onPrimary,
                          backgroundColor: Theme.of(context).primaryColor,
                        )
                      : null,
                ),
                VerticalDivider(
                    thickness: 8, color: Theme.of(context).primaryColor),
                TextButton.icon(
                  icon: const Icon(Icons.grid_3x3_rounded),
                  label: const Text('Toggle grid (G)'),
                  onPressed: () {
                    levelEditorBloc.add(const GridToggled());
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.grid_3x3_rounded),
                  label: const Text('Clear (C)'),
                  onPressed: () {
                    levelEditorBloc.add(const MapCleared());
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    levelEditorBloc.add(const TestMapPressed());
                  },
                  child: const Text('Play (Space/Enter)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
