import 'package:flutter/material.dart';
import 'package:slide/models/puzzle/puzzle.dart';
import 'package:slide/puzzle/puzzle.dart';

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
        color: BoardColor.of(context).wall,
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
          color: BoardColor.of(context).wall,
          width: 2.0,
        ),
      ),
      width: segment.width.toWallSize(),
      height: segment.height.toWallSize(),
    );
  }
}
