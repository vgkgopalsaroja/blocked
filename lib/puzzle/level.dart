import 'package:slide/puzzle/bloc/puzzle_bloc.dart';
import 'package:slide/puzzle/model/block.dart';

import 'model/segment.dart';

class Level {
  const Level(this.name, {this.hint, required this.initialState});

  final String name;
  final String? hint;
  final PuzzleState initialState;
}

class Levels {
  static final List<Level> levels = [
    Level(
      '1',
      hint: 'Swipe or use the arrow keys to move.'
          '\nExit the room to win.',
      initialState: PuzzleState.initial(
        3,
        1,
        initialBlock: const Block.main(1, 1).place(0, 0),
        otherBlocks: [],
        innerWalls: [],
        exit: Segment.vertical(x: 3, start: 0, end: 1),
      ),
    ),
    Level(
      '2',
      hint: 'Move into blocks to transfer control.',
      initialState: PuzzleState.initial(
        3,
        3,
        initialBlock: const Block.main(1, 1).place(0, 0),
        otherBlocks: [
          const Block(2, 2).place(1, 0),
        ],
        innerWalls: [],
        exit: Segment.vertical(x: 3, start: 0, end: 1),
      ),
    ),
    Level(
      '3',
      initialState: PuzzleState.initial(
        3,
        3,
        initialBlock: const Block.main(1, 1).place(0, 0),
        otherBlocks: [
          const Block(1, 2).place(1, 0),
          const Block(1, 2).place(2, 0),
        ],
        innerWalls: [],
        exit: Segment.vertical(x: 3, start: 0, end: 1),
      ),
    ),
    Level(
      '4',
      hint: 'Only the main block (marked with a circle) can exit the room.',
      initialState: PuzzleState.initial(
        2,
        2,
        initialBlock: const Block.main(1, 1).place(0, 0),
        otherBlocks: [const Block(1, 1).place(1, 0)],
        innerWalls: [],
        exit: Segment.vertical(
          x: 2,
          start: 0,
          end: 1,
        ),
      ),
    ),
    Level(
      '5',
      hint: 'Control can only be transferred when there is exactly one target.',
      initialState: PuzzleState.initial(
        3,
        3,
        initialBlock: const Block.main(1, 2).place(0, 0),
        otherBlocks: [
          const Block(1, 1).place(1, 0),
          const Block(1, 1).place(1, 1),
          const Block(1, 1).place(0, 2),
        ],
        innerWalls: [],
        exit: Segment.horizontal(y: 3, start: 2, end: 3),
      ),
    ),
    Level(
      '6',
      initialState: PuzzleState.initial(
        4,
        3,
        initialBlock: const Block.main(2, 2).place(0, 0),
        otherBlocks: [
          const Block(1, 1).place(1, 2),
          const Block(1, 1).place(2, 0),
          const Block(1, 1).place(2, 1),
        ],
        innerWalls: [
          Segment.horizontal(y: 2, start: 2, end: 2),
          Segment.horizontal(y: 2, start: 3, end: 3),
        ],
        exit: Segment.vertical(x: 4, start: 0, end: 2),
      ),
    ),
    Level(
      '7',
      initialState: PuzzleState.initial(
        4,
        3,
        initialBlock: const Block.main(1, 1).place(0, 0),
        otherBlocks: [
          const Block(2, 1).place(1, 1),
          const Block(1, 2).place(3, 0),
          const Block(2, 1).place(1, 2),
        ],
        innerWalls: [
          Segment.horizontal(y: 1, start: 1, end: 1),
          Segment.horizontal(y: 2, start: 2, end: 2),
          // Segment.horizontal(y: 2, start: 3, end: 3),
        ],
        exit: Segment.vertical(x: 4, start: 0, end: 1),
      ),
    ),
    Level(
      '8',
      hint: 'You may not always start with the main block.',
      initialState: PuzzleState.initial(
        5,
        3,
        initialBlock: const Block(1, 1).place(1, 0),
        otherBlocks: [
          const Block(2, 1).place(2, 1),
          const Block(1, 1).place(4, 1),
          const Block.main(3, 1).place(1, 2),
        ],
        innerWalls: [
          Segment.vertical(x: 1, start: 2, end: 3),
          Segment.point(x: 2, y: 2),
        ],
        exit: Segment.vertical(x: 5, start: 0, end: 1),
      ),
    ),
    Level(
      '9',
      hint: 'Sometimes all you need is a little teamwork.',
      initialState: PuzzleState.initial(
        5,
        3,
        initialBlock: const Block.main(2, 1).place(0, 0),
        otherBlocks: [
          const Block(1, 2).place(4, 0),
          const Block(2, 1).place(2, 2),
          const Block(2, 1).place(2, 1),
        ],
        innerWalls: [
          Segment.point(x: 1, y: 1),
          Segment.horizontal(y: 1, start: 3, end: 4),
          Segment.point(x: 3, y: 2),
          Segment.vertical(x: 1, start: 2, end: 3),
        ],
        exit: Segment.vertical(x: 5, start: 0, end: 1),
      ),
    ),
  ];

  static Level? getLevelWithId(String id) {
    Iterable<Level> matchingLevels =
        Levels.levels.where((level) => level.name == id);
    if (matchingLevels.length == 1) {
      return matchingLevels.first;
    } else {
      return null;
    }
  }
}
