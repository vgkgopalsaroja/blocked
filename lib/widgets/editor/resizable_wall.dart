import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/editor/bloc/level_editor_bloc.dart';
import 'package:slide/puzzle/model/position.dart';
import 'package:slide/puzzle/model/segment.dart';
import 'package:slide/widgets/editor/animated_selectable.dart';
import 'package:slide/widgets/puzzle/board_constants.dart';
import 'package:slide/widgets/puzzle/wall.dart';
import 'package:slide/widgets/resizable/resizable.dart';

class ResizableWall extends StatelessWidget {
  const ResizableWall(this.wall, {Key? key}) : super(key: key);

  final EditorSegment wall;

  @override
  Widget build(BuildContext context) {
    final isSelected = context.select(
      (LevelEditorBloc bloc) => bloc.state.selectedObject == wall,
    );

    final isExit = context.select(
      (LevelEditorBloc bloc) => bloc.state.isExit(wall),
    );

    return Resizable.custom(
      enabled: isSelected,
      minHeight: kWallWidth,
      minWidth: kWallWidth,
      baseHeight: kWallWidth,
      baseWidth: kWallWidth,
      initialOffset: wall.offset,
      initialSize: wall.size,
      snapSizeDelegate: SnapSizeDelegate((size) {
        // See which size is longer
        Size snappedHorizontalSize = SnapSizeDelegate.interval(
          width: kBlockSizeInterval,
          widthOffset: kWallWidth,
          minWidth: kWallWidth,
          minHeight: kWallWidth,
          maxHeight: kWallWidth,
        ).sizeSnapper(size);

        Size snappedVerticalSize = SnapSizeDelegate.interval(
          height: kBlockSizeInterval,
          heightOffset: kWallWidth,
          minHeight: kWallWidth,
          minWidth: kWallWidth,
          maxWidth: kWallWidth,
        ).sizeSnapper(size);

        double horizontalSnapDiff = Offset(
                snappedHorizontalSize.width - size.width,
                snappedHorizontalSize.height - size.height)
            .distance;
        double verticalSnapDiff = Offset(snappedVerticalSize.width - size.width,
                snappedVerticalSize.height - size.height)
            .distance;

        return horizontalSnapDiff < verticalSnapDiff
            ? snappedHorizontalSize
            : snappedVerticalSize;
      }),
      snapOffsetDelegate: SnapOffsetDelegate.interval(
        interval: const Offset(
          kBlockSize + kBlockToBlockGap,
          kBlockSize + kBlockToBlockGap,
        ),
      ),
      snapWhileMoving: true,
      snapWhileResizing: true,
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
          child: isExit
              ? PuzzleExit(
                  Segment(const Position(0, 0), Position(width, height)))
              : PuzzleWall(
                  Segment(const Position(0, 0), Position(width, height))),
        );
      },
    );
  }
}
