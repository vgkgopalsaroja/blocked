class AppRoutePath {
  const AppRoutePath.levelSelection()
      : levelId = null,
        location = '/levels';
  const AppRoutePath.level({required String id})
      : levelId = id,
        location = '/levels/$id';
  const AppRoutePath.editor()
      : location = '/editor',
        levelId = null;

  final String location;
  final String? levelId;

  bool get isEditor => location == '/editor';
  bool get isLevel => levelId != null;
}
