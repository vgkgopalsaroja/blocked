import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:blocked/level/level.dart';
import 'package:blocked/models/models.dart';
import 'package:blocked/routing/routing.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final levels = await readLevelsFromYaml();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(BlockedApp(chapters: levels, savedThemeMode: savedThemeMode));
}

class BlockedApp extends StatelessWidget {
  BlockedApp({Key? key, required this.chapters, required this.savedThemeMode})
      : super(key: key);

  final List<LevelChapter> chapters;
  final AdaptiveThemeMode? savedThemeMode;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  final NavigatorCubit navigatorCubit =
      NavigatorCubit(const AppRoutePath.home());

  ThemeData createThemeWithBrightness(Brightness brightness) {
    final greenColorScheme =
        ColorScheme.fromSeed(seedColor: Colors.green, brightness: brightness);

    if (brightness == Brightness.light) {
      return FlexThemeData.light(
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
        appBarStyle: FlexAppBarStyle.surface,
        surfaceMode: FlexSurfaceMode.highBackgroundLowScaffold,
      );
    } else {
      return FlexThemeData.dark(
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
        appBarStyle: FlexAppBarStyle.surface,
        surfaceMode: FlexSurfaceMode.highBackgroundLowScaffold,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: createThemeWithBrightness(Brightness.light),
      dark: createThemeWithBrightness(Brightness.dark),
      initial: savedThemeMode ?? AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MaterialApp.router(
        title: 'blocked',
        theme: theme,
        darkTheme: darkTheme,
        routeInformationParser: AppRouteParser(),
        routerDelegate: AppRouterDelegate(
          chapters: chapters,
          navigatorKey: navigatorKey,
          navigatorCubit: navigatorCubit,
        ),
      ),
    );
  }
}
