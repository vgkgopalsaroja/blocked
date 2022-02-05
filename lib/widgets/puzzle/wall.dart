import 'package:flutter/material.dart';
import 'package:slide/puzzle/model/segment.dart';
import 'board_constants.dart';

class PuzzleWall extends StatelessWidget {
  const PuzzleWall(
    this.segment, {
    Key? key,
    this.curve = Curves.linear,
    this.duration = const Duration(milliseconds: 0),
  }) : super(key: key);

  final Segment segment;
  final Curve curve;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      curve: curve,
      duration: duration,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outline,
        borderRadius: BorderRadius.circular(2.0),
      ),
      width: segment.width.toWallSize(),
      height: segment.height.toWallSize(),
    );
  }
}

class PuzzleExit extends StatelessWidget {
  const PuzzleExit(this.segment, {Key? key}) : super(key: key);

  final Segment segment;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 2.0,
        ),
      ),
      width: segment.width.toWallSize(),
      height: segment.height.toWallSize(),
    );
  }
}
