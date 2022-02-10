import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/puzzle/bloc/puzzle_bloc.dart';
import 'package:slide/widgets/puzzle/board_constants.dart';
import 'package:slide/widgets/puzzle/board_painter.dart';

class StaticPuzzle extends StatelessWidget {
  const StaticPuzzle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final board = context.select((PuzzleBloc bloc) => bloc.state);
    final controlledBlock =
        context.select((PuzzleBloc bloc) => bloc.state.controlledBlock);

    return FittedBox(
      child: CustomPaint(
        size: Size(board.width.toBoardSize(), board.height.toBoardSize()),
        painter: BoardPainter(context, board, controlledBlock),
      ),
    );
  }
}
