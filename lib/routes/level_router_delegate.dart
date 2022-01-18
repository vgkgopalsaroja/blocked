import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:slide/level_page.dart';
import 'package:slide/routes/level_route_path.dart';
import 'package:slide/level/bloc/level_bloc.dart';
import 'package:slide/widgets/level_selection_page.dart';

class LevelRouterDelegate extends RouterDelegate<LevelRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  LevelRouterDelegate({
    required this.levelBloc,
    required GlobalKey<NavigatorState> navigatorKey,
  }) : _navigatorKey = navigatorKey;

  final LevelBloc levelBloc;

  final GlobalKey<NavigatorState> _navigatorKey;

  @override
  Widget build(BuildContext context) {
    final levelData = levelBloc.state;

    final level = levelData?.toLevel();
    return Navigator(
      key: _navigatorKey,
      pages: [
        const MaterialPage(child: LevelSelectionPage()),
        if (level != null) ...{
          MaterialPage(
              child: LevelPage(
            level,
            key: Key(level.name),
          )),
        }
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        levelBloc.add(const LevelExited());
        // level = null;
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(LevelRoutePath configuration) {
    final level = configuration.levelId != null
        ? levelBloc.getLevelWithId(configuration.levelId!)
        : null;
    levelBloc.add(level != null ? LevelChosen(level) : const LevelExited());
    return SynchronousFuture(null);
  }

  @override
  LevelRoutePath? get currentConfiguration {
    final level = levelBloc.state;
    if (level != null) {
      return LevelRoutePath.level(id: level.name);
    } else {
      return const LevelRoutePath.levelSelection();
    }
  }

  @override
  GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;
}
