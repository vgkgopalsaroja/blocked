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
    final ColorScheme green = ColorScheme.fromSeed(
        seedColor: Colors.green, brightness: Theme.of(context).brightness);
    final ColorScheme grey = ColorScheme.fromSeed(
        seedColor: Colors.grey, brightness: Theme.of(context).brightness);
    return RepaintBoundary(
      child: Material(
        elevation: 8.0,
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(2.0),
        child: AnimatedContainer(
          curve: curve,
          decoration: BoxDecoration(
            color: isControlled ? green.primaryContainer : grey.surfaceVariant,
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(
              color: isControlled ? green.primary : grey.outline,
              width: 4.0,
            ),
          ),
          duration: duration,
          width: block.width.toBlockSize(),
          height: block.height.toBlockSize(),
          child: AnimatedOpacity(
            opacity: block.isMain ? 1 : 0,
            duration: duration,
            curve: curve,
            child: Icon(
              Icons.circle_outlined,
              color: isControlled ? green.primary : grey.outline,
              size: min(block.width, block.height) * kBlockSize / 2,
            ),
          ),
        ),
      ),
    );
  }
}
