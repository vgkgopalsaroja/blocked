import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:slide/editor/bloc/level_editor_bloc.dart';
import 'package:slide/puzzle/model/block.dart';
import 'package:slide/puzzle/model/position.dart';
import 'package:slide/puzzle/model/puzzle_specifications.dart';
import 'package:slide/puzzle/model/segment.dart';
import 'package:slide/routing/app_route_path.dart';
import 'package:slide/widgets/editor/adaptive_button.dart';
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

import '../puzzle/level_reader.dart';
import '../routing/navigator_cubit.dart';

PuzzleSpecifications? tryParsePuzzleSpecs(String mapString) {
  try {
    return LevelReader.parsePuzzleSpecs(mapString);
  } on Object {
    return null;
  }
}

const kMobileWidth = 700;
const kEditorTileCount = 20;

class LevelEditorPage extends StatelessWidget {
  const LevelEditorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Portal(
      child: BlocProvider(
        create: (context) {
          NavigatorCubit navigatorCubit = context.read<NavigatorCubit>();
          PuzzleSpecifications? specs = tryParsePuzzleSpecs(
              (navigatorCubit.state as EditorRoutePath).mapString);
          return LevelEditorBloc(navigatorCubit, specs);
        },
        child: Builder(
          builder: (context) {
            final levelEditorBloc = context.read<LevelEditorBloc>();
            final isGridVisible = context.select(
              (LevelEditorBloc bloc) => bloc.state.isGridVisible,
            );
            return EditorShortcutListener(
              key: ValueKey(levelEditorBloc),
              levelEditorBloc: levelEditorBloc,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Level editor'),
                  elevation: 16.0,
                  backgroundColor: Theme.of(context).canvasColor,
                  actions: [
                    AdaptiveTextButton(
                      icon: isGridVisible
                          ? const Icon(Icons.grid_on_rounded)
                          : const Icon(Icons.grid_off_rounded),
                      label: const Text('Grid (G)'),
                      onPressed: () {
                        levelEditorBloc.add(const GridToggled());
                      },
                    ),
                    AdaptiveTextButton(
                      icon: const Icon(Icons.save),
                      label: const Text('Save (S)'),
                      onPressed: () {
                        levelEditorBloc.add(const SavePressed());
                      },
                    ),
                  ],
                ),
                bottomNavigationBar: const EditorToolbar(),
                floatingActionButton: FloatingActionButton.extended(
                  onPressed: () {
                    context.read<LevelEditorBloc>().add(const TestMapPressed());
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: MediaQuery.of(context).size.width > kMobileWidth
                      ? const Text('Play (Space/Enter)')
                      : const Text('Play'),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                body: BlocConsumer<LevelEditorBloc, LevelEditorState>(
                  listener: (context, state) {
                    SnackbarMessage? message = state.snackbarMessage;
                    if (message != null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(message.message),
                        backgroundColor:
                            message.type == SnackbarMessageType.error
                                ? Theme.of(context).colorScheme.errorContainer
                                : null,
                        duration: const Duration(seconds: 2),
                      ));
                    }
                  },
                  listenWhen: (previous, current) =>
                      previous.snackbarMessage != current.snackbarMessage,
                  builder: (context, state) {
                    return InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 1,
                      boundaryMargin: EdgeInsets.all(3.toBoardSize()),
                      constrained: false,
                      panEnabled: state.selectedTool == EditorTool.move,
                      child: SizedBox(
                        width: kEditorTileCount.toBoardSize() + 2 * kHandleSize,
                        height:
                            kEditorTileCount.toBoardSize() + 2 * kHandleSize,
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
                              Positioned.fill(
                                  child: GridOverlay(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.3),
                              )),
                            for (var object in state.objects) ...{
                              if (object is EditorFloor) ...{
                                ResizableFloor(
                                  object,
                                  state.exits
                                      .map((s) => s.toSegment())
                                      .toList(),
                                ),
                              }
                            },
                            for (var object in state.objects) ...{
                              if (object is EditorBlock) ...{
                                ResizableBlock(
                                  object,
                                  key: object.key,
                                ),
                              } else if (object is EditorSegment) ...{
                                ResizableWall(object, key: object.key),
                              }
                            },
                            if (state.selectedTool == EditorTool.segment)
                              _buildSegmentBuilder(levelEditorBloc),
                            if (state.selectedTool == EditorTool.block)
                              _buildBlockBuilder(levelEditorBloc),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSegmentBuilder(LevelEditorBloc levelEditorBloc) {
    return EditorBuilder(
      onObjectPlaced: (start, end) {
        Position snappedVerticalPosition = end.copyWith(x: start.x);
        Position snappedHorizontalPosition = end.copyWith(y: start.y);
        int verticalLength = (end.y - start.y).abs();
        int horizontalLength = (end.x - start.x).abs();
        Position snappedEndPosition = verticalLength > horizontalLength
            ? snappedVerticalPosition
            : snappedHorizontalPosition;

        levelEditorBloc
            .add(SegmentAdded(Segment.from(start, snappedEndPosition)));
      },
      offsetTransformer: (offset) {
        final x = max(
            0,
            ((offset.dx - kWallWidth - kHandleSize) / kBlockSizeInterval)
                .round());
        final y = max(
            0,
            ((offset.dy - kWallWidth - kHandleSize) / kBlockSizeInterval)
                .round());

        return Position(x, y);
      },
      positionTransformer: (position) {
        return Offset(
          kWallWidth + kHandleSize + (position.x * kBlockSizeInterval),
          kWallWidth + kHandleSize + (position.y * kBlockSizeInterval),
        );
      },
      threshold: kWallWidth * 2,
      hintBuilder: (start, end) {
        if (start != null && end != null) {
          Position snappedVerticalPosition = end.copyWith(x: start.x);
          Position snappedHorizontalPosition = end.copyWith(y: start.y);
          int verticalLength = (end.y - start.y).abs();
          int horizontalLength = (end.x - start.x).abs();
          Position snappedEndPosition = verticalLength > horizontalLength
              ? snappedVerticalPosition
              : snappedHorizontalPosition;

          final Segment segment = Segment.from(start, snappedEndPosition);
          return AnimatedPositioned(
            curve: Curves.easeOutCubic,
            duration: const Duration(milliseconds: 100),
            left: kHandleSize + segment.start.x.toWallOffset(),
            top: kHandleSize + segment.start.y.toWallOffset(),
            child: PuzzleWall(
              segment,
              curve: Curves.easeOutCubic,
              duration: const Duration(milliseconds: 100),
            ),
          );
        }
        return null;
      },
    );
  }

  Widget _buildBlockBuilder(LevelEditorBloc levelEditorBloc) {
    return EditorBuilder(
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
          final PlacedBlock block = PlacedBlock.from(start, end,
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
        return null;
      },
    );
  }
}
