import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/puzzle/bloc/puzzle_bloc.dart';
import 'package:slide/puzzle/model/block.dart';
import 'package:slide/puzzle/model/position.dart';
import 'package:slide/puzzle/model/segment.dart';
import 'package:slide/widgets/puzzle/board_constants.dart';
import 'package:collection/collection.dart';

part 'level_editor_event.dart';

enum EditorTool {
  block,
  segment,
  move,
}

class LevelEditorBloc extends Bloc<LevelEditorEvent, LevelEditorState> {
  LevelEditorBloc() : super(LevelEditorState.initial([EditorFloor.initial()])) {
    on<EditorObjectMoved>(_onEditorObjectMoved);
    on<EditorObjectSelected>(_onEditorObjectSelected);
    on<SelectedEditorObjectDeleted>(_onSelectedEditorObjectDeleted);
    on<BlockAdded>(_onBlockAdded);
    on<SegmentAdded>(_onSegmentAdded);
    on<TestMapPressed>(_onTestMapPressed);
    on<MainEditorBlockSet>(_onMainEditorBlockSet);
    on<ControlledEditorBlockSet>(_onControlledEditorBlockSet);
    on<TestMapExited>(_onTestMapExited);
    on<EditorToolSelected>(_onEditorToolSelected);
    on<GridToggled>(_onGridToggled);
    on<MapCleared>(_onMapCleared);
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
    final newBlock = EditorBlock.initial(event.block);
    emit(state.copyWith(
      objects: state.objects + [newBlock],
      generatedPuzzle: null,
    ));
  }

  void _onSegmentAdded(SegmentAdded event, Emitter<LevelEditorState> emit) {
    EditorSegment newSegment = EditorSegment.initial(event.segment);
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

  void _onEditorToolSelected(
      EditorToolSelected event, Emitter<LevelEditorState> emit) {
    emit(state.copyWith(selectedTool: event.tool));
  }

  void _onGridToggled(GridToggled event, Emitter<LevelEditorState> emit) {
    emit(state.copyWith(isGridVisible: !state.isGridVisible));
  }

  void _onMapCleared(MapCleared event, Emitter<LevelEditorState> emit) {
    emit(state.copyWith(
      objects: [EditorFloor.initial()],
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
          exit: const Segment(
            Position(0, 0),
            Position(0, 0),
          ),
          controlledBlock: const PlacedBlock(0, 0, Position(0, 0),
              isMain: false,
              canMoveHorizontally: false,
              canMoveVertically: false),
          latestMove: null,
          isCompleted: false,
        );
}

class LevelEditorState {
  const LevelEditorState.initial(this.objects)
      : selectedObject = null,
        generatedPuzzle = null,
        selectedTool = EditorTool.move,
        isGridVisible = true;
  const LevelEditorState(
    this.objects, {
    required this.selectedObject,
    required this.generatedPuzzle,
    required this.selectedTool,
    required this.isGridVisible,
  });

  static const EditorObject _invalidObject = _InvalidEditorObject();
  static const PuzzleState _invalidPuzzleState = _InvalidPuzzleState();

  final List<EditorObject> objects;
  final EditorObject? selectedObject;
  final PuzzleState? generatedPuzzle;
  final EditorTool selectedTool;
  final bool isGridVisible;

  bool get isTesting => generatedPuzzle != null;

  EditorFloor get floor => objects.whereType<EditorFloor>().first;

  Iterable<EditorSegment> getExits() =>
      objects.whereType<EditorSegment>().where((segment) => isExit(segment));

  EditorBlock? get mainBlock => objects
      .whereType<EditorBlock>()
      .where((block) => block.isMain)
      .firstOrNull;

  EditorBlock? get initialBlock => objects
      .whereType<EditorBlock>()
      .where((block) => block.hasControl)
      .firstOrNull;

  bool isExit(EditorSegment segment) {
    int dx = -floor.offset.dx.wallOffsetToBlockCount();
    int dy = -floor.offset.dy.wallOffsetToBlockCount();
    Segment translatedSegment = segment.toSegment().translate(dx, dy);
    if (translatedSegment.isVertical) {
      bool isXValid = translatedSegment.start.x == 0 ||
          translatedSegment.start.x == floor.width;
      bool isYValid = translatedSegment.start.y >= 0 &&
          translatedSegment.end.y <= floor.height;
      return isXValid && isYValid;
    } else {
      bool isXValid = translatedSegment.start.x >= 0 &&
          translatedSegment.end.x <= floor.width;
      bool isYValid = translatedSegment.start.y == 0 ||
          translatedSegment.start.y == floor.height;
      return isXValid && isYValid;
    }
  }

  LevelEditorState copyWith({
    List<EditorObject>? objects,
    EditorObject? selectedObject = _invalidObject,
    PuzzleState? generatedPuzzle = _invalidPuzzleState,
    EditorTool? selectedTool,
    bool? isGridVisible,
  }) {
    return LevelEditorState(
      objects ?? this.objects,
      selectedObject: selectedObject != _invalidObject
          ? selectedObject
          : this.selectedObject,
      generatedPuzzle: generatedPuzzle != _invalidPuzzleState
          ? generatedPuzzle
          : this.generatedPuzzle,
      selectedTool: selectedTool ?? this.selectedTool,
      isGridVisible: isGridVisible ?? this.isGridVisible,
    );
  }

  LevelEditorState withGeneratedPuzzle() {
    return copyWith(generatedPuzzle: _generatePuzzleFromEditorObjects());
  }

  LevelEditorState withoutGeneratedPuzzle() {
    return copyWith(generatedPuzzle: null);
  }

  LevelEditorState withSelectedObject(EditorObject? object) {
    return copyWith(
      selectedObject: object,
    );
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
    final otherBlocks = objects
        .whereType<EditorBlock>()
        .where((block) => block != initialBlock);
    final segments = objects.whereType<EditorSegment>().toList();

    final dx = -floor.left;
    final dy = -floor.top;

    final exitSegment = getExits().firstOrNull?.toSegment().translate(dx, dy);

    final outerWalls = [
      ...Segment.horizontal(y: 0, start: 0, end: floor.width)
          .subtract(exitSegment),
      ...Segment.horizontal(y: floor.height, start: 0, end: floor.width)
          .subtract(exitSegment),
      ...Segment.vertical(x: 0, start: 0, end: floor.height)
          .subtract(exitSegment),
      ...Segment.vertical(x: floor.width, start: 0, end: floor.height)
          .subtract(exitSegment),
    ];

    final innerWalls = segments
        .whereNot((segment) => isExit(segment))
        .map((w) => w.toSegment().translate(dx, dy))
        .toList();

    PuzzleState state = PuzzleState.initial(floor.width, floor.height,
        initialBlock: initialBlock!.toBlock().translate(dx, dy),
        otherBlocks:
            otherBlocks.map((e) => e.toBlock().translate(dx, dy)).toList(),
        walls: innerWalls + outerWalls,
        exit: exitSegment ?? Segment.point(x: 1, y: 1));
    debugPrint(state.toMapString());
    return state;
  }
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
  EditorBlock.initial(PlacedBlock block, {UniqueKey? key})
      : isMain = false,
        hasControl = false,
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
  EditorFloor.initial()
      : super(UniqueKey(), Size(1.toBoardSize(), 1.toBoardSize()), Offset.zero);

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
