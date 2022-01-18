import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/puzzle/bloc/puzzle_bloc.dart';
import 'package:slide/puzzle/model/block.dart';
import 'package:slide/puzzle/model/move_direction.dart';
import 'package:slide/widgets/wall.dart';
import 'board_constants.dart';

class Board extends StatefulWidget {
  const Board({Key? key}) : super(key: key);

  static const slideDuration = Duration(milliseconds: 150);

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: Board.slideDuration * 0.5,
  );

  @override
  Widget build(BuildContext context) {
    final board = context.select((PuzzleBloc bloc) => bloc.state);
    final latestMove =
        context.select((PuzzleBloc bloc) => bloc.state.latestMove);

    return BlocListener<PuzzleBloc, PuzzleState>(
      listener: (context, state) async {
        final latestMove = state.latestMove;
        if (latestMove != null && !latestMove.didMove) {
          await controller.forward(from: 0);
          await controller.reverse();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
        ),
        width: board.width * kBlockSize +
            kBoardPadding * 2 +
            kBlockGap * (board.width - 1),
        height: board.height * kBlockSize +
            kBoardPadding * 2 +
            kBlockGap * (board.height - 1),
        // padding: const EdgeInsets.all(kBoardPadding),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topLeft,
          children: [
            for (var block in board.blocks)
              AnimatedPositioned(
                key: ValueKey(board.blocks.indexOf(block)),
                duration: Board.slideDuration,
                curve: Curves.easeInOutCubic,
                left: block.left.toBoardOffset(),
                top: block.top.toBoardOffset(),
                child: SlideTransition(
                  position: (block == latestMove?.block
                          ? controller
                          : const AlwaysStoppedAnimation(0.0))
                      .drive(CurveTween(curve: Curves.easeInOutCubic))
                      .drive(Tween(
                          begin: Offset.zero,
                          end: Offset.fromDirection(
                              latestMove?.direction.toRadians() ?? 0,
                              kBlockGap /
                                  kBlockSize /
                                  (latestMove?.direction.isVertical ?? false
                                      ? block.height
                                      : block.width)))),
                  child: PuzzleBlock(block),
                ),
              ),
            for (var wall in board.walls)
              Positioned(
                left: wall.start.x.toWallOffset(board.width, wall.width == 0),
                top: wall.start.y.toWallOffset(board.height, wall.height == 0),
                child: Wall(
                  wall,
                  boardWidth: board.width,
                  boardHeight: board.height,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PuzzleBlock extends StatelessWidget {
  const PuzzleBlock(
    this.block, {
    Key? key,
  }) : super(key: key);

  final PlacedBlock block;

  @override
  Widget build(BuildContext context) {
    final controlledBlock =
        context.select((PuzzleBloc bloc) => bloc.state.controlledBlock);
    return Material(
      elevation: 8.0,
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(4.0),
      child: AnimatedContainer(
        curve: const Interval(0.5, 1),
        decoration: BoxDecoration(
          color:
              controlledBlock == block ? Colors.green[200] : Colors.grey[200],
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(
            color: controlledBlock == block
                ? Colors.green[700]!
                : Colors.grey[500]!,
            width: 4.0,
          ),
        ),
        duration: Board.slideDuration * 1.5,
        width: block.width * kBlockSize + kBlockGap * (block.width - 1),
        height: block.height * kBlockSize + kBlockGap * (block.height - 1),
        child: block.isMain
            ? Icon(
                Icons.circle_outlined,
                color: controlledBlock == block
                    ? Colors.green[800]
                    : Colors.grey[700],
                size: min(block.width, block.height) * kBlockSize / 2,
              )
            : null,
      ),
    );
  }
}

extension on int {
  double toBoardOffset() {
    return kBoardPadding + this * (kBlockSize + kBlockGap);
  }

  double toWallOffset(int maxValue, bool isWidthOne) {
    return (this > 0 ? (kBoardPadding - kBlockGap) : 0) +
        (this == maxValue ? (kBoardPadding - kBlockGap) : 0) +
        this * (kBlockSize + kBlockGap);
  }
}

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
