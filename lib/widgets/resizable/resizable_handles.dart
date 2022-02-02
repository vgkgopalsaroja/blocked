part of 'resizable.dart';

extension on BoxSide {
  bool get isCorner =>
      this == BoxSide.topLeft ||
      this == BoxSide.topRight ||
      this == BoxSide.bottomLeft ||
      this == BoxSide.bottomRight;
  bool get isVertical => this == BoxSide.top || this == BoxSide.bottom;
  bool get isHorizontal => this == BoxSide.left || this == BoxSide.right;

  MouseCursor toResizeCursor() {
    if (isVertical) {
      return SystemMouseCursors.resizeUpDown;
    } else if (isHorizontal) {
      return SystemMouseCursors.resizeLeftRight;
    } else if (this == BoxSide.topLeft) {
      return SystemMouseCursors.resizeUpLeft;
    } else if (this == BoxSide.topRight) {
      return SystemMouseCursors.resizeUpRight;
    } else if (this == BoxSide.bottomLeft) {
      return SystemMouseCursors.resizeDownLeft;
    } else if (this == BoxSide.bottomRight) {
      return SystemMouseCursors.resizeDownRight;
    } else {
      throw Error();
    }
  }
}

class PanHandle extends StatelessWidget {
  const PanHandle({Key? key, this.onTap}) : super(key: key);

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) {
          context.read<ResizableBloc>().add(Pan(
                delta: details.delta,
              ));
        },
        onPanEnd: (details) {
          context.read<ResizableBloc>().add(const PanEnd());
        },
        onTap: onTap,
      ),
    );
  }
}

class DragHandle extends StatelessWidget {
  const DragHandle(this.side, {required this.size, Key? key}) : super(key: key);

  final BoxSide side;
  final double size;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: side.toResizeCursor(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: side.isVertical
            ? (details) {
                context.read<ResizableBloc>().add(Resize(
                      side: side,
                      delta: details.primaryDelta!,
                    ));
              }
            : null,
        onVerticalDragEnd: side.isVertical
            ? (details) {
                context.read<ResizableBloc>().add(ResizeEnd());
              }
            : null,
        onHorizontalDragUpdate: side.isHorizontal
            ? (details) {
                context.read<ResizableBloc>().add(Resize(
                      side: side,
                      delta: details.primaryDelta!,
                    ));
              }
            : null,
        onHorizontalDragEnd: side.isHorizontal
            ? (details) {
                context.read<ResizableBloc>().add(const ResizeEnd());
              }
            : null,
        onPanUpdate: side.isCorner
            ? (details) {
                context.read<ResizableBloc>().add(ResizeCorner(
                      side: side,
                      delta: details.delta,
                    ));
              }
            : null,
        onPanEnd: side.isCorner
            ? (details) {
                context.read<ResizableBloc>().add(const ResizeEnd());
              }
            : null,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: size,
            minWidth: size,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: side.isHorizontal ? size / 4 : 0,
              vertical: side.isVertical ? size / 4 : 0,
            ),
            child: Container(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
