import 'package:flutter/material.dart';
import 'package:slide/routes/level_route_path.dart';

class LevelRouteParser extends RouteInformationParser<LevelRoutePath> {
  @override
  Future<LevelRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    if (routeInformation.location == null) {
      return const LevelRoutePath.levelSelection();
    }
    final uri = Uri.parse(routeInformation.location!);

    if (uri.pathSegments.isEmpty) {
      return const LevelRoutePath.levelSelection();
    } else {
      if (uri.pathSegments[0] == 'levels') {
        if (uri.pathSegments.length == 1) {
          return const LevelRoutePath.levelSelection();
        } else if (uri.pathSegments.length == 2) {
          return LevelRoutePath.level(id: uri.pathSegments[1]);
        }
      }
    }
    return const LevelRoutePath.levelSelection();
  }

  @override
  RouteInformation? restoreRouteInformation(LevelRoutePath configuration) {
    return RouteInformation(location: configuration.location);
  }
}
