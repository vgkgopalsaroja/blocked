part of 'block.dart';

class PlacedBlock extends Block with EquatableMixin {
  PlacedBlock.from(
    Position start,
    Position end, {
    required bool isMain,
    required bool canMoveHorizontally,
    required bool canMoveVertically,
  })  : position = Position(min(start.x, end.x), min(start.y, end.y)),
        super.manual((end.x - start.x).abs() + 1, (end.y - start.y).abs() + 1,
            isMain: isMain,
            canMoveHorizontally: canMoveHorizontally,
            canMoveVertically: canMoveVertically);

  const PlacedBlock(
    int width,
    int height,
    this.position, {
    required bool isMain,
    required bool canMoveHorizontally,
    required bool canMoveVertically,
  }) : super.manual(
          width,
          height,
          isMain: isMain,
          canMoveHorizontally: canMoveHorizontally,
          canMoveVertically: canMoveVertically,
        );

  final Position position;

  int get left => position.x;
  int get right => position.x + width - 1;
  int get top => position.y;
  int get bottom => position.y + height - 1;

  PlacedBlock translate(int dx, int dy) => PlacedBlock(
        width,
        height,
        position + Position(dx, dy),
        isMain: isMain,
        canMoveHorizontally: canMoveHorizontally,
        canMoveVertically: canMoveVertically,
      );

  @override
  List<Object?> get props =>
      [width, height, position, isMain, canMoveHorizontally, canMoveVertically];
}

extension PlaceBlock on Block {
  PlacedBlock withPosition(Position position) =>
      PlacedBlock(width, height, position,
          isMain: isMain,
          canMoveHorizontally: canMoveHorizontally,
          canMoveVertically: canMoveVertically);

  PlacedBlock place(int x, int y) => PlacedBlock(
        width,
        height,
        Position(x, y),
        isMain: isMain,
        canMoveHorizontally: canMoveHorizontally,
        canMoveVertically: canMoveVertically,
      );
}