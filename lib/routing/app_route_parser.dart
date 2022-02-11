import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:slide/routing/app_route_path.dart';
import 'package:collection/collection.dart';

class AppRouteParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
      RouteInformation routeInformation) {
    return SynchronousFuture(_parseRouteInformationSync(routeInformation));
  }

  AppRoutePath _parseRouteInformationSync(RouteInformation routeInformation) {
    if (routeInformation.location == null) {
      return const LevelRoutePath.levelSelection();
    }
    final uri = Uri.parse(routeInformation.location!);

    if (uri.pathSegments.isEmpty) {
      return const LevelRoutePath.levelSelection();
    } else {
      final firstSegment = uri.pathSegments.first;
      if (firstSegment == 'levels') {
        if (uri.pathSegments.length == 1) {
          return const LevelRoutePath.levelSelection();
        } else if (uri.pathSegments.length == 2 &&
            uri.pathSegments[1].isNotEmpty) {
          return LevelRoutePath.level(id: uri.pathSegments[1]);
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
    return const LevelRoutePath.levelSelection();
  }

  @override
  RouteInformation? restoreRouteInformation(AppRoutePath configuration) {
    return RouteInformation(location: configuration.location);
  }
}