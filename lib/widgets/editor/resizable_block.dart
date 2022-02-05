import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/editor/bloc/level_editor_bloc.dart';
import 'package:slide/puzzle/model/block.dart';
import 'package:slide/widgets/editor/animated_selectable.dart';
import 'package:slide/widgets/puzzle/block.dart';
import 'package:slide/widgets/puzzle/board_constants.dart';
import 'package:slide/widgets/resizable/resizable.dart';

class ResizableBlock extends StatelessWidget {
  const ResizableBlock(this.block, {Key? key}) : super(key: key);

  final EditorBlock block;

  @override
  Widget build(BuildContext context) {
    final isSelected = context.select(
      (LevelEditorBloc bloc) => bloc.state.selectedObject == block,
    );

    return Resizable(
      enabled: isSelected,
      minHeight: kBlockSize,
      minWidth: kBlockSize,
      baseHeight: kBlockSize,
      baseWidth: kBlockSize,
      initialOffset: block.offset,
      initialSize: block.size,
      snapHeightInterval: kBlockSizeInterval,
      snapWidthInterval: kBlockSizeInterval,
      snapWhileMoving: true,
      snapWhileResizing: true,
      snapOffsetInterval: const Offset(
        kBlockSize + kBlockToBlockGap,
        kBlockSize + kBlockToBlockGap,
      ),
      snapBaseOffset: const Offset(
        kWallWidth + kBlockGap,
        kWallWidth + kBlockGap,
      ),
      onTap: () {
        context.read<LevelEditorBloc>().add(EditorObjectSelected(block));
      },
      onUpdate: (state) {
        final newSize = state.size;
        final newOffset = state.offset;
        if (block.offset != newOffset || block.size != newSize) {
          context.read<LevelEditorBloc>().add(
                EditorObjectMoved(
                  block,
                  state.size,
                  state.offset,
                ),
              );
        }
      },
      builder: (context, size) {
        final blockSize = size / kBlockSize;
        return AnimatedSelectable(
          isSelected: isSelected,
          child: PuzzleBlock(
            Block.manual(
              blockSize.width.round(),
              blockSize.height.round(),
              isMain: block.isMain,
              canMoveHorizontally: true,
              canMoveVertically: true,
            ),
            isControlled: block.hasControl,
          ),
        );
      },
    );
  }
}
