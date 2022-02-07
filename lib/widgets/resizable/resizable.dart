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
typedef ResizableUpdateCallback = void Function(
    ResizablePosition resizablePosition);

const double kHandleSize = 12.0;

class Resizable extends StatelessWidget {
  Resizable({
    Key? key,
    required this.builder,
    this.snapWhileMoving = false,
    this.snapWhileResizing = false,
    double? snapWidthInterval,
    double? snapHeightInterval,
    Offset? snapOffsetInterval,
    this.snapBaseOffset = Offset.zero,
    this.onUpdate,
    this.onTap,
    this.baseWidth = 0,
    this.baseHeight = 0,
    this.initialSize,
    this.initialOffset,
    this.enabled = true,
    required this.minWidth,
    required this.minHeight,
  })  : snapSizeDelegate =
            (snapWidthInterval != null && snapHeightInterval != null)
                ? SnapSizeDelegate.interval(
                    minWidth: minWidth,
                    minHeight: minHeight,
                    width: snapWidthInterval,
                    height: snapHeightInterval,
                    widthOffset: baseWidth,
                    heightOffset: baseHeight,
                  )
                : null,
        snapOffsetDelegate = snapOffsetInterval != null
            ? SnapOffsetDelegate.interval(
                offset: snapBaseOffset,
                interval: snapOffsetInterval,
              )
            : null,
        super(key: key);

  const Resizable.custom({
    Key? key,
    required this.builder,
    this.snapWhileMoving = false,
    this.snapWhileResizing = false,
    this.snapSizeDelegate,
    this.snapOffsetDelegate,
    this.snapBaseOffset = Offset.zero,
    this.onUpdate,
    this.onTap,
    this.baseWidth = 0,
    this.baseHeight = 0,
    this.initialSize,
    this.initialOffset,
    this.enabled = true,
    required this.minWidth,
    required this.minHeight,
  }) : super(key: key);

  final ResizableWidgetBuilder builder;
  final SnapOffsetDelegate? snapOffsetDelegate;
  final SnapSizeDelegate? snapSizeDelegate;
  final double baseWidth;
  final double baseHeight;
  final double minWidth;
  final double minHeight;
  final Size? initialSize;
  final Offset? initialOffset;
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
        top: initialOffset?.dy ?? snapBaseOffset.dy,
        left: initialOffset?.dx ?? snapBaseOffset.dx,
        width: initialSize?.width ?? minWidth,
        height: initialSize?.height ?? minHeight,
        snapSizeDelegate: snapSizeDelegate,
        snapOffsetDelegate: snapOffsetDelegate,
        snapWhileResizing: snapWhileResizing,
        snapWhileMoving: snapWhileMoving,
      ),
      child: BlocConsumer<ResizableBloc, ResizableState>(
        listenWhen: (previous, current) =>
            previous.displayedPosition != current.displayedPosition,
        listener: (context, state) => onUpdate?.call(state.displayedPosition),
        buildWhen: (previous, current) =>
            previous.displayedPosition != current.displayedPosition,
        builder: (context, state) {
          return AnimatedPositioned(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            left: state.left,
            top: state.top,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
              width: state.width + 2 * kHandleSize,
              height: state.height + 2 * kHandleSize,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(kHandleSize),
                      child: builder(context, state.size),
                    ),
                  ),
                  if (enabled) ...{
                    const Positioned(
                      left: 0,
                      top: kHandleSize,
                      bottom: kHandleSize,
                      child: DragHandle(
                        BoxSide.left,
                        size: kHandleSize,
                      ),
                    ),
                    const Positioned(
                      right: 0,
                      top: kHandleSize,
                      bottom: kHandleSize,
                      child: DragHandle(
                        BoxSide.right,
                        size: kHandleSize,
                      ),
                    ),
                    const Positioned(
                      left: kHandleSize,
                      right: kHandleSize,
                      top: 0,
                      child: DragHandle(
                        BoxSide.top,
                        size: kHandleSize,
                      ),
                    ),
                    const Positioned(
                      left: kHandleSize,
                      right: kHandleSize,
                      bottom: 0,
                      child: DragHandle(BoxSide.bottom, size: kHandleSize),
                    ),
                    const Positioned(
                      left: 0,
                      top: 0,
                      child: DragHandle(BoxSide.topLeft, size: kHandleSize),
                    ),
                    const Positioned(
                      right: 0,
                      top: 0,
                      child: DragHandle(BoxSide.topRight, size: kHandleSize),
                    ),
                    const Positioned(
                      left: 0,
                      bottom: 0,
                      child: DragHandle(BoxSide.bottomLeft, size: kHandleSize),
                    ),
                    const Positioned(
                      right: 0,
                      bottom: 0,
                      child: DragHandle(BoxSide.bottomRight, size: kHandleSize),
                    ),
                  },
                  Positioned.fill(
                    bottom: kHandleSize,
                    right: kHandleSize,
                    top: kHandleSize,
                    left: kHandleSize,
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
