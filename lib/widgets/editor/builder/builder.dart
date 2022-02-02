import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/editor/bloc/builder_bloc.dart';
import 'package:slide/puzzle/model/position.dart';
import 'package:slide/widgets/puzzle/board_constants.dart';

class WallBuilder extends StatelessWidget {
  const WallBuilder({Key? key, this.onObjectPlaced, required this.hintBuilder})
      : super(key: key);

  final void Function(Position start, Position end)? onObjectPlaced;
  final Widget? Function(Position? start, Position? end) hintBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditorBuilderBloc(),
      child: BlocListener<EditorBuilderBloc, EditorBuilderState>(
        listener: (context, state) {
          final start = state.start;
          final end = state.end;
          assert(start != null && end != null);
          onObjectPlaced?.call(start!, end!);
        },
        listenWhen: (previous, current) {
          return previous.isObjectPlaced != current.isObjectPlaced &&
              current.isObjectPlaced;
        },
        child: Builder(builder: (context) {
          final Position? start =
              context.select((EditorBuilderBloc bloc) => bloc.state.start);
          final Position? end =
              context.select((EditorBuilderBloc bloc) => bloc.state.end);

          return Listener(
            onPointerHover: (event) {
              final globalPosition = event.position;

              final x = max(
                  0,
                  ((globalPosition.dx - kWallWidth) / kBlockSizeInterval)
                      .round());
              final y = max(
                  0,
                  ((globalPosition.dy - kWallWidth) / kBlockSizeInterval)
                      .round());
              context
                  .read<EditorBuilderBloc>()
                  .add(PointHovered(Position(x, y)));
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                final globalPosition = details.globalPosition;
                final x = max(
                    0,
                    ((globalPosition.dx - kWallWidth) / kBlockSizeInterval)
                        .round());
                final y = max(
                    0,
                    ((globalPosition.dy - kWallWidth) / kBlockSizeInterval)
                        .round());
                context
                    .read<EditorBuilderBloc>()
                    .add(PointPressed(Position(x, y)));
              },
              onPanUpdate: (details) {
                final globalPosition = details.globalPosition;

                final x = max(
                    0,
                    ((globalPosition.dx - kWallWidth) / kBlockSizeInterval)
                        .round());
                final y = max(
                    0,
                    ((globalPosition.dy - kWallWidth) / kBlockSizeInterval)
                        .round());
                context
                    .read<EditorBuilderBloc>()
                    .add(PointHovered(Position(x, y)));
              },
              onPanEnd: (details) {
                final hoveredPosition =
                    context.read<EditorBuilderBloc>().state.hoveredPosition;

                context
                    .read<EditorBuilderBloc>()
                    .add(PointReleased(hoveredPosition!));
              },
              child: Stack(
                children: [
                  Positioned.fill(
                      child: Ink(
                    color: Colors.black.withOpacity(0.1),
                  )),
                  hintBuilder(start, end) ?? Container(),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
