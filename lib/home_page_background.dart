import 'dart:math';

import 'package:blocked/level/level.dart';
import 'package:blocked/models/models.dart';
import 'package:blocked/puzzle/puzzle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePageBackground extends StatefulWidget {
  const HomePageBackground({Key? key}) : super(key: key);

  @override
  _HomePageBackgroundState createState() => _HomePageBackgroundState();
}

class _HomePageBackgroundState extends State<HomePageBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(duration: const Duration(seconds: 30), vsync: this);

  var moveIndex = 0;

  final List<MoveDirection> moves = [
    MoveDirection.right,
    MoveDirection.right,
    MoveDirection.down,
    MoveDirection.down,
    MoveDirection.left,
    MoveDirection.left,
    MoveDirection.up,
    MoveDirection.up,
  ];

  @override
  void initState() {
    super.initState();
    // Start from a random position.
    _controller.value = Random().nextDouble();
    _controller.repeat(period: const Duration(seconds: 60));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Create a puzzle that keeps moving
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SizedBox.expand(
          child: BlocProvider(
            create: (context) {
              return LevelBloc(
                LevelState.initial(
                  PuzzleState.initial(
                    3,
                    3,
                    initialBlock: const Block.main(1, 1).place(0, 0),
                    otherBlocks: [
                      const Block(1, 1).place(1, 0),
                      const Block(1, 1).place(2, 2),
                    ],
                    walls: [
                      Segment.horizontal(y: 0, start: 0, end: 3),
                      Segment.vertical(x: 0, start: 0, end: 3),
                      Segment.horizontal(y: 3, start: 0, end: 3),
                      Segment.vertical(x: 3, start: 0, end: 3),
                    ],
                  ),
                ),
              )..add(MoveAttempt(moves[moveIndex++]));
            },
            child: BlocListener<LevelBloc, LevelState>(
              listenWhen: (previous, current) => previous != current,
              listener: (context, state) async {
                final move = moves[moveIndex];
                await Future.delayed(kSlideDuration * 10);
                context.read<LevelBloc>().add(MoveAttempt(move));
                moveIndex = (moveIndex + 1) % moves.length;
              },
              child: Opacity(
                opacity: 0.1,
                child: RotationTransition(
                  turns: _controller.drive(Tween(begin: 1.0, end: 0.0)),
                  child: Transform.scale(
                    scale: 0.8,
                    child: const Puzzle(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
