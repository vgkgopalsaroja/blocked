import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slide/puzzle/level_reader.dart';
import 'package:slide/routing/app_route_parser.dart';
import 'package:slide/routing/app_router_delegate.dart';
import 'package:slide/level/bloc/level_bloc.dart';

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
    ColorScheme colorScheme = ColorScheme.fromSeed(
        seedColor: Colors.orange, brightness: Brightness.dark);
    return Builder(
      builder: (context) => MaterialApp.router(
        title: 'slide',
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                side: BorderSide(color: colorScheme.outline, width: 2)),
          ),
          textTheme: GoogleFonts.poppinsTextTheme(
            ThemeData.dark().textTheme,
          ),
        ),
        routerDelegate: AppRouterDelegate(
          // navigatorCubit: context.select((NavigatorCubit cubit) => cubit),
          levelList: LevelList(widget.levels),
          navigatorKey: navigatorKey,
        ),
        routeInformationParser: AppRouteParser(),
      ),
    );
  }
}
