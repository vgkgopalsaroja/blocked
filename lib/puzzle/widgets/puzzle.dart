import 'dart:math';

import 'package:blocked/models/models.dart';
import 'package:blocked/puzzle/puzzle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    final board = context.select((LevelBloc bloc) => bloc.state);
    final latestMove =
        context.select((LevelBloc bloc) => bloc.state.latestMove);
    final controlledBlock =
        context.select((LevelBloc bloc) => bloc.state.controlledBlock);
    final isCompleted =
        context.select((LevelBloc bloc) => bloc.state.isCompleted);

    return RepaintBoundary(
      child: FittedBox(
        child: BlocListener<LevelBloc, LevelState>(
          listenWhen: (previous, current) =>
              previous.latestMove != current.latestMove,
          listener: (context, state) async {
            final latestMove = state.latestMove;
            if (latestMove != null && !latestMove.didMove) {
              await controller.forward(from: 0);
              await controller.reverse();
            }
          },
          child: PuzzleFloor.container(
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
                    child: AnimatedOpacity(
                      opacity: board.isCompleted && block.isMain ? 0 : 1,
                      duration: kSlideDuration,
                      child: SlideTransition(
                        position: (block == latestMove?.block
                                ? controller
                                : const AlwaysStoppedAnimation(0.0))
                            .drive(CurveTween(curve: Curves.easeInOutCubic))
                            .drive(Tween(
                                begin: Offset.zero,
                                end: Offset.fromDirection(
                                    latestMove?.direction.toRadians() ?? 0,
                                    ((2 * kBlockGap + kWallWidth) /
                                            kBlockSize) /
                                        (latestMove?.direction.isVertical ??
                                                false
                                            ? block.height
                                            : block.width)))),
                        child: PuzzleBlock(
                          block,
                          isControlled: block == controlledBlock,
                        ),
                      ),
                    ),
                  ),
                for (var wall in board.walls)
                  Positioned(
                    left: wall.start.x.toWallOffset(),
                    top: wall.start.y.toWallOffset(),
                    child: PuzzleWall(wall),
                  ),
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: isCompleted ? 1 : 0,
                    duration: kSlideDuration,
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: AnimatedScale(
                        scale: isCompleted ? 1 : 0,
                        duration: kSlideDuration * 5,
                        curve: const Interval(1 / 3, 1.0,
                            curve: Curves.elasticOut),
                        child: const FittedBox(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Icon(
                              Icons.check,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
