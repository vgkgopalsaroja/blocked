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

  int get cross => isVertical ? start.x : start.y;
  int get mainStart => isVertical ? start.y : start.x;
  int get mainEnd => isVertical ? end.y : end.x;

  Segment.from(
    Position start,
    Position end,
  )   : start = Position(min(start.x, end.x), min(start.y, end.y)),
        end = Position(max(start.x, end.x), max(start.y, end.y));

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

  Segment translate(int dx, int dy) => Segment.from(
        start + Position(dx, dy),
        end + Position(dx, dy),
      );

  Iterable<Segment> subtract(Segment? other) {
    if (other == null) {
      return [this];
    }
    if (isVertical != other.isVertical) {
      return [this];
    } else if (cross != other.cross) {
      return [this];
    }
    // assert(isVertical == other.isVertical);
    if (isVertical) {
      int x = cross;

      Segment intersection = Segment.vertical(
        x: x,
        start: max(start.y, other.start.y),
        end: min(end.y, other.end.y),
      );

      // Return the vertical segment that is not intersecting with the other segment.
      int start1 = start.y;
      int end1 = intersection.start.y;
      int start2 = intersection.end.y;
      int end2 = end.y;

      return [
        if (end1 > start1) Segment.vertical(x: x, start: start1, end: end1),
        if (end2 > start2) Segment.vertical(x: x, start: start2, end: end2),
      ];
    } else {
      int y = cross;

      Segment intersection = Segment.horizontal(
        y: y,
        start: max(start.x, other.start.x),
        end: min(end.x, other.end.x),
      );

      // Return the horizontal segment that is not intersecting with the other segment.
      int start1 = start.x;
      int end1 = intersection.start.x;
      int start2 = intersection.end.x;
      int end2 = end.x;

      return [
        if (end1 > start1) Segment.horizontal(y: y, start: start1, end: end1),
        if (end2 > start2) Segment.horizontal(y: y, start: start2, end: end2),
      ];
    }
  }

  // List<Segment> subtract(Segment segment) {
  //   if (segment.isVertical && isVertical && segment.start.x == start.x) {
  //     assert(start.y <= segment.start.y && end.y >= segment.end.y);
  //     return [
  //       Segment.vertical(x: start.x, start: start.y, end: segment.start.y),
  //       Segment.vertical(x: start.x, start: segment.end.y, end: end.y),
  //     ];
  //   } else if (segment.isHorizontal &&
  //       isHorizontal &&
  //       segment.start.y == start.y) {
  //     assert(start.x <= segment.start.x && end.x >= segment.end.x);
  //     return [
  //       Segment.horizontal(y: start.y, start: start.x, end: segment.start.x),
  //       Segment.horizontal(y: start.y, start: segment.end.x, end: end.x),
  //     ];
  //   } else {
  //     return [this];
  //   }
  // }
}
