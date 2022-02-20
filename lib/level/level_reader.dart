import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:slide/models/models.dart';
import 'package:slide/puzzle/puzzle.dart';
import 'package:yaml/yaml.dart';

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
  '********e',
  '*MMM.x..e',
  '*..*..*.e',
  '*xxx.xxx*',
  '*..*....*',
  '*..x.x..*',
  '*********',
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
      initialState: LevelReader.parseLevel(map),
    );
  }
}

extension on int {
  int segmentToTileCount() {
    return 1 + this * 2;
  }

  int toTileCount() {
    return 1 + (this - 1) * 2;
  }
}

class LevelReader {
  static Future<List<LevelData>> readLevels() async {
    final levels = <LevelData>[];
    final data = await rootBundle.loadString('assets/levels.yaml');
    final mapData = loadYaml(data);
    for (YamlMap levelData in mapData) {
      final name = levelData['name']!.toString();
      final String? hint = levelData['hint'];
      final map = levelData['map']!.toString();
      levels.add(LevelData(
        name: name.toString(),
        hint: hint?.toString(),
        map: map,
      ));
    }
    return levels;
  }

  static String stateToMapString(LevelState state) {
    return toMapString(
        width: state.width,
        height: state.height,
        walls: state.walls,
        blocks: state.blocks,
        initialBlock: state.controlledBlock);
  }

  static String specsToMapString(PuzzleSpecifications state) {
    return toMapString(
        width: state.width,
        height: state.height,
        walls: state.walls,
        blocks: [
          ...state.otherBlocks,
          if (state.initialBlock != null) state.initialBlock!,
        ],
        initialBlock: state.initialBlock);
  }

  static String toMapString({
    required int width,
    required int height,
    required Iterable<Segment> walls,
    required Iterable<PlacedBlock> blocks,
    required PlacedBlock? initialBlock,
  }) {
    final map = List<List<String>>.generate(height.toTileCount() + 2, (y) {
      return List.generate(width.toTileCount() + 2, (x) {
        if (x == 0 ||
            x == width.toTileCount() + 1 ||
            y == 0 ||
            y == height.toTileCount() + 1) {
          return 'e';
        }
        return '.';
      });
    });

    for (final wall in walls) {
      final wallTileWidth = wall.width.segmentToTileCount();
      final wallTileHeight = wall.height.segmentToTileCount();
      for (var dx = 0; dx < wallTileWidth; dx++) {
        for (var dy = 0; dy < wallTileHeight; dy++) {
          map[wall.start.y * 2 + dy][wall.start.x * 2 + dx] = '*';
        }
      }
    }

    for (final block in blocks) {
      final blockTileWidth = block.width.toTileCount();
      final blockTileHeight = block.height.toTileCount();
      var blockChar = block.isMain ? 'm' : 'x';
      if (block == initialBlock) {
        blockChar = blockChar.toUpperCase();
      }

      for (var dx = 0; dx < blockTileWidth; dx++) {
        for (var dy = 0; dy < blockTileHeight; dy++) {
          map[block.top * 2 + 1 + dy][block.left * 2 + 1 + dx] = blockChar;
        }
      }
    }

    return map.map((row) {
      return row.join();
    }).join('\n');
  }

  static LevelState parseLevel(String mapString) {
    return LevelReader._parseLevelFromTiles(
        LevelReader._parseTilesFromMap(mapString.split('\n')));
  }

  static PuzzleSpecifications parsePuzzleSpecs(String mapString) {
    return LevelReader._parsePuzzleFromTiles(
        LevelReader._parseTilesFromMap(mapString.split('\n')));
  }

  static List<List<Tile>> _parseTilesFromMap(Iterable<String> rawMap) {
    return rawMap.map((line) {
      return line.split('').map((char) {
        if (char == wall) {
          return TileType.wall;
        } else if (char == empty) {
          return TileType.empty;
        } else if (char == exit) {
          return TileType.exit;
        } else {
          var baseBlock = char.toLowerCase() == block
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
    final segments = <Segment>[];
    final width = map[0].length;
    final height = map.length;

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
      final starts = Iterable.generate(width,
              (col) => isWall(col, row) && !isWall(col - 1, row) ? col : -1)
          .where((index) => index != -1)
          .toList();
      final ends = Iterable.generate(width,
              (col) => isWall(col, row) && !isWall(col + 1, row) ? col : -1)
          .where((index) => index != -1)
          .toList();

      assert(starts.length == ends.length);

      for (var i = 0; i < starts.length; i++) {
        // Only add isolated walls
        if (starts[i] == ends[i]) {
          final x = starts[i];
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
      final starts = Iterable.generate(height,
              (row) => isWall(col, row) && !isWall(col, row - 1) ? row : -1)
          .where((index) => index != -1)
          .toList();
      final ends = Iterable.generate(height,
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

  static PuzzleSpecifications _parsePuzzleFromTiles(List<List<Tile>> map) {
    final width = map[0].length;
    final height = map.length;

    assert(width % 2 == 1 && height % 2 == 1, 'Map must be odd-sized');

    final walls = getSegmentsOfType(map, TileType.wall);
    final parsedBlocks = LevelReader.getBlocks(map);
    final blocks = parsedBlocks
        .where((block) => !block.isControlled)
        .map((block) => block.block)
        .toList();
    final controlledBlock =
        parsedBlocks.where((block) => block.isControlled).firstOrNull?.block;

    return PuzzleSpecifications(
      width: width ~/ 2,
      height: height ~/ 2,
      walls: walls,
      otherBlocks: blocks,
      initialBlock: controlledBlock,
    );
  }

  static LevelState _parseLevelFromTiles(List<List<Tile>> map) {
    final spec = _parsePuzzleFromTiles(map);

    assert(spec.initialBlock != null);
    return LevelState.initial(PuzzleState.initial(spec.width, spec.height,
        initialBlock: spec.initialBlock!,
        otherBlocks: spec.otherBlocks,
        walls: spec.walls));
  }

  static List<_ParsedBlock> getBlocks(List<List<int>> map) {
    final blocks = <_ParsedBlock>[];

    final blockTopLefts = <Position>[];
    final blockBottomRights = <Position>[];

    final width = map[0].length;
    final height = map.length;

    bool isBlock(int x, int y) {
      if (x >= 0 && x < width && y >= 0 && y < height) {
        return isTileType(map[y][x], TileType.block);
      } else {
        return false;
      }
    }

    for (var row = 0; row < height; row++) {
      for (var col = 0; col < width; col++) {
        final isAboveBlock = isBlock(col, row - 1);
        final isLeftBlock = isBlock(col - 1, row);
        final isCurrentBlock = isBlock(col, row);

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
      final position = blockTopLefts[i];
      final actualPosition = Position(position.x ~/ 2, position.y ~/ 2);
      final isMain = isTileType(map[position.y][position.x], TileType.main);
      final isControlled =
          isTileType(map[position.y][position.x], TileType.control);
      final blockWidth = blockBottomRights[i].x - position.x + 1;
      final blockHeight = blockBottomRights[i].y - position.y + 1;

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
