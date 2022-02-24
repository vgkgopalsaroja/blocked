import 'package:blocked/level/level.dart';
import 'package:blocked/models/models.dart';
import 'package:blocked/routing/routing.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final levels = await readLevelsFromYaml();
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
      title: 'blocked',
      themeMode: ThemeMode.system,
      theme: FlexThemeData.dark(
        colors: FlexSchemeColor.from(
          primary: greenColorScheme.primary,
          secondary: greenColorScheme.tertiary,
        ),
        useSubThemes: true,
        blendLevel: 16,
        fontFamily: GoogleFonts.dmSans().fontFamily,
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
