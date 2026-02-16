import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String? getString(String key) => _prefs?.getString(key);
  int? getInt(String key) => _prefs?.getInt(key);
  bool? getBool(String key) => _prefs?.getBool(key);

  Future<void> setString(String key, String value) async {
    if (_prefs == null) return;
    await _prefs!.setString(key, value);
  }

  Future<void> setInt(String key, int value) async {
    if (_prefs == null) return;
    await _prefs!.setInt(key, value);
  }

  Future<void> setBool(String key, bool value) async {
    if (_prefs == null) return;
    await _prefs!.setBool(key, value);
  }

  Future<void> remove(String key) async {
    if (_prefs == null) return;
    await _prefs!.remove(key);
  }
}
