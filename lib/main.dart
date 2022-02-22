import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slide/level/level.dart';
import 'package:slide/models/models.dart';
import 'package:slide/routing/routing.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final levels = await LevelReader.readLevels();
  runApp(MyApp(chapters: levels));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key, required this.chapters}) : super(key: key);

  final List<LevelChapter> chapters;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final greenColorScheme = ColorScheme.fromSeed(
        seedColor: Colors.green, brightness: Brightness.dark);
    return MaterialApp.router(
      title: 'shift',
      themeMode: ThemeMode.system,
      theme: FlexThemeData.dark(
        colors: FlexSchemeColor.from(
          primary: greenColorScheme.primary,
          secondary: greenColorScheme.tertiary,
        ),
        useSubThemes: true,
        blendLevel: 16,
        fontFamily: GoogleFonts.poppins().fontFamily,
        subThemesData: const FlexSubThemesData(
          buttonPadding: EdgeInsets.all(16),
          textButtonRadius: 8,
          outlinedButtonRadius: 8,
          elevatedButtonRadius: 8,
        ),
        surfaceMode: FlexSurfaceMode.highBackgroundLowScaffold,
      ),
      routerDelegate: AppRouterDelegate(
        chapters: widget.chapters,
        navigatorKey: navigatorKey,
      ),
      routeInformationParser: AppRouteParser(),
    );
  }
}
