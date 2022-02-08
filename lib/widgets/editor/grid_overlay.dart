import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:slide/widgets/puzzle/board_constants.dart';
import 'package:slide/widgets/resizable/resizable.dart';

class GridOverlay extends StatelessWidget {
  const GridOverlay(
      {Key? key, this.color = const Color(0x66777777), this.child})
      : super(key: key);

  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        willChange: false,
        foregroundPainter: _GridOverlayPainter(color),
        child: child,
      ),
    );
  }
}

class _GridOverlayPainter extends CustomPainter {
  _GridOverlayPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (double x = kHandleSize;
        x + kWallWidth <= size.width;
        x += kBlockSizeInterval) {
      for (double y = kHandleSize;
          y + kWallWidth <= size.height;
          y += kBlockSizeInterval) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(x, y, kWallWidth, kWallWidth),
                const Radius.circular(2)),
            paint);
      }
    }
    for (double x = kHandleSize + kWallWidth + kBlockGap;
        x + kBlockSize <= size.width;
        x += kBlockSizeInterval) {
      for (double y = kHandleSize + kWallWidth + kBlockGap;
          y + kBlockSize <= size.height;
          y += kBlockSizeInterval) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(x, y, kBlockSize, kBlockSize),
                const Radius.circular(2)),
            paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
