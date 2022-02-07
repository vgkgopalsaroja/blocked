import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:slide/widgets/puzzle/board_constants.dart';

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

    for (double x = 12; x < size.width; x += kBlockSizeInterval) {
      for (double y = 12; y < size.height; y += kBlockSizeInterval) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(x, y, kWallWidth, kWallWidth),
                const Radius.circular(2)),
            paint);
      }
    }
    for (double x = 12 + kWallWidth + kBlockGap;
        x < size.width;
        x += kBlockSizeInterval) {
      for (double y = 12 + kWallWidth + kBlockGap;
          y < size.height;
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
