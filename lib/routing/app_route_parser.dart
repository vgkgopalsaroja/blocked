import 'package:flutter/material.dart';
import 'package:slide/routing/app_route_path.dart';

class AppRouteParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    if (routeInformation.location == null) {
      return const AppRoutePath.levelSelection();
    }
    final uri = Uri.parse(routeInformation.location!);

    if (uri.pathSegments.isEmpty) {
      return const AppRoutePath.levelSelection();
    } else {
      final firstSegment = uri.pathSegments.first;
      if (firstSegment == 'levels') {
        if (uri.pathSegments.length == 1) {
          return const AppRoutePath.levelSelection();
        } else if (uri.pathSegments.length == 2) {
          return AppRoutePath.level(id: uri.pathSegments[1]);
        }
      } else if (firstSegment == 'editor') {
        return const AppRoutePath.editor();
      }
    }
    return const AppRoutePath.levelSelection();
  }

  @override
  RouteInformation? restoreRouteInformation(AppRoutePath configuration) {
    return RouteInformation(location: configuration.location);
  }
}
