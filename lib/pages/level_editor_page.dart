import 'dart:js';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/editor/bloc/level_editor_bloc.dart';
import 'package:slide/editor/bloc/builder_bloc.dart';
import 'package:slide/puzzle/model/position.dart';
import 'package:slide/pages/level_page.dart';
import 'package:slide/puzzle/bloc/puzzle_bloc.dart';
import 'package:slide/level/bloc/level_bloc.dart';
import 'package:slide/puzzle/level.dart';
import 'package:slide/puzzle/level_reader.dart';
import 'package:slide/puzzle/model/segment.dart';
import 'package:slide/widgets/editor/builder/builder.dart';
import 'package:slide/widgets/editor/editor_shortcut_listener.dart';
import 'package:slide/widgets/editor/grid_overlay.dart';
import 'package:slide/widgets/editor/resizable_block.dart';
import 'package:slide/widgets/editor/resizable_floor.dart';
import 'package:slide/widgets/editor/resizable_wall.dart';
import 'package:slide/widgets/puzzle/block.dart';
import 'package:slide/widgets/puzzle/puzzle.dart';
import 'package:slide/widgets/puzzle/board_constants.dart';
import 'package:slide/widgets/puzzle/floor.dart';
import 'package:slide/widgets/puzzle/wall.dart';
import 'package:slide/widgets/resizable/resizable.dart';
import 'package:slide/puzzle/model/block.dart';

class LevelEditorPage extends StatelessWidget {
  const LevelEditorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LevelEditorBloc(),
        ),
      ],
      child: Center(
        child: Scaffold(
          body: BlocConsumer<LevelEditorBloc, LevelEditorState>(
            listener: (outerContext, state) {
              if (state.isTesting) {
                Navigator.of(outerContext)
                    .push(MaterialPageRoute(builder: (context) {
                  final generatedLevel = Level('Generated puzzle',
                      initialState: state.generatedPuzzle!);
                  return LevelPage(
                    generatedLevel,
                    onExit: () {
                      Navigator.of(context).pop();
                      outerContext
                          .read<LevelEditorBloc>()
                          .add(const TestMapExited());
                    },
                    onNext: () {
                      Navigator.of(context).pop();
                      outerContext
                          .read<LevelEditorBloc>()
                          .add(const TestMapExited());
                    },
                  );
                }));
              }
            },
            listenWhen: (previous, current) {
              return previous.isTesting != current.isTesting;
            },
            builder: (context, state) {
              return EditorShortcutListener(
                levelEditorBloc: context.read<LevelEditorBloc>(),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            context
                                .read<LevelEditorBloc>()
                                .add(const EditorObjectSelected(null));
                          }),
                    ),
                    if (state.isGridVisible)
                      const Positioned.fill(child: GridOverlay()),
                    for (var object in state.objects) ...{
                      if (object is EditorFloor) ...{
                        ResizableFloor(
                          object,
                          state.getExits().map((s) => s.toSegment()).toList(),
                        ),
                      }
                    },
                    for (var object in state.objects) ...{
                      if (object is EditorBlock) ...{
                        ResizableBlock(object),
                      } else if (object is EditorFloor) ...{
                        // ResizableFloor(
                        //     object, state.exits.map((s) => s.segment).toList()),
                      } else if (object is EditorSegment) ...{
                        ResizableWall(object),
                      }
                    },
                    if (state.isWallBuilderOpen)
                      WallBuilder(onObjectPlaced: (start, end) {
                        context
                            .read<LevelEditorBloc>()
                            .add(SegmentAdded(Segment.from(start, end)));
                      }, hintBuilder: (start, end) {
                        if (start != null && end != null) {
                          final Segment segment = Segment.from(
                              Position(start.x, start.y),
                              Position(end.x, end.y));
                          return Positioned(
                            left: kHandleSize + segment.start.x.toWallOffset(),
                            top: kHandleSize + segment.start.y.toWallOffset(),
                            child: PuzzleWall(segment),
                          );
                        }
                      }),
                    Positioned(
                      bottom: 0,
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<LevelEditorBloc>()
                                  .add(const BlockAdded());
                            },
                            child: const Text('Add block'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context.read<LevelEditorBloc>().add(SegmentAdded(
                                    Segment.vertical(x: 2, start: 0, end: 1),
                                  ));
                            },
                            child: const Text('Add vertical wall'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<LevelEditorBloc>()
                                  .add(const TestMapPressed());
                            },
                            child: const Text('Play'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<LevelEditorBloc>()
                                  .add(const WallBuilderToggled());
                            },
                            child: const Text('Toggle wall builder'),
                          ),
                          if (state.selectedObject is EditorBlock) ...{
                            ElevatedButton(
                              onPressed: () {
                                context.read<LevelEditorBloc>().add(
                                    MainEditorBlockSet(
                                        state.selectedObject as EditorBlock));
                              },
                              child: const Text('Set main'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                context.read<LevelEditorBloc>().add(
                                    ControlledEditorBlockSet(
                                        state.selectedObject as EditorBlock));
                              },
                              child: const Text('Set controlled'),
                            ),
                          }
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class WallPoint extends StatefulWidget {
  const WallPoint(this.position, {Key? key}) : super(key: key);

  final Position position;

  @override
  State<WallPoint> createState() => _WallPointState();
}

class _WallPointState extends State<WallPoint> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: MouseRegion(
        onEnter: (event) {
          setState(() {
            isHovered = true;
          });
          context.read<EditorBuilderBloc>().add(PointHovered(widget.position));
        },
        onExit: (event) {
          setState(() {
            isHovered = false;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          width: isHovered ? kWallWidth * 2 : kWallWidth,
          height: isHovered ? kWallWidth * 2 : kWallWidth,
          decoration: BoxDecoration(
            color: Colors.black,
            // borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
    );
  }
}
