import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/puzzle/bloc/puzzle_bloc.dart';
import 'package:slide/puzzle/model/block.dart';
import 'package:slide/puzzle/model/segment.dart';
import 'package:slide/widgets/puzzle/board_constants.dart';
import 'package:collection/collection.dart';

class LevelEditorBloc extends Bloc<LevelEditorEvent, LevelEditorState> {
  LevelEditorBloc() : super(LevelEditorState.initial([EditorFloor.initial()])) {
    on<EditorObjectMoved>(_onEditorObjectMoved);
    on<EditorObjectSelected>(_onEditorObjectSelected);
    on<BlockAdded>(_onBlockAdded);
    on<SegmentAdded>(_onSegmentAdded);
    on<TestMapPressed>(_onTestMapPressed);
    on<MainEditorBlockSet>(_onMainEditorBlockSet);
    on<ControlledEditorBlockSet>(_onControlledEditorBlockSet);
    on<TestMapExited>(_onTestMapExited);
    on<WallBuilderOpened>(_onWallBuilderOpened);
    on<WallBuilderClosed>(_onWallBuilderClosed);
  }

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
    emit(state.withGeneratedPuzzle());
  }

  void _onTestMapExited(TestMapExited event, Emitter<LevelEditorState> emit) {
    emit(state.withoutGeneratedPuzzle());
  }

  void _onBlockAdded(BlockAdded event, Emitter<LevelEditorState> emit) {
    final newBlock = EditorBlock.small();
    emit(state.copyWith(
      objects: state.objects + [newBlock],
      generatedPuzzle: null,
    ));
  }

  void _onSegmentAdded(SegmentAdded event, Emitter<LevelEditorState> emit) {
    EditorSegment newSegment;
    if (event.isVertical) {
      newSegment = EditorSegment.vertical(event.segment);
    } else {
      newSegment = EditorSegment.horizontal(event.segment);
    }
    emit(state.copyWith(
      objects: state.objects + [newSegment],
      selectedObject: state.selectedObject,
      generatedPuzzle: null,
    ));
  }

  void _onMainEditorBlockSet(
      MainEditorBlockSet event, Emitter<LevelEditorState> emit) {
    emit(state.withMainBlock(event.block));
  }

  void _onControlledEditorBlockSet(
      ControlledEditorBlockSet event, Emitter<LevelEditorState> emit) {
    emit(state.withControlBlock(event.block));
  }

  void _onWallBuilderOpened(
      WallBuilderOpened event, Emitter<LevelEditorState> emit) {
    emit(state.copyWith(isWallBuilderOpen: true));
  }

  void _onWallBuilderClosed(
      WallBuilderClosed event, Emitter<LevelEditorState> emit) {
    emit(state.copyWith(isWallBuilderOpen: false));
  }
}

abstract class LevelEditorEvent {
  const LevelEditorEvent();
}

class EditorObjectMoved extends LevelEditorEvent {
  const EditorObjectMoved(this.object, this.size, this.offset);

  final EditorObject object;
  final Size size;
  final Offset offset;
}

class EditorObjectSelected extends LevelEditorEvent {
  const EditorObjectSelected(this.object);

  final EditorObject? object;
}

class MainEditorBlockSet extends LevelEditorEvent {
  const MainEditorBlockSet(this.block);

  final EditorBlock block;
}

class ControlledEditorBlockSet extends LevelEditorEvent {
  const ControlledEditorBlockSet(this.block);

  final EditorBlock block;
}

class BlockAdded extends LevelEditorEvent {
  const BlockAdded();
}

class SegmentAdded extends LevelEditorEvent {
  const SegmentAdded(this.segment, {required this.isVertical});

  final Segment segment;
  final bool isVertical;
}

class TestMapPressed extends LevelEditorEvent {
  const TestMapPressed();
}

class TestMapExited extends LevelEditorEvent {
  const TestMapExited();
}

class WallBuilderOpened extends LevelEditorEvent {
  const WallBuilderOpened();
}

class WallBuilderClosed extends LevelEditorEvent {
  const WallBuilderClosed();
}

class LevelEditorState {
  const LevelEditorState.initial(this.objects)
      : selectedObject = null,
        generatedPuzzle = null,
        isWallBuilderOpen = false;
  const LevelEditorState(
    this.objects, {
    required this.selectedObject,
    required this.generatedPuzzle,
    required this.isWallBuilderOpen,
  });

  final List<EditorObject> objects;
  final EditorObject? selectedObject;
  final PuzzleState? generatedPuzzle;
  final bool isWallBuilderOpen;

  EditorFloor get floor =>
      objects.firstWhere((object) => object is EditorFloor) as EditorFloor;
  bool get isTesting => generatedPuzzle != null;

  EditorBlock? get mainBlock => objects.firstWhereOrNull(
      (object) => object is EditorBlock && object.isMain) as EditorBlock?;

  EditorBlock? get initialBlock => objects.firstWhereOrNull(
      (object) => object is EditorBlock && object.hasControl) as EditorBlock?;

  LevelEditorState copyWith({
    List<EditorObject>? objects,
    EditorObject? selectedObject,
    PuzzleState? generatedPuzzle,
    bool? isWallBuilderOpen,
  }) {
    return LevelEditorState(
      objects ?? this.objects,
      selectedObject: selectedObject ?? this.selectedObject,
      generatedPuzzle: generatedPuzzle ?? this.generatedPuzzle,
      isWallBuilderOpen: isWallBuilderOpen ?? this.isWallBuilderOpen,
    );
  }

  LevelEditorState withGeneratedPuzzle() {
    return copyWith(generatedPuzzle: _generatePuzzleFromEditorObjects());
  }

  LevelEditorState withoutGeneratedPuzzle() {
    return copyWith(generatedPuzzle: null);
  }

  LevelEditorState withSelectedObject(EditorObject? object) {
    return LevelEditorState(objects,
        selectedObject: object,
        generatedPuzzle: generatedPuzzle,
        isWallBuilderOpen: isWallBuilderOpen);
  }

  LevelEditorState withUpdatedObjectPosition(
      EditorObject object, Size size, Offset offset) {
    assert(objects.contains(object),
        'Editor object is not in list of known editor objects');

    return withUpdatedObject(
        object, object.copyWith(size: size, offset: offset));
  }

  LevelEditorState withUpdatedObject(
      EditorObject object, EditorObject newObject) {
    final wasSelected = selectedObject == object;
    assert(objects.contains(object),
        'Editor object is not in list of known editor objects');
    assert(object.key == newObject.key,
        'New editor object does not have the same key as the old object');

    final newObjects = [
      ...objects,
    ];

    newObjects[newObjects.indexOf(object)] = newObject;
    // newObjects.remove(object);
    // newObjects.add(newObject);

    return copyWith(
        objects: newObjects,
        selectedObject: wasSelected ? newObject : selectedObject,
        generatedPuzzle: null);
  }

  LevelEditorState withMainBlock(EditorBlock block) {
    assert(objects.contains(block),
        'Editor block is not in list of known editor objects');

    // Set main to false for current main block
    final state = mainBlock != null
        ? withUpdatedObject(mainBlock!, mainBlock!.copyWith(isMain: false))
        : this;

    // Set main to true
    final newBlock = block.copyWith(
      isMain: true,
    );
    return state.withUpdatedObject(block, newBlock);
  }

  LevelEditorState withControlBlock(EditorBlock block) {
    assert(objects.contains(block),
        'Editor block is not in list of known editor objects');

    // Set control to false for current initial block
    final state = initialBlock != null
        ? withUpdatedObject(
            initialBlock!, initialBlock!.copyWith(hasControl: false))
        : this;

    // Set control to true
    final newBlock = block.copyWith(
      hasControl: true,
    );
    return state.withUpdatedObject(block, newBlock);
  }

  PuzzleState _generatePuzzleFromEditorObjects() {
    final initialBlock = this.initialBlock;
    assert(initialBlock != null, 'No initial block set');
    final otherBlocks = objects.where((EditorObject object) =>
        object is EditorBlock && object != initialBlock);

    return PuzzleState.initial(floor.width, floor.height,
        initialBlock: initialBlock!.toBlock(),
        otherBlocks:
            otherBlocks.map((e) => (e as EditorBlock).toBlock()).toList(),
        innerWalls: [],
        exit: Segment.point(x: 1, y: 1));
  }
}

abstract class EditorObject extends Equatable {
  const EditorObject(this.key, this.size, this.offset);

  final UniqueKey key;
  final Size size;
  final Offset offset;

  int get width;
  int get height;

  EditorObject copyWith({Size? size, Offset? offset});

  @override
  List<Object?> get props => [key];
}

class EditorBlock extends EditorObject {
  EditorBlock.small({UniqueKey? key})
      : isMain = false,
        hasControl = false,
        super(key ?? UniqueKey(), const Size(1, 1), Offset.zero);
  EditorBlock(Size size, Offset offset,
      {UniqueKey? key, this.isMain = false, this.hasControl = false})
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
  EditorSegment(
    Size size,
    Offset offset,
    this.segment,
    this._isVertical, {
    required UniqueKey key,
  }) : super(key, size, offset);
  EditorSegment._initial(this.segment, this._isVertical)
      : super(
            UniqueKey(),
            Size(segment.width.toWallSize(), segment.height.toWallSize()),
            Offset(segment.start.x.toWallOffset(),
                segment.start.y.toWallOffset()));
  EditorSegment.vertical(Segment segment) : this._initial(segment, true);
  EditorSegment.horizontal(Segment segment) : this._initial(segment, false);

  @override
  int get width => segment.width;

  @override
  int get height => segment.height;

  bool get isVertical => _isVertical;
  bool get isHorizontal => !_isVertical;

  final Segment segment;
  final bool _isVertical;

  @override
  EditorObject copyWith({Size? size, Offset? offset}) {
    return EditorSegment(
        size ?? this.size, offset ?? this.offset, segment, _isVertical,
        key: key);
  }
}

class EditorFloor extends EditorObject {
  EditorFloor.initial()
      : super(UniqueKey(), Size(1.toBoardSize(), 1.toBoardSize()), Offset.zero);

  EditorFloor(Size size, Offset offset, {UniqueKey? key})
      : super(key ?? UniqueKey(), size, offset);

  @override
  int get width => size.width.boardSizeToBlockCount();
  @override
  int get height => size.height.boardSizeToBlockCount();

  @override
  EditorFloor copyWith({Size? size, Offset? offset}) {
    return EditorFloor(size ?? this.size, offset ?? this.offset, key: key);
  }
}
