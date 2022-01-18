import 'dart:math';

import 'package:slide/puzzle/model/position.dart';

class Segment {
  const Segment(this.start, this.end);

  final Position start;
  final Position end;

  int get width => end.x - start.x;
  int get height => end.y - start.y;
  bool get isVertical => start.x == end.x;
  bool get isHorizontal => start.y == end.y;

  Segment.point({
    required int x,
    required int y,
  })  : start = Position(x, y),
        end = Position(x, y);

  Segment.vertical({
    required int x,
    required int start,
    required int end,
  })  : start = Position(x, min(start, end)),
        end = Position(x, max(start, end));

  Segment.horizontal({
    required int y,
    required int start,
    required int end,
  })  : start = Position(min(start, end), y),
        end = Position(max(start, end), y);
}
