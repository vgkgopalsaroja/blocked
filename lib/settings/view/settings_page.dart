import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:blocked/progress/progress.dart';
import 'package:blocked/settings/settings.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  static const colors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    final settingsContext = context;
    final themeColor =
        context.select((ThemeColorBloc bloc) => bloc.state.color);
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ValueListenableBuilder<AdaptiveThemeMode>(
              valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
              builder: (_, mode, child) {
                return ListTile(
                  leading: const Icon(Icons.brush_rounded),
                  title: const Text('Theme'),
                  subtitle: Text(mode.name),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: const Text('Theme'),
                        children: [
                          SimpleDialogOption(
                            child: const Text('System'),
                            onPressed: () {
                              AdaptiveTheme.of(context).setSystem();
                              Navigator.pop(context);
                            },
                          ),
                          SimpleDialogOption(
                            child: const Text('Light'),
                            onPressed: () {
                              AdaptiveTheme.of(context).setLight();
                              Navigator.pop(context);
                            },
                          ),
                          SimpleDialogOption(
                            child: const Text('Dark'),
                            onPressed: () {
                              AdaptiveTheme.of(context).setDark();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            ListTile(
              title: const Text('Color'),
              leading: const Icon(Icons.palette_rounded),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Color'),
                    content: SingleChildScrollView(
                      child: SizedBox(
                        width: 128 * 4,
                        child: GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 128,
                            childAspectRatio: 1,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                          ),
                          itemCount: colors.length,
                          itemBuilder: (context, index) {
                            final colorScheme = ColorScheme.fromSeed(
                                seedColor: colors[index],
                                brightness: brightness);
                            final flexColorScheme =
                                brightness == Brightness.light
                                    ? FlexThemeData.light(
                                        colors: FlexSchemeColor.from(
                                          primary: colorScheme.primary,
                                          secondary: colorScheme.tertiary,
                                        ),
                                      ).colorScheme
                                    : FlexThemeData.dark(
                                        colors: FlexSchemeColor.from(
                                          primary: colorScheme.primary,
                                          secondary: colorScheme.tertiary,
                                        ),
                                      ).colorScheme;
                            return _ColorOption(
                              primary: flexColorScheme.primary,
                              secondary: flexColorScheme.secondary,
                              isSelected: themeColor == colors[index],
                              onTap: () {
                                context
                                    .read<ThemeColorBloc>()
                                    .add(ThemeColorChanged(colors[index]));
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Clear progress'),
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear progress'),
                    content: const Text('Are you sure? This cannot be undone.'),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: const Text('Clear'),
                        onPressed: () async {
                          await clearData();
                          ScaffoldMessenger.of(settingsContext).showSnackBar(
                            const SnackBar(
                              content: Text('Progress cleared'),
                            ),
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  const _ColorOption({
    Key? key,
    required this.primary,
    required this.secondary,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  final Color primary;
  final Color secondary;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: primary.darken(5).withOpacity(0.5),
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Positioned.fill(
            child: FittedBox(
              child: Row(
                children: [
                  Ink(
                    width: 3 / 4 * 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(16),
                      ),
                    ),
                  ),
                  Ink(
                    width: 1 / 4 * 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: secondary,
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child:
                isSelected ? Icon(Icons.check, color: primary.onColor) : null,
          )
        ],
      ),
    );
  }
}
