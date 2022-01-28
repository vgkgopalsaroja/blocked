import 'dart:js';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/editor/bloc/level_editor_bloc.dart';
import 'package:slide/editor/bloc/wall_builder_bloc.dart';
import 'package:slide/puzzle/model/position.dart';
import 'package:slide/pages/level_page.dart';
import 'package:slide/puzzle/bloc/puzzle_bloc.dart';
import 'package:slide/level/bloc/level_bloc.dart';
import 'package:slide/puzzle/level.dart';
import 'package:slide/puzzle/level_reader.dart';
import 'package:slide/puzzle/model/segment.dart';
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
            return Stack(
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
                for (var object in state.objects) ...{
                  if (object is EditorBlock) ...{
                    _ResizableBlock(object),
                  } else if (object is EditorFloor) ...{
                    _ResizableFloor(object),
                  } else if (object is EditorSegment) ...{
                    _ResizableWall(object),
                  }
                },
                if (state.isWallBuilderOpen) _WallBuilder(),
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
                                isVertical: true,
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
                          if (state.isWallBuilderOpen) {
                            context
                                .read<LevelEditorBloc>()
                                .add(const WallBuilderClosed());
                          } else {
                            context
                                .read<LevelEditorBloc>()
                                .add(const WallBuilderOpened());
                          }
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
            );
          },
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
          context.read<WallBuilderBloc>().add(PointHovered(widget.position));
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

class _WallBuilder extends StatelessWidget {
  const _WallBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return BlocProvider(
      create: (context) => WallBuilderBloc(),
      child: BlocListener<WallBuilderBloc, WallBuilderState>(
        listener: (context, state) {
          // if (state.start != null && state.end != null) {
          //   context
          //       .read<LevelEditorBloc>()
          //       .add(SegmentAdded(Segment(state.start!, state.end!)));
          // }
        },
        listenWhen: (previous, current) {
          return previous.end != current.end;
        },
        child: Builder(builder: (context) {
          final start =
              context.select((WallBuilderBloc bloc) => bloc.state.start);
          final end = context.select((WallBuilderBloc bloc) => bloc.state.end);
          return GestureDetector(
            onTapDown: (details) {
              final globalPosition = details.globalPosition;
              final x = max(
                  0,
                  ((globalPosition.dx - kWallWidth) / kBlockSizeInterval)
                      .round());
              final y = max(
                  0,
                  ((globalPosition.dy - kWallWidth) / kBlockSizeInterval)
                      .round());
              context.read<WallBuilderBloc>().add(PointPressed(Position(x, y)));
            },
            onPanUpdate: (details) {
              final globalPosition = details.globalPosition;

              final x = max(
                  0,
                  ((globalPosition.dx - kWallWidth) / kBlockSizeInterval)
                      .round());
              final y = max(
                  0,
                  ((globalPosition.dy - kWallWidth) / kBlockSizeInterval)
                      .round());
              context.read<WallBuilderBloc>().add(PointHovered(Position(x, y)));
            },
            onPanEnd: (details) {
              final hoveredPosition =
                  context.read<WallBuilderBloc>().state.hoveredPosition;

              context
                  .read<WallBuilderBloc>()
                  .add(PointReleased(hoveredPosition!));
            },
            child: Stack(
              children: [
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: kBlockSizeInterval,
                    mainAxisExtent: kBlockSizeInterval,
                  ),
                  itemBuilder: (context, index) {
                    final x = index % (screenWidth ~/ kBlockSizeInterval);
                    final y = index ~/ (screenWidth ~/ kBlockSizeInterval);
                    return WallPoint(Position(x, y));
                  },
                  itemCount: (screenWidth / kBlockSizeInterval).floor() *
                      (screenHeight / kBlockSizeInterval).floor(),
                ),
                if (start != null && end != null) ...{
                  Positioned(
                    top: start.y * kBlockSizeInterval,
                    left: start.x * kBlockSizeInterval,
                    child: Container(
                      width: (end.x - start.x).toWallSize(),
                      height: (end.y - start.y).toWallSize(),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                  ),
                },
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _ResizableFloor extends StatelessWidget {
  const _ResizableFloor(this.floor, {Key? key}) : super(key: key);

  final EditorFloor floor;

  @override
  Widget build(BuildContext context) {
    return Resizable(
      enabled: context
          .select((LevelEditorBloc bloc) => bloc.state.selectedObject == floor),
      minHeight: 1.toBoardSize(),
      minWidth: 1.toBoardSize(),
      snapHeightInterval: 2.toBoardSize() - 1.toBoardSize(),
      snapWidthInterval: 2.toBoardSize() - 1.toBoardSize(),
      snapWhileMoving: true,
      snapWhileResizing: true,
      baseWidth: 1.toBoardSize(),
      baseHeight: 1.toBoardSize(),
      snapOffsetInterval: const Offset(
        kBlockSize + kBlockToBlockGap,
        kBlockSize + kBlockToBlockGap,
      ),
      onUpdate: (state) {
        final newSize = state.size;
        final newOffset = state.offset;
        if (floor.offset != newOffset || floor.size != newSize) {
          context.read<LevelEditorBloc>().add(
                EditorObjectMoved(
                  floor,
                  state.size,
                  state.offset,
                ),
              );
        }
      },
      builder: (context, size) {
        return PuzzleFloor(
          width: size.width.boardSizeToBlockCount(),
          height: size.height.boardSizeToBlockCount(),
        );
      },
    );
  }
}

class AnimatedSelectable extends StatelessWidget {
  const AnimatedSelectable(
      {Key? key, required this.isSelected, required this.child})
      : super(key: key);

  final bool isSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      foregroundDecoration: BoxDecoration(
        color:
            isSelected ? Theme.of(context).primaryColor.withOpacity(0.3) : null,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          color: Theme.of(context).primaryColor,
          style: isSelected ? BorderStyle.solid : BorderStyle.none,
          width: 4.0,
        ),
      ),
      child: child,
    );
  }
}

class _ResizableBlock extends StatelessWidget {
  const _ResizableBlock(this.block, {Key? key}) : super(key: key);

  final EditorBlock block;

  @override
  Widget build(BuildContext context) {
    final isSelected = context.select(
      (LevelEditorBloc bloc) => bloc.state.selectedObject == block,
    );

    return Resizable(
      enabled: isSelected,
      minHeight: kBlockSize,
      minWidth: kBlockSize,
      baseHeight: kBlockSize,
      baseWidth: kBlockSize,
      snapHeightInterval: kBlockSizeInterval,
      snapWidthInterval: kBlockSizeInterval,
      snapWhileMoving: true,
      snapWhileResizing: true,
      snapOffsetInterval: const Offset(
        kBlockSize + kBlockToBlockGap,
        kBlockSize + kBlockToBlockGap,
      ),
      snapBaseOffset: const Offset(
        kWallWidth + kBlockGap,
        kWallWidth + kBlockGap,
      ),
      onTap: () {
        context.read<LevelEditorBloc>().add(EditorObjectSelected(block));
      },
      onUpdate: (state) {
        final newSize = state.size;
        final newOffset = state.offset;
        if (block.offset != newOffset || block.size != newSize) {
          context.read<LevelEditorBloc>().add(
                EditorObjectMoved(
                  block,
                  state.size,
                  state.offset,
                ),
              );
        }
      },
      builder: (context, size) {
        final blockSize = size / kBlockSize;
        return AnimatedSelectable(
          isSelected: isSelected,
          child: PuzzleBlock(
            Block.manual(
              blockSize.width.round(),
              blockSize.height.round(),
              isMain: block.isMain,
              canMoveHorizontally: true,
              canMoveVertically: true,
            ),
            isControlled: block.hasControl,
          ),
        );
      },
    );
  }
}

class _ResizableWall extends StatelessWidget {
  const _ResizableWall(this.wall, {Key? key}) : super(key: key);

  final EditorSegment wall;
  bool get _isVertical => wall.segment.isVertical;

  @override
  Widget build(BuildContext context) {
    final isSelected = context.select(
      (LevelEditorBloc bloc) => bloc.state.selectedObject == wall,
    );

    return Resizable(
      enabled: isSelected,
      minHeight: kWallWidth,
      minWidth: kWallWidth,
      baseHeight: kWallWidth,
      baseWidth: kWallWidth,
      snapHeightInterval: kBlockSizeInterval,
      snapWidthInterval: kBlockSizeInterval,
      // snapHeightInterval: _isVertical ? kBlockSizeInterval : null,
      // snapWidthInterval: _isVertical ? null : kBlockSizeInterval,
      snapWhileMoving: true,
      snapWhileResizing: true,
      snapOffsetInterval: const Offset(
        kBlockSize + kBlockToBlockGap,
        kBlockSize + kBlockToBlockGap,
      ),
      onTap: () {
        context.read<LevelEditorBloc>().add(EditorObjectSelected(wall));
      },
      onUpdate: (state) {
        final newSize = state.size;
        final newOffset = state.offset;
        if (wall.offset != newOffset || wall.size != newSize) {
          context.read<LevelEditorBloc>().add(
                EditorObjectMoved(
                  wall,
                  state.size,
                  state.offset,
                ),
              );
        }
      },
      builder: (context, size) {
        final width = size.width.boardSizeToBlockCount();
        final height = size.height.boardSizeToBlockCount();
        return AnimatedSelectable(
          isSelected: isSelected,
          child: PuzzleWall(Segment(
            Position(0, 0),
            Position(width, height),
          )),
        );
      },
    );
  }
}
