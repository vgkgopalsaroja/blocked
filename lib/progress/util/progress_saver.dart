import 'package:blocked/level/level.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> markLevelAsCompleted(String levelName) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.setBool(levelName, true);
}

Future<bool> isLevelCompleted(String levelName) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getBool(levelName) ?? false;
}

Future<bool> clearData() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  return await sharedPreferences.clear();
}

Future<List<String>> getFirstUncompletedLevel() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  final keys = sharedPreferences.getKeys();
  final chapters = await LevelReader.readLevels();
  for (final chapter in chapters) {
    for (final level in chapter.levels) {
      if (!keys.contains(level.name)) {
        return [chapter.name, level.name];
      }
    }
  }
  return [chapters.last.name, chapters.last.levels.last.name];
}

Future<bool> hasProgress() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  final keys = sharedPreferences.getKeys();
  return keys.isNotEmpty;
}
