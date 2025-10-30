import 'package:shared_preferences/shared_preferences.dart';

//final SharedPreferences prefs=await SharedPreferences.getInstance();
class PrefsHelper {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }



  static Future<bool> setString(String key, String value) async {
    if (_prefs == null) throw Exception('CacheHelper not initialized');
    return await _prefs!.setString(key, value);
  }

  static Future<bool> setInt(String key, int value) async {
    if (_prefs == null) throw Exception('CacheHelper not initialized');
    return await _prefs!.setInt(key, value);
  }

  static Future<bool> setBool(String key, bool value) async {
    if (_prefs == null) throw Exception('CacheHelper not initialized');
    return await _prefs!.setBool(key, value);
  }



  static String? getString(String key) {
    if (_prefs == null) throw Exception('CacheHelper not initialized');
    return _prefs!.getString(key);
  }

  static int? getInt(String key) {
    if (_prefs == null) throw Exception('CacheHelper not initialized');
    return _prefs!.getInt(key);
  }
  static bool? getBool(String key) {
    if (_prefs == null) throw Exception('CacheHelper not initialized');
    return _prefs!.getBool(key);
  }


  static Future<bool> remove(String key)async{
    if (_prefs == null) throw Exception('CacheHelper not initialized');
    return await _prefs!.remove(key);
  }
  static Future<bool> clear()async{
    if (_prefs == null) throw Exception('CacheHelper not initialized');
    return await _prefs!.clear();
  }


}
