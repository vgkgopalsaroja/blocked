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
      // elevation: 8.0,
      child: Ink(
        width: segment.width.toWallSize(),
        height: segment.height.toWallSize(),
        // width: kBlockGap +
        //     (segment.width) * (kBlockGap + kBlockSize) -
        //     (segment.width > 0 ? kBlockGap : 0) +
        //     _getVerticalBorderCount() * (kBoardPadding - kBlockGap / 2),
        // height: kBlockGap +
        //     (segment.height) * (kBlockGap + kBlockSize) -
        //     (segment.height > 0 ? kBlockGap : 0) +
        //     _getHorizontalBorderCount() * (kBoardPadding - kBlockGap / 2),
      ),
    );
  }
}
