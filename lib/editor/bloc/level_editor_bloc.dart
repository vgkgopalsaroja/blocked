import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/editor/editor_exception.dart';
import 'package:slide/puzzle/bloc/puzzle_bloc.dart';
import 'package:slide/puzzle/level_reader.dart';
import 'package:slide/puzzle/model/block.dart';
import 'package:slide/puzzle/model/position.dart';
import 'package:slide/puzzle/model/puzzle_specifications.dart';
import 'package:slide/puzzle/model/segment.dart';
import 'package:slide/routing/navigator_cubit.dart';
import 'package:slide/widgets/puzzle/board_constants.dart';
import 'package:collection/collection.dart';

part 'level_editor_event.dart';
part 'level_editor_state.dart';

enum EditorTool {
  block,
  segment,
  move,
}

class LevelEditorBloc extends Bloc<LevelEditorEvent, LevelEditorState> {
  LevelEditorBloc(this.navigatorCubit, PuzzleSpecifications? puzzleSpecs)
      : super(puzzleSpecs != null
            ? LevelEditorState.fromPuzzleSpecifications(puzzleSpecs)
            : LevelEditorState.initial([EditorFloor.initial(1, 1)])) {
    on<EditorObjectMoved>(_onEditorObjectMoved);
    on<EditorObjectSelected>(_onEditorObjectSelected);
    on<SelectedEditorObjectDeleted>(_onSelectedEditorObjectDeleted);
    on<BlockAdded>(_onBlockAdded);
    on<SegmentAdded>(_onSegmentAdded);
    on<TestMapPressed>(_onTestMapPressed);
    on<MainEditorBlockSet>(_onMainEditorBlockSet);
    on<InitialEditorBlockSet>(_onControlledEditorBlockSet);
    on<TestMapExited>(_onTestMapExited);
    on<EditorToolSelected>(_onEditorToolSelected);
    on<GridToggled>(_onGridToggled);
    on<MapCleared>(_onMapCleared);
    on<SavePressed>(_onSavePressed);
  }

  final NavigatorCubit navigatorCubit;

  void _onEditorObjectMoved(
      EditorObjectMoved event, Emitter<LevelEditorState> emit) {
    emit(state.withUpdatedObjectPosition(
        event.object, event.size, event.offset));
  }

  void _onEditorObjectSelected(
      EditorObjectSelected event, Emitter<LevelEditorState> emit) {
    emit(state.withSelectedObject(event.object));
  }

  void _onTestMapPressed(TestMapPressed event, Emitter<LevelEditorState> emit) {
    final newState = state.withGeneratedPuzzle();
    emit(newState);
    if (newState.generatedPuzzle != null) {
      navigatorCubit
          .navigateToGeneratedLevel(newState.generatedPuzzle!.toMapString());
    }
  }

  void _onSavePressed(SavePressed event, Emitter<LevelEditorState> emit) {
    final mapString = state.getMapString();
    if (mapString != null) {
      navigatorCubit.navigateToEditor(mapString);
      emit(state.copyWith(
        snackbarMessage: const SnackbarMessage.info('Puzzle saved to url'),
      ));
    } else {
      emit(state.copyWith(
        snackbarMessage:
            const SnackbarMessage.error('Cannot save invalid puzzle'),
      ));
    }
  }

  void _onTestMapExited(TestMapExited event, Emitter<LevelEditorState> emit) {
    emit(state.withoutGeneratedPuzzle());
  }

  void _onBlockAdded(BlockAdded event, Emitter<LevelEditorState> emit) {
    final newBlock = EditorBlock.initial(event.block);
    emit(state.copyWith(
      objects: state.objects + [newBlock],
      generatedPuzzle: null,
      selectedTool: EditorTool.move,
    ));
  }

  void _onSegmentAdded(SegmentAdded event, Emitter<LevelEditorState> emit) {
    EditorSegment newSegment = EditorSegment.initial(event.segment);
    emit(state.copyWith(
      objects: state.objects + [newSegment],
      selectedObject: state.selectedObject,
      generatedPuzzle: null,
      selectedTool: EditorTool.move,
    ));
  }

  void _onMainEditorBlockSet(
      MainEditorBlockSet event, Emitter<LevelEditorState> emit) {
    emit(state.withMainBlock(event.block));
  }

  void _onControlledEditorBlockSet(
      InitialEditorBlockSet event, Emitter<LevelEditorState> emit) {
    emit(state.withControlBlock(event.block));
  }

  void _onEditorToolSelected(
      EditorToolSelected event, Emitter<LevelEditorState> emit) {
    emit(state.copyWith(selectedTool: event.tool));
  }

  void _onGridToggled(GridToggled event, Emitter<LevelEditorState> emit) {
    emit(state.copyWith(isGridVisible: !state.isGridVisible));
  }

  void _onMapCleared(MapCleared event, Emitter<LevelEditorState> emit) {
    emit(state.copyWith(
      objects: [state.floor],
      selectedObject: null,
      generatedPuzzle: null,
    ));
  }

  void _onSelectedEditorObjectDeleted(
      SelectedEditorObjectDeleted event, Emitter<LevelEditorState> emit) {
    if (state.selectedObject is! EditorFloor) {
      emit(state.copyWith(
        objects: state.objects
            .where((object) => object != state.selectedObject)
            .toList(),
        selectedObject: null,
        generatedPuzzle: null,
      ));
    }
  }
}

class _InvalidEditorObject extends EditorObject {
  const _InvalidEditorObject() : super(const Key(''), Size.zero, Offset.zero);

  @override
  EditorObject copyWith({Size? size, Offset? offset}) {
    throw UnimplementedError();
  }

  @override
  int get height => throw UnimplementedError();

  @override
  int get width => throw UnimplementedError();
}

class _InvalidPuzzleState extends PuzzleState {
  const _InvalidPuzzleState()
      : super(
          0,
          0,
          walls: const [],
          blocks: const [],
          controlledBlock: const PlacedBlock(0, 0, Position(0, 0),
              isMain: false,
              canMoveHorizontally: false,
              canMoveVertically: false),
          latestMove: null,
          isCompleted: false,
        );
}

abstract class EditorObject extends Equatable {
  const EditorObject(this.key, this.size, this.offset);

  final Key key;
  final Size size;
  final Offset offset;

  int get width;
  int get height;

  EditorObject copyWith({Size? size, Offset? offset});

  @override
  List<Object?> get props => [key];
}

class EditorBlock extends EditorObject {
  EditorBlock.initial(PlacedBlock block,
      {UniqueKey? key, this.hasControl = false})
      : isMain = block.isMain,
        super(
            key ?? UniqueKey(),
            Size(block.width.toBlockSize(), block.height.toBlockSize()),
            Offset(block.left.toBlockOffset(), block.top.toBlockOffset()));
  EditorBlock(Size size, Offset offset,
      {Key? key, this.isMain = false, this.hasControl = false})
      : super(key ?? UniqueKey(), size, offset);

  final bool hasControl;
  final bool isMain;

  @override
  int get width => size.width.blockSizeToBlockCount();
  @override
  int get height => size.height.blockSizeToBlockCount();
  int get top => offset.dy.blockOffsetToBlockCount();
  int get left => offset.dx.blockOffsetToBlockCount();

  PlacedBlock toBlock() => Block.manual(
        width,
        height,
        isMain: isMain,
        canMoveHorizontally: true,
        canMoveVertically: true,
      ).place(left, top);

  @override
  EditorBlock copyWith(
      {Size? size, Offset? offset, bool? isMain, bool? hasControl}) {
    return EditorBlock(
      size ?? this.size,
      offset ?? this.offset,
      isMain: isMain ?? this.isMain,
      hasControl: hasControl ?? this.hasControl,
      key: key,
    );
  }
}

class EditorSegment extends EditorObject {
  const EditorSegment(
    Size size,
    Offset offset, {
    required Key key,
  }) : super(key, size, offset);
  EditorSegment.initial(Segment segment)
      : super(
            UniqueKey(),
            Size(segment.width.toWallSize(), segment.height.toWallSize()),
            Offset(segment.start.x.toWallOffset(),
                segment.start.y.toWallOffset()));

  @override
  int get width => size.width.boardSizeToBlockCount();

  @override
  int get height => size.height.boardSizeToBlockCount();

  int get top => offset.dy.wallOffsetToBlockCount();
  int get left => offset.dx.wallOffsetToBlockCount();

  // bool get isVertical => _isVertical;
  // bool get isHorizontal => !_isVertical;

  // final bool _isVertical;

  Segment toSegment() {
    return Segment.from(
      Position(left, top),
      Position(left + width, top + height),
    );
  }

  @override
  EditorSegment copyWith({Size? size, Offset? offset}) {
    return EditorSegment(size ?? this.size, offset ?? this.offset, key: key);
  }
}

class EditorFloor extends EditorObject {
  EditorFloor.initial(int width, int height)
      : super(UniqueKey(), Size(width.toBoardSize(), height.toBoardSize()),
            Offset.zero);

  EditorFloor(Size size, Offset offset, {Key? key})
      : super(key ?? UniqueKey(), size, offset);

  int get left => offset.dx.wallOffsetToBlockCount();
  int get top => offset.dy.wallOffsetToBlockCount();

  @override
  int get width => size.width.boardSizeToBlockCount();
  @override
  int get height => size.height.boardSizeToBlockCount();

  @override
  EditorFloor copyWith({Size? size, Offset? offset}) {
    return EditorFloor(size ?? this.size, offset ?? this.offset, key: key);
  }
}
