import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slide/editor/bloc/level_editor_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/routing/app_route_path.dart';

class EditorToolbar extends StatelessWidget {
  const EditorToolbar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LevelEditorBloc levelEditorBloc =
        context.select((LevelEditorBloc bloc) => bloc);
    final EditorTool selectedTool =
        context.select((LevelEditorBloc bloc) => bloc.state.selectedTool);
    final EditorObject? selectedObject =
        context.select((LevelEditorBloc bloc) => bloc.state.selectedObject);
    final String? puzzleError =
        context.select((LevelEditorBloc bloc) => bloc.state.puzzleError);
    final String? encodedMapString = context.select((LevelEditorBloc bloc) =>
        bloc.state.getMapString()?.encodeAsMapString() ?? 'Invalid map state');

    return RepaintBoundary(
      child: Material(
        elevation: 8.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (puzzleError != null)
                Container(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Text(
                    puzzleError,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer),
                  ),
                ),
              if (selectedObject is EditorBlock) ...{
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.read<LevelEditorBloc>().add(MainEditorBlockSet(
                            context.read<LevelEditorBloc>().state.selectedObject
                                as EditorBlock));
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
              if (encodedMapString != null)
                SelectableText(
                  encodedMapString,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontFamily: GoogleFonts.robotoMono().fontFamily,
                      ),
                ),
              Wrap(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.mouse),
                        label: const Text('Select (Q)'),
                        onPressed: () {
                          context
                              .read<LevelEditorBloc>()
                              .add(const EditorToolSelected(EditorTool.move));
                        },
                        style: selectedTool == EditorTool.move
                            ? TextButton.styleFrom(
                                primary:
                                    Theme.of(context).colorScheme.onPrimary,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                              )
                            : null,
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.brush_rounded),
                        label: const Text('Wall/Exit (W)'),
                        onPressed: () {
                          levelEditorBloc.add(
                              const EditorToolSelected(EditorTool.segment));
                        },
                        style: selectedTool == EditorTool.segment
                            ? TextButton.styleFrom(
                                primary:
                                    Theme.of(context).colorScheme.onPrimary,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
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
                                primary:
                                    Theme.of(context).colorScheme.onPrimary,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                              )
                            : null,
                      ),
                    ],
                  ),
                  VerticalDivider(
                      width: 8, color: Theme.of(context).colorScheme.primary),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.grid_3x3_rounded),
                        label: const Text('Toggle grid (G)'),
                        onPressed: () {
                          levelEditorBloc.add(const GridToggled());
                        },
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.clear_rounded),
                        label: const Text('Clear (C)'),
                        onPressed: () {
                          levelEditorBloc.add(const MapCleared());
                        },
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Save (S)'),
                        onPressed: () {
                          levelEditorBloc.add(const SavePressed());
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on String {
  String encodeAsMapString() {
    return encodeMapString(this);
  }
}
