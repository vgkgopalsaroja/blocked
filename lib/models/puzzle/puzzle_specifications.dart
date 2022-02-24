import 'package:blocked/models/models.dart';

class PuzzleSpecifications {
  const PuzzleSpecifications({
    required this.width,
    required this.height,
    required this.otherBlocks,
    required this.initialBlock,
    required this.walls,
  });

  final int width;
  final int height;
  final List<PlacedBlock> otherBlocks;
  final PlacedBlock? initialBlock;
  final List<Segment> walls;
}
