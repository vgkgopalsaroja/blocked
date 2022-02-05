import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/editor/bloc/level_editor_bloc.dart';
import 'package:slide/puzzle/model/block.dart';
import 'package:slide/puzzle/model/position.dart';
import 'package:slide/pages/level_page.dart';
import 'package:slide/puzzle/level.dart';
import 'package:slide/puzzle/model/segment.dart';
import 'package:slide/widgets/editor/builder/builder.dart';
import 'package:slide/widgets/editor/editor_shortcut_listener.dart';
import 'package:slide/widgets/editor/grid_overlay.dart';
import 'package:slide/widgets/editor/resizable_block.dart';
import 'package:slide/widgets/editor/resizable_floor.dart';
import 'package:slide/widgets/editor/resizable_wall.dart';
import 'package:slide/widgets/editor/toolbar.dart';
import 'package:slide/widgets/puzzle/block.dart';
import 'package:slide/widgets/puzzle/board_constants.dart';
import 'package:slide/widgets/puzzle/wall.dart';
import 'package:slide/widgets/resizable/resizable.dart';

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
              final levelEditorBloc = context.read<LevelEditorBloc>();
              return EditorShortcutListener(
                key: ValueKey(levelEditorBloc),
                levelEditorBloc: levelEditorBloc,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            levelEditorBloc
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
                        ResizableBlock(
                          object,
                          key: object.key,
                        ),
                      } else if (object is EditorFloor) ...{
                        // ResizableFloor(
                        //     object, state.exits.map((s) => s.segment).toList()),
                      } else if (object is EditorSegment) ...{
                        ResizableWall(object, key: object.key),
                      }
                    },
                    if (state.selectedTool == EditorTool.segment)
                      EditorBuilder(
                        onObjectPlaced: (start, end) {
                          Position snappedVerticalPosition =
                              end.copyWith(x: start.x);
                          Position snappedHorizontalPosition =
                              end.copyWith(y: start.y);
                          int verticalLength = (end.y - start.y).abs();
                          int horizontalLength = (end.x - start.x).abs();
                          Position snappedEndPosition =
                              verticalLength > horizontalLength
                                  ? snappedVerticalPosition
                                  : snappedHorizontalPosition;

                          levelEditorBloc.add(SegmentAdded(
                              Segment.from(start, snappedEndPosition)));
                        },
                        offsetTransformer: (offset) {
                          final x = max(
                              0,
                              ((offset.dx - kWallWidth - kHandleSize) /
                                      kBlockSizeInterval)
                                  .round());
                          final y = max(
                              0,
                              ((offset.dy - kWallWidth - kHandleSize) /
                                      kBlockSizeInterval)
                                  .round());

                          return Position(x, y);
                        },
                        positionTransformer: (position) {
                          return Offset(
                            kWallWidth +
                                kHandleSize +
                                (position.x * kBlockSizeInterval),
                            kWallWidth +
                                kHandleSize +
                                (position.y * kBlockSizeInterval),
                          );
                        },
                        threshold: kWallWidth * 2,
                        hintBuilder: (start, end) {
                          if (start != null && end != null) {
                            Position snappedVerticalPosition =
                                end.copyWith(x: start.x);
                            Position snappedHorizontalPosition =
                                end.copyWith(y: start.y);
                            int verticalLength = (end.y - start.y).abs();
                            int horizontalLength = (end.x - start.x).abs();
                            Position snappedEndPosition =
                                verticalLength > horizontalLength
                                    ? snappedVerticalPosition
                                    : snappedHorizontalPosition;

                            final Segment segment =
                                Segment.from(start, snappedEndPosition);
                            return AnimatedPositioned(
                              curve: Curves.easeOutCubic,
                              duration: const Duration(milliseconds: 100),
                              left:
                                  kHandleSize + segment.start.x.toWallOffset(),
                              top: kHandleSize + segment.start.y.toWallOffset(),
                              child: PuzzleWall(
                                segment,
                                curve: Curves.easeOutCubic,
                                duration: const Duration(milliseconds: 100),
                              ),
                            );
                          }
                        },
                      ),
                    if (state.selectedTool == EditorTool.block)
                      EditorBuilder(
                        onObjectPlaced: (start, end) {
                          levelEditorBloc.add(BlockAdded(PlacedBlock.from(
                            start,
                            end,
                            isMain: false,
                            canMoveHorizontally: true,
                            canMoveVertically: true,
                          )));
                        },
                        offsetTransformer: (offset) {
                          final x = max(
                              0,
                              ((offset.dx -
                                          kWallWidth -
                                          kBlockGap -
                                          kHandleSize -
                                          kBlockSize / 2) /
                                      (kBlockSize + kBlockToBlockGap))
                                  .round());
                          final y = max(
                              0,
                              ((offset.dy -
                                          kWallWidth -
                                          kBlockGap -
                                          kHandleSize -
                                          kBlockSize / 2) /
                                      (kBlockSize + kBlockToBlockGap))
                                  .round());

                          return Position(x, y);
                        },
                        positionTransformer: (position) {
                          return Offset(
                            kWallWidth +
                                kBlockGap +
                                kHandleSize +
                                kBlockSize / 2 +
                                (position.x * (kBlockSize + kBlockToBlockGap)),
                            kWallWidth +
                                kBlockGap +
                                kHandleSize +
                                kBlockSize / 2 +
                                (position.y * (kBlockSize + kBlockToBlockGap)),
                          );
                        },
                        threshold: kBlockSize / 2,
                        hintBuilder: (start, end) {
                          if (start != null && end != null) {
                            final PlacedBlock block = PlacedBlock.from(
                                start, end,
                                isMain: false,
                                canMoveHorizontally: true,
                                canMoveVertically: true);

                            return AnimatedPositioned(
                              curve: Curves.easeOutCubic,
                              duration: const Duration(milliseconds: 100),
                              left: kHandleSize + block.left.toBlockOffset(),
                              top: kHandleSize + block.top.toBlockOffset(),
                              child: PuzzleBlock(
                                block,
                                curve: Curves.easeOutCubic,
                                duration: const Duration(milliseconds: 100),
                              ),
                            );
                          }
                        },
                      ),
                    const Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: RepaintBoundary(
                        child: Center(
                          child: EditorToolbar(),
                        ),
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
