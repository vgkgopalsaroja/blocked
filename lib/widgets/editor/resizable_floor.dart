import 'package:flutter/material.dart';
import 'package:slide/editor/bloc/level_editor_bloc.dart';
import 'package:slide/puzzle/model/position.dart';
import 'package:slide/puzzle/model/segment.dart';
import 'package:slide/widgets/puzzle/board_constants.dart';
import 'package:slide/widgets/puzzle/floor.dart';
import 'package:slide/widgets/puzzle/wall.dart';
import 'package:slide/widgets/resizable/resizable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';

class ResizableFloor extends StatelessWidget {
  const ResizableFloor(this.floor, this.exits, {Key? key}) : super(key: key);

  final EditorFloor floor;
  final List<Segment> exits;

  @override
  Widget build(BuildContext context) {
    List<Segment> exits = context.select((LevelEditorBloc bloc) =>
        bloc.state.getExits().map((e) => e.toSegment()).toList());
    return Resizable(
      enabled: true,
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
        int boardWidth = size.width.boardSizeToBlockCount();
        int boardHeight = size.height.boardSizeToBlockCount();

        final walls = [
          Segment.from(Position(0, 0), Position(boardWidth, 0)),
          Segment.from(Position(0, 0), Position(0, boardHeight)),
          Segment.from(
              Position(0, boardHeight), Position(boardWidth, boardHeight)),
          Segment.from(
              Position(boardWidth, 0), Position(boardWidth, boardHeight)),
        ];

        final subtractedWalls = walls
            .map((wall) => wall.subtract(
                exits.firstOrNull?.translate(-floor.left, -floor.top)))
            .flattened
            .toList();

        return Stack(
          children: [
            PuzzleFloor(
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
            // for (var exit in exits) ...{
            //   Positioned(
            //     left: exit.start.x.toWallOffset(),
            //     top: exit.start.y.toWallOffset(),
            //     child: PuzzleExit(exit),
            //   ),
            // },
          ],
        );
      },
    );
  }
}
