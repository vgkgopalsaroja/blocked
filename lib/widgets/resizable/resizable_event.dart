part of 'resizable.dart';

enum BoxSide {
  top,
  left,
  bottom,
  right,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

abstract class ResizeEvent {
  const ResizeEvent();
}

class Pan extends ResizeEvent {
  const Pan({required this.delta});

  final Offset delta;
}

class PanEnd extends ResizeEvent {
  const PanEnd();
}

class Resize extends ResizeEvent {
  const Resize({
    required this.side,
    required this.delta,
  });

  final BoxSide side;
  final double delta;
}

class ResizeCorner extends ResizeEvent {
  const ResizeCorner({
    required this.side,
    required this.delta,
  });

  final BoxSide side;
  final Offset delta;
}

class ResizeEnd extends ResizeEvent {
  const ResizeEnd();
}
