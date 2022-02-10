import 'package:flutter/material.dart';
import 'package:slide/puzzle/bloc/puzzle_bloc.dart';
import 'package:slide/puzzle/model/block.dart';
import 'package:slide/widgets/puzzle/board_constants.dart';

class BoardPainter extends CustomPainter {
  const BoardPainter(this.context, this.board, this.controlledBlock);

  final PuzzleState board;
  final BuildContext context;
  final PlacedBlock controlledBlock;

  @override
  void paint(Canvas canvas, Size size) {
    // Floor
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(
                0, 0, board.width.toBoardSize(), board.height.toBoardSize()),
            const Radius.circular(2)),
        Paint()..color = Theme.of(context).colorScheme.surface);

    for (var wall in board.walls) {
      final wallPaint = Paint()..color = Theme.of(context).colorScheme.outline;
      final wallRect = Rect.fromLTWH(
          wall.start.x.toWallOffset(),
          wall.start.y.toWallOffset(),
          wall.width.toWallSize(),
          wall.height.toWallSize());
      canvas.drawRRect(
          RRect.fromRectAndRadius(wallRect, const Radius.circular(2)),
          wallPaint);
    }

    final ColorScheme green = ColorScheme.fromSeed(
        seedColor: Colors.green, brightness: Theme.of(context).brightness);
    final ColorScheme grey = ColorScheme.fromSeed(
        seedColor: Colors.grey, brightness: Theme.of(context).brightness);

    for (var block in board.blocks) {
      final blockPaint = Paint()
        ..color = block == controlledBlock
            ? green.primaryContainer
            : grey.surfaceVariant
        ..style = PaintingStyle.fill;
      final outlinePaint = Paint()
        ..color = block == controlledBlock ? green.primary : grey.outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      final blockRect = Rect.fromLTWH(
          block.position.x.toBlockOffset(),
          block.position.y.toBlockOffset(),
          block.width.toBlockSize(),
          block.height.toBlockSize());
      canvas.drawRRect(
          RRect.fromRectAndRadius(blockRect, const Radius.circular(2)),
          blockPaint);

      canvas.drawRRect(
          RRect.fromRectAndRadius(blockRect, const Radius.circular(2)),
          outlinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
