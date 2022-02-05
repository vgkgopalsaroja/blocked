import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/editor/bloc/builder_bloc.dart';
import 'package:slide/puzzle/model/position.dart';

class EditorBuilder extends StatelessWidget {
  const EditorBuilder({
    Key? key,
    required this.onObjectPlaced,
    required this.hintBuilder,
    required this.offsetTransformer,
    required this.positionTransformer,
    required this.threshold,
  }) : super(key: key);

  final void Function(Position start, Position end) onObjectPlaced;
  final Widget? Function(Position? start, Position? end) hintBuilder;
  final Position Function(Offset offset) offsetTransformer;
  final Offset Function(Position position) positionTransformer;

  /// The number of pixels from a point that the cursor must be within to show hint.
  final double threshold;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditorBuilderBloc(),
      child: BlocConsumer<EditorBuilderBloc, EditorBuilderState>(
        listener: (context, state) {
          final start = state.start;
          final end = state.end;
          assert(start != null && end != null);
          onObjectPlaced(start!, end!);
        },
        listenWhen: (previous, current) {
          return previous.isObjectPlaced != current.isObjectPlaced &&
              current.isObjectPlaced;
        },
        buildWhen: (previous, current) {
          return previous.start != current.start || previous.end != current.end;
        },
        builder: (context, state) {
          final Position? start = state.start;
          final Position? end = state.end;

          return Listener(
            onPointerHover: (event) {
              final position = offsetTransformer(event.position);
              final snappedOffset = positionTransformer(position);
              final difference = snappedOffset - event.position;

              if (min(difference.dx, difference.dy) < threshold) {
                context.read<EditorBuilderBloc>().add(PointUpdate(position));
              } else {
                context.read<EditorBuilderBloc>().add(const PointCancelled());
              }
            },
            child: GestureDetector(
              dragStartBehavior: DragStartBehavior.down,
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                final position = offsetTransformer(details.globalPosition);
                context.read<EditorBuilderBloc>().add(PointDown(position));
              },
              onTapUp: (details) {
                final position = offsetTransformer(details.globalPosition);
                context.read<EditorBuilderBloc>().add(PointUp(position));
              },
              onPanDown: (details) {
                final position = offsetTransformer(details.globalPosition);
                context.read<EditorBuilderBloc>().add(PointDown(position));
              },
              onPanUpdate: (details) {
                final position = offsetTransformer(details.globalPosition);
                context.read<EditorBuilderBloc>().add(PointUpdate(position));
              },
              onPanEnd: (details) {
                final hoveredPosition =
                    context.read<EditorBuilderBloc>().state.hoveredPosition;

                context
                    .read<EditorBuilderBloc>()
                    .add(PointUp(hoveredPosition!));
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
        },
      ),
    );
  }
}