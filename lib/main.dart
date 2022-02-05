import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/puzzle/level_reader.dart';
import 'package:slide/routing/app_route_parser.dart';
import 'package:slide/routing/app_router_delegate.dart';
import 'package:slide/level/bloc/level_bloc.dart';
import 'package:slide/routing/navigator_bloc.dart';

import 'keyboard/bloc/keyboard_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final levels = await LevelReader.readLevels();
  runApp(MyApp(levels: levels));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key, required this.levels}) : super(key: key);

  final List<LevelData> levels;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationCubit(),
      child: Builder(
        builder: (context) => MaterialApp.router(
          title: 'slide',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            textTheme: TextTheme(
              subtitle1: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ),
          routerDelegate: AppRouterDelegate(
            navigationCubit: context.watch<NavigationCubit>(),
            levelList: LevelList([
              ...widget.levels,
              // LevelData(name: 'test', map: ''),
            ]),
            navigatorKey: navigatorKey,
          ),
          routeInformationParser: AppRouteParser(),
        ),
      ),
    );
  }
}

class ArrowIndicator extends StatelessWidget {
  const ArrowIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pressedKey =
        context.select((KeyboardBloc bloc) => bloc.state.latestKey);
    return Icon(
      pressedKey == LogicalKeyboardKey.arrowLeft
          ? Icons.arrow_left
          : pressedKey == LogicalKeyboardKey.arrowRight
              ? Icons.arrow_right
              : pressedKey == LogicalKeyboardKey.arrowUp
                  ? Icons.arrow_upward
                  : pressedKey == LogicalKeyboardKey.arrowDown
                      ? Icons.arrow_downward
                      : null,
      color: Colors.blue,
    );
  }
}
