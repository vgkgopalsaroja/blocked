import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:blocked/progress/progress.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsContext = context;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ValueListenableBuilder<AdaptiveThemeMode>(
                valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
                builder: (_, mode, child) {
                  return ListTile(
                    leading: const Icon(Icons.palette_rounded),
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
                }),
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
