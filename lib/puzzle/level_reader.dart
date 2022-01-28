import 'package:slide/puzzle/bloc/puzzle_bloc.dart';
import 'package:slide/puzzle/level.dart';
import 'package:slide/puzzle/model/block.dart';
import 'package:slide/puzzle/model/position.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

import 'model/segment.dart';

const String wall = '*';
const String empty = '.';
const String block = 'x';
const String mainBlock = 'm';
const String exit = 'e';

typedef Tile = int;

class TileType {
  static const wall = 1;
  static const block = 2;
  static const empty = 4;
  static const main = 8;
  static const exit = 16;
  static const control = 32;
}

const defaultMap = [
  '########e',
  '#MMM.x..e',
  '#..#..#.e',
  '#xxx.xxx#',
  '#..#....#',
  '#..x.x..#',
  '#########',
];

bool isTileType(Tile tile, Tile type) {
  return (tile & type) == type;
}

class LevelData {
  const LevelData({
    required this.name,
    this.hint,
    required this.map,
  });

  final String name;
  final String? hint;
  final String map;

  Level toLevel() {
    return Level(
      name,
      hint: hint,
      initialState: LevelReader.parseLevel(
        LevelReader.parseMapToTiles(map.split('\n')),
      ),
    );
  }
}

class LevelReader {
  static Future<List<LevelData>> readLevels() async {
    final List<LevelData> levels = [];
    final data = await rootBundle.loadString('assets/levels.yaml');
    final mapData = loadYaml(data);
    for (YamlMap levelData in mapData) {
      String name = levelData['name']!.toString();
      String? hint = levelData['hint'];
      String map = levelData['map']!.toString();
      levels.add(LevelData(
        name: name.toString(),
        hint: hint?.toString(),
        map: map,
      ));
    }
    return levels;
  }

  static List<List<Tile>> parseMapToTiles(Iterable<String> rawMap) {
    return rawMap.map((line) {
      return line.split('').map((char) {
        if (char == wall) {
          return TileType.wall;
        } else if (char == empty) {
          return TileType.empty;
        } else if (char == exit) {
          return TileType.exit;
        } else {
          int baseBlock = char.toLowerCase() == block
              ? TileType.block
              : TileType.block | TileType.main;
          if (char == char.toUpperCase()) {
            baseBlock = baseBlock | TileType.control;
          }
          return baseBlock;
        }
      }).toList();
    }).toList();
  }

  static List<Segment> getSegmentsOfType(List<List<Tile>> map, Tile type) {
    List<Segment> segments = [];
    int width = map[0].length;
    int height = map.length;

    bool isWall(int x, int y) {
      if (x >= 0 && x < width && y >= 0 && y < height) {
        return isTileType(map[y][x], type);
      } else {
        return false;
      }
    }

    // Get horizontal walls
    for (var row = 0; row < height; row++) {
      // int? wallStart;
      var starts = Iterable.generate(width,
              (col) => isWall(col, row) && !isWall(col - 1, row) ? col : -1)
          .where((index) => index != -1)
          .toList();
      var ends = Iterable.generate(width,
              (col) => isWall(col, row) && !isWall(col + 1, row) ? col : -1)
          .where((index) => index != -1)
          .toList();

      assert(starts.length == ends.length);

      for (var i = 0; i < starts.length; i++) {
        // Only add isolated walls
        if (starts[i] == ends[i]) {
          var x = starts[i];
          if (!isWall(x, row - 1) && !isWall(x, row + 1)) {
            segments.add(Segment.point(x: x ~/ 2, y: row ~/ 2));
          }
        } else {
          segments.add(Segment.horizontal(
              y: row ~/ 2, start: starts[i] ~/ 2, end: ends[i] ~/ 2));
        }
      }
    }

    // Get vertical walls
    for (var col = 0; col < width; col++) {
      var starts = Iterable.generate(height,
              (row) => isWall(col, row) && !isWall(col, row - 1) ? row : -1)
          .where((index) => index != -1)
          .toList();
      var ends = Iterable.generate(height,
              (row) => isWall(col, row) && !isWall(col, row + 1) ? row : -1)
          .where((index) => index != -1)
          .toList();

      assert(starts.length == ends.length);

      for (var i = 0; i < starts.length; i++) {
        // Don't add isolated walls again
        if (starts[i] != ends[i]) {
          segments.add(Segment.vertical(
              x: col ~/ 2, start: starts[i] ~/ 2, end: ends[i] ~/ 2));
        }
      }
    }

    return segments;
  }

  static PuzzleState parseLevel(List<List<Tile>> map) {
    // The level is defined as a 2w+1 x 2h+1 grid of cells.
    // The even rows/columns represent the walls,
    // and the odd rows/columns represent the cells.

    List<Segment> walls = getSegmentsOfType(map, TileType.wall);
    Segment exit = getSegmentsOfType(map, TileType.exit).first;

    // Vertical walls

    int width = map[0].length;
    int height = map.length;

    var blocks = LevelReader.getBlocks(map);

    var initialBlock = blocks.firstWhere((block) => block.isControlled).block;
    var otherBlocks = blocks
        .where((block) => !block.isControlled)
        .map((b) => b.block)
        .toList();

    return PuzzleState.initial(
      width ~/ 2,
      height ~/ 2,
      initialBlock: initialBlock,
      otherBlocks: otherBlocks,
      innerWalls: walls,
      exit: exit,
    );
  }

  static List<_ParsedBlock> getBlocks(List<List<int>> map) {
    List<_ParsedBlock> blocks = [];

    List<Position> blockTopLefts = [];
    List<Position> blockBottomRights = [];

    int width = map[0].length;
    int height = map.length;

    bool isBlock(int x, int y) {
      if (x >= 0 && x < width && y >= 0 && y < height) {
        return isTileType(map[y][x], TileType.block);
      } else {
        return false;
      }
    }

    for (var row = 0; row < height; row++) {
      for (var col = 0; col < width; col++) {
        var isAboveBlock = isBlock(col, row - 1);
        var isLeftBlock = isBlock(col - 1, row);
        var isCurrentBlock = isBlock(col, row);

        if (isCurrentBlock && !isAboveBlock && !isLeftBlock) {
          blockTopLefts.add(Position(col, row));
        }

        // if (isCurrentBlock && !isBelowBlock && !isRightBlock) {
        //   blockBottomRights.add(Position(col, row));
        // }
      }
    }

    for (var blockTopLeft in blockTopLefts) {
      // Go as right as possible
      var right = blockTopLeft.x;
      var bottom = blockTopLeft.y;
      while (isBlock(right + 1, bottom)) {
        right++;
      }

      while (isBlock(right, bottom + 1)) {
        bottom++;
      }
      blockBottomRights.add(Position(right, bottom));
    }

    assert(blockTopLefts.length == blockBottomRights.length);

    for (var i = 0; i < blockTopLefts.length; i++) {
      var position = blockTopLefts[i];
      var actualPosition = Position(position.x ~/ 2, position.y ~/ 2);
      var isMain = isTileType(map[position.y][position.x], TileType.main);
      var isControlled =
          isTileType(map[position.y][position.x], TileType.control);
      var blockWidth = blockBottomRights[i].x - position.x + 1;
      var blockHeight = blockBottomRights[i].y - position.y + 1;

      blocks.add(
        _ParsedBlock(
            block: PlacedBlock(
              blockWidth ~/ 2 + 1,
              blockHeight ~/ 2 + 1,
              actualPosition,
              isMain: isMain,
              canMoveHorizontally: true,
              canMoveVertically: true,
            ),
            isControlled: isControlled),
      );
    }

    return blocks;
  }

  //   for (var col = 0; col < width; col++) {
  //     var cell = rawMap[row][col];
  //     if (cell == TileType.wall) {
  //       if (wallStart == -1) {
  //         wallStart = col;
  //       }
  //     } else if (wallStart != null) {
  //       walls.add(Segment.vertical(
  //         x: row,
  //         start: wallStart,
  //         end: col - 1,
  //       ));
  //       wallStart = null;
  //     }
  //   }
  //   if (wallStart != null) {
  //     walls.add(Segment.vertical(
  //       x: row,
  //       start: wallStart,
  //       end: width - 1,
  //     ));
  //   }
  // }
  // }
}

class _ParsedBlock {
  const _ParsedBlock({required this.block, required this.isControlled});

  final PlacedBlock block;
  final bool isControlled;
}
