import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_portal/flutter_portal.dart';

import 'package:slide/editor/editor.dart';
import 'package:slide/models/models.dart';
import 'package:slide/puzzle/puzzle.dart';
import 'package:slide/resizable/resizable.dart';

class ResizableSegment extends StatelessWidget {
  const ResizableSegment(this.wall, {Key? key}) : super(key: key);

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
        final snappedHorizontalSize = SnapSizeDelegate.interval(
          width: kBlockSizeInterval,
          widthOffset: kWallWidth,
          minWidth: kWallWidth,
          minHeight: kWallWidth,
          maxHeight: kWallWidth,
        ).sizeSnapper(size);

        final snappedVerticalSize = SnapSizeDelegate.interval(
          height: kBlockSizeInterval,
          heightOffset: kWallWidth,
          minHeight: kWallWidth,
          minWidth: kWallWidth,
          maxWidth: kWallWidth,
        ).sizeSnapper(size);

        final horizontalSnapDiff = Offset(
                snappedHorizontalSize.width - size.width,
                snappedHorizontalSize.height - size.height)
            .distance;
        final verticalSnapDiff = Offset(snappedVerticalSize.width - size.width,
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
      onUpdate: (position) {
        final newSize = position.size;
        final newOffset = position.offset;
        if (wall.offset != newOffset || wall.size != newSize) {
          context.read<LevelEditorBloc>().add(
                EditorObjectMoved(
                  wall,
                  position.size,
                  position.offset,
                ),
              );
        }
      },
      builder: (context, size) {
        final width = size.width.boardSizeToBlockCount();
        final height = size.height.boardSizeToBlockCount();
        return PortalEntry(
          visible: isSelected,
          childAnchor: Alignment.topRight,
          portalAnchor: Alignment.topLeft,
          portal: Padding(
            padding: const EdgeInsets.only(left: kHandleSize),
            child: ElevatedButton(
              onPressed: () {
                context
                    .read<LevelEditorBloc>()
                    .add(const SelectedEditorObjectDeleted());
              },
              child: const Icon(Icons.clear),
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
          child: AnimatedSelectable(
            isSelected: isSelected,
            child: isExit
                ? PuzzleExit(
                    Segment(const Position(0, 0), Position(width, height)))
                : PuzzleWall(
                    Segment(const Position(0, 0), Position(width, height))),
          ),
        );
      },
    );
  }
}
