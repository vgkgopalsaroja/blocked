import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/routes/level_route_parser.dart';
import 'package:slide/routes/level_router_delegate.dart';
import 'package:slide/level/bloc/level_bloc.dart';

import 'keyboard/bloc/keyboard_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LevelBloc(null),
      child: Builder(
        builder: (context) => MaterialApp.router(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            textTheme: TextTheme(
              subtitle1: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ),
          routerDelegate: LevelRouterDelegate(
            levelBloc: context.watch<LevelBloc>(),
            navigatorKey: navigatorKey,
          ),
          routeInformationParser: LevelRouteParser(),
          // home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
