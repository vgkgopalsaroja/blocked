import 'package:flutter/material.dart';
import 'package:slide/widgets/puzzle/board_constants.dart';

class PuzzleFloor extends StatelessWidget {
  const PuzzleFloor({
    Key? key,
    required this.width,
    required this.height,
    this.child,
  }) : super(key: key);

  final int width;
  final int height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8.0),
      ),
      width: width.toBoardSize(),
      height: height.toBoardSize(),
      child: child,
    );
  }
}
