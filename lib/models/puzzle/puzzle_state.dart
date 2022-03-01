import 'dart:math';

import 'package:blocked/models/puzzle/puzzle.dart';
import 'package:blocked/puzzle/puzzle.dart';
import 'package:equatable/equatable.dart';

class PuzzleState extends Equatable {
  PuzzleState.initial(
    this.width,
    this.height, {
    required PlacedBlock initialBlock,
    required Iterable<PlacedBlock> otherBlocks,
    required this.walls,
  })  : blocks = [initialBlock, ...otherBlocks],
        controlledBlock = initialBlock,
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

  const PuzzleState(
    this.width,
    this.height, {
    required this.blocks,
    required this.walls,
    required this.controlledBlock,
  });

  final int width;
  final int height;
  final List<PlacedBlock> blocks;
  final List<Segment> walls;
  final PlacedBlock controlledBlock;

  PlacedBlock get mainBlock => blocks.firstWhere((block) => block.isMain);
  bool get isCompleted => !_canFit(mainBlock);

  PuzzleState withMoveAttempt(MoveAttempt move) {
    final movedBlock = controlledBlock;
    final newPosition = movedBlock.position.shifted(move.direction);
    final newBlock = movedBlock.withPosition(newPosition);
    if (hasWallInDirection(movedBlock, move.direction)) {
      return this;
    }

    final blocksAhead = _getBlocksAhead(movedBlock, move.direction);

    if (blocksAhead.isNotEmpty) {
      if (blocksAhead.length == 1) {
        final newControlledBlock = blocksAhead.first;
        return _withControlledBlock(newControlledBlock);
      } else {
        return this;
      }
    }

    if (!_canFit(newBlock) && !newBlock.isMain) {
      return this;
    }

    return _withMovedBlock(movedBlock, move.direction);
  }

  PuzzleState _withControlledBlock(PlacedBlock newControlledBlock) {
    return PuzzleState(
      width,
      height,
      blocks: blocks,
      walls: walls,
      controlledBlock: newControlledBlock,
    );
  }

  PuzzleState _withMovedBlock(PlacedBlock movedBlock, MoveDirection direction) {
    final newPosition = movedBlock.position.shifted(direction);
    final newBlock = movedBlock.withPosition(newPosition);
    return PuzzleState(
      width,
      height,
      blocks: blocks.map((b) {
        return b == movedBlock ? newBlock : b;
      }).toList(),
      walls: walls,
      controlledBlock:
          controlledBlock == movedBlock ? newBlock : controlledBlock,
    );
  }

  Iterable<PlacedBlock> _getBlocksAhead(
      PlacedBlock block, MoveDirection direction) {
    switch (direction) {
      case MoveDirection.up:
        return _getBlocksTop(block);
      case MoveDirection.down:
        return _getBlocksBottom(block);
      case MoveDirection.left:
        return _getBlocksLeft(block);
      case MoveDirection.right:
        return _getBlocksRight(block);
    }
  }

  Iterable<PlacedBlock> _getBlocksTop(PlacedBlock block) {
    return blocks
        .where((b) => b != block)
        .where((b) => b.bottom == block.top - 1)
        .where((b) =>
            _isRangeIntersecting(block.left, block.right, b.left, b.right));
  }

  Iterable<PlacedBlock> _getBlocksBottom(PlacedBlock block) {
    return blocks
        .where((b) => b != block)
        .where((b) => b.top == block.bottom + 1)
        .where((b) =>
            _isRangeIntersecting(block.left, block.right, b.left, b.right));
  }

  Iterable<PlacedBlock> _getBlocksLeft(PlacedBlock block) {
    return blocks
        .where((b) => b != block)
        .where((b) => b.right == block.left - 1)
        .where((b) =>
            _isRangeIntersecting(block.top, block.bottom, b.top, b.bottom));
  }

  Iterable<PlacedBlock> _getBlocksRight(PlacedBlock block) {
    return blocks
        .where((b) => b != block)
        .where((b) => b.left == block.right + 1)
        .where((b) =>
            _isRangeIntersecting(block.top, block.bottom, b.top, b.bottom));
  }

  bool _canFit(PlacedBlock block) {
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

  static bool _isRangeIntersecting(num min1, num max1, num min2, num max2) {
    return max(min1, min2) <= min(max1, max2);
  }

  @override
  List<Object?> get props => [
        width,
        height,
        blocks,
        walls,
        controlledBlock,
      ];
}

extension on Position {
  Position shifted(MoveDirection direction) {
    switch (direction) {
      case MoveDirection.up:
        return Position(x, y - 1);
      case MoveDirection.down:
        return Position(x, y + 1);
      case MoveDirection.left:
        return Position(x - 1, y);
      case MoveDirection.right:
        return Position(x + 1, y);
    }
  }
}
