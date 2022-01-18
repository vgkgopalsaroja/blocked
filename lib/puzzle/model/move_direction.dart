enum MoveDirection { left, right, up, down }

extension MoveDirectionHelper on MoveDirection {
  bool get isVertical => this == MoveDirection.up || this == MoveDirection.down;
  bool get isHorizontal =>
      this == MoveDirection.left || this == MoveDirection.right;
}
