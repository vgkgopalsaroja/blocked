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
