import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:slide/editor/editor.dart';
import 'package:slide/models/models.dart';
import 'package:slide/puzzle/puzzle.dart';
import 'package:slide/resizable/resizable.dart';

class ResizableFloor extends StatelessWidget {
  const ResizableFloor(this.floor, this.exits, {Key? key}) : super(key: key);

  final EditorFloor floor;
  final List<Segment> exits;

  @override
  Widget build(BuildContext context) {
    final exits = context.select((LevelEditorBloc bloc) =>
        bloc.state.exits.map((e) => e.toSegment()).toList());
    return Resizable(
      enabled: context
          .select((LevelEditorBloc bloc) => bloc.state.selectedObject == null),
      initialSize: Size(floor.width.toBoardSize(), floor.height.toBoardSize()),
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
      onTap: () {
        context.read<LevelEditorBloc>().add(const EditorObjectSelected(null));
      },
      onUpdate: (position) {
        final newSize = position.size;
        final newOffset = position.offset;
        if (floor.offset != newOffset || floor.size != newSize) {
          context.read<LevelEditorBloc>().add(
                EditorObjectMoved(
                  floor,
                  position.size,
                  position.offset,
                ),
              );
        }
      },
      builder: (context, size) {
        final boardWidth = size.width.boardSizeToBlockCount();
        final boardHeight = size.height.boardSizeToBlockCount();

        final walls = [
          Segment.from(const Position(0, 0), Position(boardWidth, 0)),
          Segment.from(const Position(0, 0), Position(0, boardHeight)),
          Segment.from(
              Position(0, boardHeight), Position(boardWidth, boardHeight)),
          Segment.from(
              Position(boardWidth, 0), Position(boardWidth, boardHeight)),
        ];

        final subtractedWalls = walls
            .map((wall) => wall.subtractAll(
                exits.map((e) => e.translate(-floor.left, -floor.top))))
            .flattened
            .toList();

        return Stack(
          children: [
            PuzzleFloor.material(
              width: boardWidth,
              height: boardHeight,
            ),
            for (var wall in subtractedWalls) ...{
              Positioned(
                left: wall.start.x.toWallOffset(),
                top: wall.start.y.toWallOffset(),
                child: PuzzleWall(wall),
              ),
            },
          ],
        );
      },
    );
  }
}
