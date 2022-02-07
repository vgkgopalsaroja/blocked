import 'dart:convert';

import 'package:archive/archive.dart';

class AppRoutePath {
  const AppRoutePath(this.location);

  final String location;
}

class LevelRoutePath extends AppRoutePath {
  const LevelRoutePath.levelSelection()
      : levelId = null,
        super('/levels');
  const LevelRoutePath.level({required String id})
      : levelId = id,
        super('/levels/$id');

  final String? levelId;
}

class EditorRoutePath extends AppRoutePath {
  EditorRoutePath.editor(this.mapString)
      : isInPreview = false,
        super('/editor/${encodeMapString(mapString)}');
  EditorRoutePath.generatedLevel(this.mapString)
      : isInPreview = true,
        super('/editor/generated/${encodeMapString(mapString)}');

  final bool isInPreview;
  final String mapString;
}

String encodeMapString(String mapString) {
  var result = GZipEncoder().encode(utf8.encode(mapString))!;
  return Uri.encodeComponent(base64.encode(result));
}

String decodeMapString(String mapString) {
  var result = base64.decode(Uri.decodeComponent(mapString));
  return utf8.decode(GZipDecoder().decodeBytes(result, verify: true));
}
