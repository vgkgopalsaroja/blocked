part of 'level_editor_bloc.dart';

class LevelEditorState {
  LevelEditorState.fromPuzzleSpecifications(PuzzleSpecifications specs)
      : this.initial([
          if (specs.initialBlock != null)
            EditorBlock.initial(specs.initialBlock!, hasControl: true),
          ...specs.otherBlocks.map((block) => EditorBlock.initial(block)),
          ..._withoutOuterWalls(specs.width, specs.height, specs.walls)
              .map((wall) => EditorSegment.initial(wall)),
          EditorFloor.initial(specs.width, specs.height),
        ]);
  const LevelEditorState.initial(this.objects)
      : selectedObject = null,
        generatedPuzzle = null,
        puzzleError = null,
        selectedTool = EditorTool.move,
        isGridVisible = true;
  const LevelEditorState(
    this.objects, {
    required this.selectedObject,
    required this.generatedPuzzle,
    required this.puzzleError,
    required this.selectedTool,
    required this.isGridVisible,
  });

  static const EditorObject _invalidObject = _InvalidEditorObject();
  static const PuzzleState _invalidPuzzleState = _InvalidPuzzleState();
  static const String _invalidPuzzleError = 'Valid';

  final List<EditorObject> objects;
  final EditorObject? selectedObject;
  final PuzzleState? generatedPuzzle;
  final String? puzzleError;
  final EditorTool selectedTool;
  final bool isGridVisible;

  bool get isTesting => generatedPuzzle != null;

  EditorFloor get floor => objects.whereType<EditorFloor>().first;

  Iterable<EditorSegment> get segments => objects.whereType<EditorSegment>();

  Iterable<EditorBlock> get blocks => objects.whereType<EditorBlock>();

  Iterable<EditorSegment> get exits =>
      segments.where((segment) => isExit(segment));

  static bool hasBlockIntersection(
      int width, int height, Iterable<PlacedBlock> blocks) {
    final visited = List.generate(height, (i) => List.filled(width, false));
    for (var block in blocks) {
      for (var y = block.top; y <= block.bottom; y++) {
        for (var x = block.left; x <= block.right; x++) {
          if (visited[y][x]) return true;
          visited[y][x] = true;
        }
      }
    }
    return false;
  }

  String? getMapString() {
    bool segmentFits(Segment segment) {
      return segment.start.x >= 0 &&
          segment.start.x <= floor.width &&
          segment.start.y >= 0 &&
          segment.start.y <= floor.height &&
          segment.end.x >= 0 &&
          segment.end.x <= floor.width &&
          segment.end.y >= 0 &&
          segment.end.y <= floor.height;
    }

    bool blockFits(PlacedBlock block) {
      return block.left >= 0 &&
          block.right < floor.width &&
          block.top >= 0 &&
          block.bottom < floor.height;
    }

    final blocks = getGeneratedBlocks().where((block) => blockFits(block));
    final walls = getGeneratedWalls().where((wall) => segmentFits(wall));

    if (hasBlockIntersection(floor.width, floor.height, blocks)) {
      return null;
    }

    String mapString = LevelReader.toMapString(
      width: floor.width,
      height: floor.height,
      walls: walls,
      blocks: blocks,
      initialBlock: blocks.where((block) => block.isMain).firstOrNull,
    );

    return mapString;
  }

  EditorBlock? get mainBlock => objects
      .whereType<EditorBlock>()
      .where((block) => block.isMain)
      .firstOrNull;

  EditorBlock? get initialBlock => objects
      .whereType<EditorBlock>()
      .where((block) => block.hasControl)
      .firstOrNull;

  bool isExit(EditorSegment segment) {
    int dx = -floor.left;
    int dy = -floor.top;
    Segment translatedSegment = segment.toSegment().translate(dx, dy);
    return _isSegmentOuterWall(floor.width, floor.height, translatedSegment);
  }

  static bool _isSegmentOuterWall(int width, int height, Segment segment) {
    if (segment.isVertical) {
      bool isXValid = segment.start.x == 0 || segment.start.x == width;
      bool isYValid = segment.start.y >= 0 && segment.end.y <= height;
      return isXValid && isYValid;
    } else {
      bool isXValid = segment.start.x >= 0 && segment.end.x <= width;
      bool isYValid = segment.start.y == 0 || segment.start.y == height;
      return isXValid && isYValid;
    }
  }

  static List<Segment> _withoutOuterWalls(
      int width, int height, Iterable<Segment> segments) {
    final outerWalls =
        segments.where((s) => _isSegmentOuterWall(width, height, s));

    final exits = _generateOuterWallsWithout(width, height, outerWalls);

    final innerWalls =
        segments.whereNot((s) => outerWalls.contains(s)).toList();
    return innerWalls + exits;
  }

  LevelEditorState copyWith({
    List<EditorObject>? objects,
    EditorObject? selectedObject = _invalidObject,
    PuzzleState? generatedPuzzle = _invalidPuzzleState,
    String? puzzleError = _invalidPuzzleError,
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
      puzzleError:
          puzzleError != _invalidPuzzleError ? puzzleError : this.puzzleError,
      selectedTool: selectedTool ?? this.selectedTool,
      isGridVisible: isGridVisible ?? this.isGridVisible,
    );
  }

  LevelEditorState withGeneratedPuzzle() {
    try {
      return copyWith(
          generatedPuzzle: _generatePuzzleFromEditorObjects(),
          puzzleError: null);
    } on EditorException catch (e) {
      return copyWith(puzzleError: e.message);
    }
  }

  LevelEditorState withoutGeneratedPuzzle() {
    return copyWith(generatedPuzzle: null, puzzleError: null);
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

  List<PlacedBlock> getGeneratedBlocks() {
    final dx = -floor.left;
    final dy = -floor.top;
    return blocks.map((block) => block.toBlock().translate(dx, dy)).toList();
  }

  List<Segment> getGeneratedWalls() {
    final dx = -floor.left;
    final dy = -floor.top;

    final exitSegments = exits.map((e) => e.toSegment().translate(dx, dy));

    final outerWalls =
        _generateOuterWallsWithout(floor.width, floor.height, exitSegments);

    final innerWalls = segments
        .whereNot((segment) => isExit(segment))
        .map((w) => w.toSegment().translate(dx, dy))
        .toList();

    return outerWalls + innerWalls;
  }

  static List<Segment> _generateOuterWallsWithout(
      int mapWidth, int mapHeight, Iterable<Segment> wallsToSubtract) {
    var outerWalls = [
      Segment.horizontal(y: 0, start: 0, end: mapWidth),
      Segment.horizontal(y: mapHeight, start: 0, end: mapWidth),
      Segment.vertical(x: 0, start: 0, end: mapHeight),
      Segment.vertical(x: mapWidth, start: 0, end: mapHeight),
    ];

    return outerWalls
        .map((wall) => wall.subtractAll(wallsToSubtract))
        .flattened
        .toList();
  }

  PuzzleState _generatePuzzleFromEditorObjects() {
    final initialBlock = this.initialBlock;
    if (initialBlock == null) {
      throw const EditorException('No initial block found');
    } else if (mainBlock == null) {
      throw const EditorException('No main block found');
    } else if (exits.isEmpty) {
      throw const EditorException('Puzzle has no exits');
    }

    final otherBlocks = blocks.where((block) => block != initialBlock);

    final dx = -floor.left;
    final dy = -floor.top;

    PuzzleState state = PuzzleState.initial(
      floor.width,
      floor.height,
      initialBlock: initialBlock.toBlock().translate(dx, dy),
      otherBlocks:
          otherBlocks.map((e) => e.toBlock().translate(dx, dy)).toList(),
      walls: getGeneratedWalls(),
    );
    return state;
  }
}