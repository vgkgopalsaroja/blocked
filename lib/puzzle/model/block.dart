import 'dart:math';

import 'package:equatable/equatable.dart';

import 'position.dart';

part 'placed_block.dart';

class Block with EquatableMixin {
  const Block(this.width, this.height)
      : isMain = false,
        canMoveHorizontally = true,
        canMoveVertically = true;
  const Block.main(this.width, this.height)
      : isMain = true,
        canMoveHorizontally = true,
        canMoveVertically = true;
  const Block.fixed(this.width, this.height)
      : isMain = false,
        canMoveHorizontally = false,
        canMoveVertically = false;
  const Block.vertical(this.width, this.height)
      : isMain = false,
        canMoveHorizontally = false,
        canMoveVertically = true;
  const Block.horizontal(this.width, this.height)
      : isMain = false,
        canMoveHorizontally = true,
        canMoveVertically = false;

  const Block.manual(
    this.width,
    this.height, {
    required this.isMain,
    required this.canMoveHorizontally,
    required this.canMoveVertically,
  });

  final int width;
  final int height;
  final bool isMain;
  final bool canMoveHorizontally;
  final bool canMoveVertically;

  bool get isFixed => !canMoveHorizontally && !canMoveVertically;

  @override
  List<Object?> get props => [
        width,
        height,
        isMain,
        canMoveHorizontally,
        canMoveVertically,
      ];
}
