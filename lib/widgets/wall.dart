import 'package:flutter/material.dart';
import 'package:slide/puzzle/model/segment.dart';
import 'board_constants.dart';

class Wall extends StatelessWidget {
  const Wall(
    this.segment, {
    required this.boardWidth,
    required this.boardHeight,
    Key? key,
  }) : super(key: key);

  final Segment segment;
  final int boardWidth;
  final int boardHeight;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[600],
      borderRadius: BorderRadius.circular(2.0),
      // elevation: 8.0,
      child: Ink(
        width: kBlockGap +
            (segment.width) * (kBlockGap + kBlockSize) -
            (segment.width > 0 ? kBlockGap : 0) +
            _getVerticalBorderCount() * (kBoardPadding - kBlockGap / 2),
        height: kBlockGap +
            (segment.height) * (kBlockGap + kBlockSize) -
            (segment.height > 0 ? kBlockGap : 0) +
            _getHorizontalBorderCount() * (kBoardPadding - kBlockGap / 2),
      ),
    );
  }

  // Returns the number of horizontal borders "touched".
  int _getHorizontalBorderCount() {
    int count = 0;
    if (segment.start.y == 0 && segment.end.y > 0) {
      count++;
    }
    if (segment.start.y < boardHeight && segment.end.y == boardHeight) {
      count++;
    }
    return count;
  }

  // Returns the number of vertical borders "touched".
  int _getVerticalBorderCount() {
    int count = 0;
    if (segment.start.x == 0 && segment.end.x > 0) {
      count++;
    }
    if (segment.start.x < boardWidth && segment.end.x == boardWidth) {
      count++;
    }
    return count;
  }
}
