import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _userIdKey = 'user_id';
  static const String _dogIdKey = 'dog_id';

  static Future<void> saveUserId(int userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
  }

  static Future<void> saveDogId(int dogId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dogIdKey, dogId);
  }

  static Future<void> clearUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_dogIdKey); // clear dog Id too
  }

  static Future<int?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  static Future<int?> getDogId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dogIdKey);
  }

}
