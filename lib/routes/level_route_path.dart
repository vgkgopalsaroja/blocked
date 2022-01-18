class LevelRoutePath {
  // const LevelRoutePath.home() : path = '/';
  const LevelRoutePath.levelSelection()
      : levelId = null,
        location = '/levels';
  const LevelRoutePath.level({required String id})
      : levelId = id,
        location = '/levels/$id';

  final String location;
  final String? levelId;
}
