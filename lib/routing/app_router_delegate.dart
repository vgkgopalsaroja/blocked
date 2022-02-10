import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/pages/generated_level_page.dart';
import 'package:slide/pages/level_editor_page.dart';
import 'package:slide/pages/level_page.dart';
import 'package:slide/routing/app_route_path.dart';
import 'package:slide/level/bloc/level_bloc.dart';
import 'package:slide/pages/level_selection_page.dart';
import 'package:slide/routing/navigator_cubit.dart';
import 'package:slide/widgets/puzzle/board_controls.dart';

class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  AppRouterDelegate({
    required this.levelList,
    required GlobalKey<NavigatorState> navigatorKey,
  })  : _navigatorKey = navigatorKey,
        isLoaded = false;

  final GlobalKey<NavigatorState> _navigatorKey;
  final LevelList levelList;

  bool isLoaded;
  NavigatorCubit navigatorCubit =
      NavigatorCubit(const LevelRoutePath.levelSelection());

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NavigatorCubit, AppRoutePath>(
      bloc: navigatorCubit,
      // listenWhen: (previous, current) => isLoaded,
      listener: (context, state) {
        notifyListeners();
      },
      builder: (context, state) {
        final path = state;
        return BlocProvider(
          create: (context) => navigatorCubit,
          child: Navigator(
            key: _navigatorKey,
            pages: [
              MaterialPage(child: LevelSelectionPage(levelList.levels)),
              if (path is EditorRoutePath) ...{
                const MaterialPage(child: LevelEditorPage()),
                if (path.isInPreview)
                  MaterialPage(
                    key: ValueKey(path.mapString),
                    child:
                        GeneratedLevelPage(Uri.decodeComponent(path.mapString)),
                  ),
              },
              if (path is LevelRoutePath && path.levelId != null) ...{
                MaterialPage(
                  child: Scaffold(
                    body: LevelPage(
                      levelList.getLevelWithId(path.levelId!)!.toLevel(),
                      boardControls: const BoardControls(),
                      key: Key(levelList.getLevelWithId(path.levelId!)!.name),
                      onExit: () => navigatorCubit.navigateToLevelSelection(),
                      onNext: () {
                        String? nextLevelId =
                            levelList.getLevelAfterId(path.levelId!)?.name;
                        if (nextLevelId != null) {
                          navigatorCubit.navigateToLevel(nextLevelId);
                        } else {
                          navigatorCubit.navigateToLevelSelection();
                        }
                      },
                    ),
                  ),
                ),
              }
            ],
            onPopPage: (route, result) {
              if (!route.didPop(result)) {
                return false;
              }
              navigatorCubit.navigateToPreviousPage();
              return true;
            },
          ),
        );
      },
    );
  }

  @override
  Future<void> setInitialRoutePath(AppRoutePath configuration) {
    navigatorCubit = NavigatorCubit(configuration);
    isLoaded = true;
    return SynchronousFuture(null);
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) {
    if (configuration is EditorRoutePath) {
      if (configuration.isInPreview) {
        navigatorCubit.navigateToGeneratedLevel(configuration.mapString);
      } else {
        navigatorCubit.navigateToEditor(configuration.mapString);
      }
    } else if (configuration is LevelRoutePath &&
        configuration.levelId != null) {
      navigatorCubit.navigateToLevel(configuration.levelId!);
    } else {
      navigatorCubit.navigateToLevelSelection();
    }

    return SynchronousFuture(null);
  }

  @override
  AppRoutePath? get currentConfiguration => navigatorCubit.state;

  @override
  GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;
}
