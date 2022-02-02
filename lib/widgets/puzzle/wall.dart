import 'package:flutter/material.dart';
import 'package:slide/puzzle/model/segment.dart';
import 'board_constants.dart';

class PuzzleWall extends StatelessWidget {
  const PuzzleWall(
    this.segment, {
    Key? key,
  }) : super(key: key);

  final Segment segment;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[600],
      borderRadius: BorderRadius.circular(2.0),
      child: Ink(
        width: segment.width.toWallSize(),
        height: segment.height.toWallSize(),
      ),
    );
  }
}

class PuzzleExit extends StatelessWidget {
  const PuzzleExit(this.segment, {Key? key}) : super(key: key);

  final Segment segment;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Ink(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 2.0,
          ),
        ),
        width: segment.width.toWallSize(),
        height: segment.height.toWallSize(),
      ),
    );
  }
}
