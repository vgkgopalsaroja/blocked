import 'dart:math';

import 'package:flutter/material.dart';
import 'package:slide/puzzle/model/block.dart';
import 'package:slide/widgets/puzzle/board_constants.dart';

const _defaultDuration = Duration(milliseconds: 225); // kSlideDuration * 1.5

class PuzzleBlock extends StatelessWidget {
  const PuzzleBlock(
    this.block, {
    Key? key,
    this.isControlled = false,
    this.curve = const Interval(0.5, 1),
    this.duration = _defaultDuration,
  }) : super(key: key);

  final Block block;
  final bool isControlled;
  final Curve curve;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8.0,
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(2.0),
      child: AnimatedContainer(
        curve: curve,
        decoration: BoxDecoration(
          color: isControlled ? Colors.green[200] : Colors.grey[200],
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(
            color: isControlled ? Colors.green[700]! : Colors.grey[500]!,
            width: 4.0,
          ),
        ),
        duration: duration,
        width: block.width.toBlockSize(),
        height: block.height.toBlockSize(),
        child: block.isMain
            ? Icon(
                Icons.circle_outlined,
                color: isControlled ? Colors.green[800] : Colors.grey[700],
                size: min(block.width, block.height) * kBlockSize / 2,
              )
            : null,
      ),
    );
  }
}
