import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/puzzle/bloc/puzzle_bloc.dart';
import 'package:slide/puzzle/model/move_direction.dart';
import 'package:slide/widgets/puzzle/floor.dart';
import 'package:slide/widgets/puzzle/block.dart';
import 'package:slide/widgets/puzzle/wall.dart';
import 'board_constants.dart';

class Puzzle extends StatefulWidget {
  const Puzzle({Key? key}) : super(key: key);

  @override
  State<Puzzle> createState() => _PuzzleState();
}

class _PuzzleState extends State<Puzzle> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: kSlideDuration * 0.5,
  );

  @override
  Widget build(BuildContext context) {
    final board = context.select((PuzzleBloc bloc) => bloc.state);
    final latestMove =
        context.select((PuzzleBloc bloc) => bloc.state.latestMove);
    final controlledBlock =
        context.select((PuzzleBloc bloc) => bloc.state.controlledBlock);

    return BlocListener<PuzzleBloc, PuzzleState>(
      listener: (context, state) async {
        final latestMove = state.latestMove;
        if (latestMove != null && !latestMove.didMove) {
          await controller.forward(from: 0);
          await controller.reverse();
        }
      },
      child: PuzzleFloor(
        width: board.width,
        height: board.height,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topLeft,
          children: [
            for (var block in board.blocks)
              AnimatedPositioned(
                key: ValueKey(board.blocks.indexOf(block)),
                duration: kSlideDuration,
                curve: Curves.easeInOutCubic,
                left: block.left.toBlockOffset(),
                top: block.top.toBlockOffset(),
                child: SlideTransition(
                  position: (block == latestMove?.block
                          ? controller
                          : const AlwaysStoppedAnimation(0.0))
                      .drive(CurveTween(curve: Curves.easeInOutCubic))
                      .drive(Tween(
                          begin: Offset.zero,
                          end: Offset.fromDirection(
                              latestMove?.direction.toRadians() ?? 0,
                              ((2 * kBlockGap + kWallWidth) / kBlockSize) /
                                  (latestMove?.direction.isVertical ?? false
                                      ? block.height
                                      : block.width)))),
                  child: PuzzleBlock(
                    block,
                    isControlled: block == controlledBlock,
                  ),
                ),
              ),
            for (var wall in board.walls)
              Positioned(
                left: wall.start.x.toWallOffset(),
                top: wall.start.y.toWallOffset(),
                child: PuzzleWall(wall),
              ),
          ],
        ),
      ),
    );
  }
}

// int getBoardSize(int width) {
//   return width.toWallOffset() + kWallWidth;
// }

extension on MoveDirection {
  double toRadians() {
    switch (this) {
      case MoveDirection.right:
        return 0.0;
      case MoveDirection.down:
        return 0.5 * pi;
      case MoveDirection.left:
        return 1.0 * pi;
      case MoveDirection.up:
        return 1.5 * pi;
    }
  }
}
