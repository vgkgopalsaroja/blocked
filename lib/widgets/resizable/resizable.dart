import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'resizable_handles.dart';
part 'resizable_bloc.dart';
part 'resizable_event.dart';
part 'resizable_state.dart';
part 'resizable_delegates.dart';

typedef ResizableWidgetBuilder = Widget Function(
    BuildContext context, Size size);
typedef ResizableUpdateCallback = void Function(ResizableState state);

class Resizable extends StatelessWidget {
  const Resizable({
    Key? key,
    required this.builder,
    this.handleSize = 12.0,
    this.snapWhileMoving = false,
    this.snapWhileResizing = false,
    this.snapWidthInterval,
    this.snapHeightInterval,
    this.snapOffsetInterval,
    this.snapBaseOffset = Offset.zero,
    this.onUpdate,
    this.onTap,
    this.baseWidth = 0,
    this.baseHeight = 0,
    this.enabled = true,
    required this.minWidth,
    required this.minHeight,
  }) : super(key: key);

  final ResizableWidgetBuilder builder;
  final double handleSize;
  final double? snapWidthInterval;
  final double? snapHeightInterval;
  final double baseWidth;
  final double baseHeight;
  final double minWidth;
  final double minHeight;
  final Offset? snapOffsetInterval;
  final Offset snapBaseOffset;
  final bool snapWhileMoving;
  final bool snapWhileResizing;
  final ResizableUpdateCallback? onUpdate;
  final Function()? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ResizableBloc(
        top: snapBaseOffset.dy,
        left: snapBaseOffset.dx,
        width: minWidth,
        height: minHeight,
        snapSizeDelegate:
            // (snapWidthInterval != null || snapHeightInterval != null)
            SnapSizeDelegate.interval(
          min: Size(minWidth, minHeight),
          width: snapWidthInterval,
          height: snapHeightInterval,
          widthOffset: baseWidth,
          heightOffset: baseHeight,
        ),
        snapWhileResizing: snapWhileResizing,
        snapWhileMoving: snapWhileMoving,
        snapOffsetDelegate: snapOffsetInterval != null
            ? SnapOffsetDelegate.interval(
                offset: snapBaseOffset,
                interval: snapOffsetInterval!,
              )
            : null,
      ),
      child: BlocConsumer<ResizableBloc, ResizableState>(
        listener: (context, state) => onUpdate?.call(state),
        builder: (context, state) {
          return AnimatedPositioned(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            left: state.left,
            top: state.top,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
              width: state.width + 2 * handleSize,
              height: state.height + 2 * handleSize,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.all(handleSize),
                      child: builder(context, state.size),
                    ),
                  ),
                  if (enabled) ...{
                    Positioned(
                      left: 0,
                      top: handleSize,
                      bottom: handleSize,
                      child: DragHandle(
                        BoxSide.left,
                        size: handleSize,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: handleSize,
                      bottom: handleSize,
                      child: DragHandle(
                        BoxSide.right,
                        size: handleSize,
                      ),
                    ),
                    Positioned(
                      left: handleSize,
                      right: handleSize,
                      top: 0,
                      child: DragHandle(
                        BoxSide.top,
                        size: handleSize,
                      ),
                    ),
                    Positioned(
                      left: handleSize,
                      right: handleSize,
                      bottom: 0,
                      child: DragHandle(BoxSide.bottom, size: handleSize),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      child: DragHandle(BoxSide.topLeft, size: handleSize),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: DragHandle(BoxSide.topRight, size: handleSize),
                    ),
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: DragHandle(BoxSide.bottomLeft, size: handleSize),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: DragHandle(BoxSide.bottomRight, size: handleSize),
                    ),
                  },
                  Positioned.fill(
                    // bottom: handleSize,
                    // right: handleSize,
                    // top: handleSize,
                    // left: handleSize,
                    child: PanHandle(
                      onTap: onTap,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
