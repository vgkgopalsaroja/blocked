import 'dart:math';

import 'package:flutter/material.dart';
import 'package:slide/models/models.dart';
import 'package:slide/puzzle/puzzle.dart';

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
    final boardColors = BoardColor.of(context);
    return RepaintBoundary(
      child: Material(
        elevation: 8.0,
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(2.0),
        child: AnimatedContainer(
          curve: curve,
          decoration: BoxDecoration(
            color:
                isControlled ? boardColors.controlledBlock : boardColors.block,
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(
              color: isControlled
                  ? boardColors.controlledBlockOutline
                  : boardColors.blockOutline,
              width: 4.0,
            ),
          ),
          duration: duration,
          width: block.width.toBlockSize(),
          height: block.height.toBlockSize(),
          alignment: Alignment.center,
          child: AnimatedOpacity(
            opacity: block.isMain ? 1 : 0,
            duration: duration,
            curve: curve,
            child: AnimatedSwitcher(
              duration: duration,
              switchInCurve: curve,
              switchOutCurve: curve.flipped,
              child: Icon(
                Icons.circle_outlined,
                key: ValueKey(isControlled),
                color: isControlled
                    ? boardColors.controlledBlockOutline
                    : boardColors.blockOutline,
                size: min(block.width, block.height) * kBlockSize / 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StaticPuzzleBlock extends StatelessWidget {
  const StaticPuzzleBlock(
    this.block, {
    Key? key,
    this.isControlled = false,
  }) : super(key: key);

  final Block block;
  final bool isControlled;

  @override
  Widget build(BuildContext context) {
    final green = ColorScheme.fromSeed(
        seedColor: Colors.green, brightness: Theme.of(context).brightness);
    final grey = ColorScheme.fromSeed(
        seedColor: Colors.grey, brightness: Theme.of(context).brightness);
    return RepaintBoundary(
      child: Material(
        elevation: 8.0,
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(2.0),
        child: Container(
          decoration: BoxDecoration(
            color: isControlled ? green.primaryContainer : grey.surfaceVariant,
            borderRadius: BorderRadius.circular(2.0),
            border: Border.all(
              color: isControlled ? green.primary : grey.outline,
              width: 4.0,
            ),
          ),
          width: block.width.toBlockSize(),
          height: block.height.toBlockSize(),
          child: Icon(
            Icons.circle_outlined,
            color: isControlled ? green.primary : grey.outline,
            size: min(block.width, block.height) * kBlockSize / 2,
          ),
        ),
      ),
    );
  }
}
