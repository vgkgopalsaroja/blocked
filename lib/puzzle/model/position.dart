class Position {
  const Position(this.x, this.y);
  final int x;
  final int y;

  @override
  String toString() {
    return 'Position{x: $x, y: $y}';
  }

  Position operator +(Position other) {
    return Position(x + other.x, y + other.y);
  }

  Position operator -(Position other) {
    return Position(x - other.x, y - other.y);
  }

  Position copyWith({int? x, int? y}) {
    return Position(x ?? this.x, y ?? this.y);
  }
}
