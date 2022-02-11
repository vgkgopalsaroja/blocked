part of 'puzzle_bloc.dart';

class PuzzleState {
  const PuzzleState(
    this.width,
    this.height, {
    required this.blocks,
    required this.walls,
    required this.controlledBlock,
    required this.latestMove,
    required this.isCompleted,
  });

  PuzzleState.initial(
    this.width,
    this.height, {
    required PlacedBlock initialBlock,
    required Iterable<PlacedBlock> otherBlocks,
    required this.walls,
  })  : blocks = [initialBlock, ...otherBlocks],
        controlledBlock = initialBlock,
        latestMove = null,
        isCompleted = false,
        assert(
            [initialBlock, ...otherBlocks]
                    .where((block) => block.isMain)
                    .length ==
                1,
            'Puzzle requires exactly one main block.'),
        assert(
            [initialBlock, ...otherBlocks].every((block) =>
                block.top >= 0 &&
                block.left >= 0 &&
                block.bottom < height &&
                block.right < width),
            'Blocks must be placed within the puzzle.');

  final int width;
  final int height;
  final List<PlacedBlock> blocks;
  final List<Segment> walls;
  final PlacedBlock controlledBlock;
  final Move? latestMove;
  final bool isCompleted;

  // List<Segment> get walls => [
  // ...Segment.horizontal(y: 0, start: 0, end: width).subtract(exit),
  // ...Segment.horizontal(y: height, start: 0, end: width).subtract(exit),
  // ...Segment.vertical(x: 0, start: 0, end: height).subtract(exit),
  // ...Segment.vertical(x: width, start: 0, end: height).subtract(exit),
  // ...innerWalls,
  // ];

  Iterable<PlacedBlock> getBlocksTop(PlacedBlock block) {
    return blocks
        .where((b) => b != block)
        .where((b) => b.bottom == block.top - 1)
        .where((b) =>
            _isRangeIntersecting(block.left, block.right, b.left, b.right));
  }

  Iterable<PlacedBlock> getBlocksBottom(PlacedBlock block) {
    return blocks
        .where((b) => b != block)
        .where((b) => b.top == block.bottom + 1)
        .where((b) =>
            _isRangeIntersecting(block.left, block.right, b.left, b.right));
  }

  Iterable<PlacedBlock> getBlocksLeft(PlacedBlock block) {
    return blocks
        .where((b) => b != block)
        .where((b) => b.right == block.left - 1)
        .where((b) =>
            _isRangeIntersecting(block.top, block.bottom, b.top, b.bottom));
  }

  Iterable<PlacedBlock> getBlocksRight(PlacedBlock block) {
    return blocks
        .where((b) => b != block)
        .where((b) => b.left == block.right + 1)
        .where((b) =>
            _isRangeIntersecting(block.top, block.bottom, b.top, b.bottom));
  }

  static bool _isRangeIntersecting(num min1, num max1, num min2, num max2) {
    return max(min1, min2) <= min(max1, max2);
  }

  PuzzleState withControlledBlock(PlacedBlock newControlledBlock, Move move) {
    assert(blocks.contains(newControlledBlock));
    return PuzzleState(
      width,
      height,
      blocks: blocks,
      walls: walls,
      controlledBlock: newControlledBlock,
      latestMove: move,
      isCompleted: false,
    );
  }

  Iterable<PlacedBlock> getBlocksAhead(
      PlacedBlock block, MoveDirection direction) {
    switch (direction) {
      case MoveDirection.up:
        return getBlocksTop(block);
      case MoveDirection.down:
        return getBlocksBottom(block);
      case MoveDirection.left:
        return getBlocksLeft(block);
      case MoveDirection.right:
        return getBlocksRight(block);
    }
  }

  PuzzleState withMoveAttempt(MoveAttempt move) {
    final movedBlock = controlledBlock;
    final newPosition = movedBlock.position.move(move.direction);
    final newBlock = movedBlock.withPosition(newPosition);
    if (hasWallInDirection(movedBlock, move.direction)) {
      return this;
    }

    final blocksAhead = getBlocksAhead(movedBlock, move.direction);

    if (blocksAhead.isNotEmpty) {
      if (blocksAhead.length == 1) {
        final newControlledBlock = blocksAhead.first;
        return withControlledBlock(
            newControlledBlock, move.blocked(movedBlock));
      } else {
        return PuzzleState(
          width,
          height,
          blocks: blocks,
          walls: walls,
          isCompleted: isCompleted,
          controlledBlock: controlledBlock,
          latestMove: move.blocked(movedBlock),
        );
      }
    }

    if (!canFit(newBlock) && !newBlock.isMain) {
      return PuzzleState(
        width,
        height,
        blocks: blocks,
        walls: walls,
        isCompleted: isCompleted,
        controlledBlock: controlledBlock,
        latestMove: move.blocked(movedBlock),
      );
    }

    return PuzzleState(
      width,
      height,
      blocks: blocks.map((b) {
        return b == movedBlock ? newBlock : b;
      }).toList(),
      walls: walls,
      isCompleted: !canFit(newBlock) && newBlock.isMain,
      controlledBlock:
          controlledBlock == movedBlock ? newBlock : controlledBlock,
      latestMove: move.moved(movedBlock),
    );
  }

  bool canFit(PlacedBlock block) {
    return block.top >= 0 &&
        block.left >= 0 &&
        block.bottom < height &&
        block.right < width;
  }

  bool hasWallInDirection(PlacedBlock block, MoveDirection direction) {
    switch (direction) {
      case MoveDirection.up:
        return walls.any((wall) =>
            wall.end.y == block.top &&
            _isRangeIntersecting(
                wall.start.x, wall.end.x, block.left + 0.5, block.right + 0.5));
      case MoveDirection.down:
        return walls.any((wall) =>
            wall.start.y == block.bottom + 1 &&
            _isRangeIntersecting(
                wall.start.x, wall.end.x, block.left + 0.5, block.right + 0.5));
      case MoveDirection.left:
        return walls.any((wall) =>
            wall.end.x == block.left &&
            _isRangeIntersecting(
                wall.start.y, wall.end.y, block.top + 0.5, block.bottom + 0.5));

      case MoveDirection.right:
        return walls.any((wall) =>
            wall.start.x == block.right + 1 &&
            _isRangeIntersecting(
                wall.start.y, wall.end.y, block.top + 0.5, block.bottom + 0.5));
    }
  }

  /// Convert the puzzle to a string representation parseable by [LevelReader].
  String toMapString() {
    return LevelReader.stateToMapString(this);
  }
}