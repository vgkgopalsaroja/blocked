import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:slide/routing/routing.dart';

class AppRouteParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
      RouteInformation routeInformation) {
    return SynchronousFuture(_parseRouteInformationSync(routeInformation));
  }

  AppRoutePath _parseRouteInformationSync(RouteInformation routeInformation) {
    if (routeInformation.location == null) {
      return const LevelRoutePath.chapterSelection();
    }
    final uri = Uri.parse(routeInformation.location!);

    if (uri.pathSegments.isEmpty) {
      return const LevelRoutePath.chapterSelection();
    } else {
      final firstSegment = uri.pathSegments.first;
      if (firstSegment == 'levels') {
        if (uri.pathSegments.length == 1) {
          return const LevelRoutePath.chapterSelection();
        } else if (uri.pathSegments.length == 2) {
          return LevelRoutePath.levelSelection(chapterId: uri.pathSegments[1]);
        } else if (uri.pathSegments.length == 3) {
          return LevelRoutePath.level(
              chapterId: uri.pathSegments[1], levelId: uri.pathSegments[2]);
        }
      } else if (firstSegment == 'editor') {
        final secondSegment = uri.pathSegments.skip(1).firstOrNull;
        if (secondSegment == 'generated') {
          // Try to fetch map string
          final thirdSegment = uri.pathSegments.skip(2).firstOrNull;
          if (thirdSegment != null) {
            return EditorRoutePath.generatedLevel(
                decodeMapString(thirdSegment));
          }
        }

        String mapString;
        try {
          mapString = decodeMapString(secondSegment ?? '');
        } on Object {
          mapString = '';
        }
        return EditorRoutePath.editor(mapString);
      }
    }
    return const LevelRoutePath.chapterSelection();
  }

  @override
  RouteInformation? restoreRouteInformation(AppRoutePath configuration) {
    return RouteInformation(location: configuration.location);
  }
}
