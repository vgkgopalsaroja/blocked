import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:slide/pages/level_editor_page.dart';
import 'package:slide/pages/level_page.dart';
import 'package:slide/routing/app_route_path.dart';
import 'package:slide/level/bloc/level_bloc.dart';
import 'package:slide/pages/level_selection_page.dart';
import 'package:slide/routing/navigator_bloc.dart';

class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  AppRouterDelegate({
    required this.levelList,
    required this.navigationCubit,
    // required this.levelBloc,
    required GlobalKey<NavigatorState> navigatorKey,
  }) : _navigatorKey = navigatorKey;

  // final LevelBloc levelBloc;
  final LevelList levelList;
  final NavigationCubit navigationCubit;
  // bool isInEditor = false;
  // LevelData? currentLevel;

  final GlobalKey<NavigatorState> _navigatorKey;

  // LevelData? get currentLevel => navigationCubit.stat;

  @override
  Widget build(BuildContext context) {
    // currentLevel
    // final levelData = levelBloc.state;

    // final level = currentLevel?.toLevel();
    final path = navigationCubit.state;
    return Navigator(
      key: _navigatorKey,
      pages: [
        MaterialPage(child: LevelSelectionPage(levelList.levels)),
        if (path.isEditor)
          const MaterialPage(
            child: LevelEditorPage(),
          ),
        if (path.isLevel) ...{
          MaterialPage(
            child: LevelPage(
              levelList.getLevelWithId(path.levelId!)!.toLevel(),
              key: Key(levelList.getLevelWithId(path.levelId!)!.name),
              onExit: () => navigationCubit.navigateToLevelSelection(),
              onNext: () {
                String? nextLevelId =
                    levelList.getLevelAfterId(path.levelId!)?.name;
                if (nextLevelId != null) {
                  navigationCubit.navigateToLevel(nextLevelId);
                } else {
                  navigationCubit.navigateToLevelSelection();
                }
              },
            ),
          ),
        }
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        // currentLevel = null;
        navigationCubit.navigateToPreviousPage();
        // levelBloc.add(const LevelExited());
        // level = null;
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) {
    if (configuration.isEditor) {
      navigationCubit.navigateToEditor();
    } else if (configuration.isLevel) {
      navigationCubit.navigateToLevel(configuration.levelId!);
    } else {
      navigationCubit.navigateToLevelSelection();
    }
    // currentLevel = configuration.levelId != null
    //     ? levelList.getLevelWithId(configuration.levelId!)
    //     : null;
    // levelBloc.add(level != null ? LevelChosen(level) : const LevelExited());
    return SynchronousFuture(null);
  }

  @override
  AppRoutePath? get currentConfiguration => navigationCubit.state;
  //   if (isInEditor) return const AppRoutePath.editor();
  //   if (currentLevel != null) {
  //     return AppRoutePath.level(id: currentLevel!.name);
  //   } else {
  //     return const AppRoutePath.levelSelection();
  //   }
  // }

  @override
  GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;
}
