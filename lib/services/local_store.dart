import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  static final Map<String, Object> _memory = {};

  Future<String?> getString(String key) async {
    try { return (await SharedPreferences.getInstance()).getString(key) ?? _memory[key] as String?; } catch (_) { return _memory[key] as String?; }
  }
  Future<bool?> getBool(String key) async {
    try { return (await SharedPreferences.getInstance()).getBool(key) ?? _memory[key] as bool?; } catch (_) { return _memory[key] as bool?; }
  }
  Future<List<String>?> getStringList(String key) async {
    try { return (await SharedPreferences.getInstance()).getStringList(key) ?? (_memory[key] as List<String>?); } catch (_) { return _memory[key] as List<String>?; }
  }
  Future<void> setString(String key, String value) async {
    _memory[key] = value;
    try { await (await SharedPreferences.getInstance()).setString(key, value); } catch (_) {}
  }
  Future<void> setBool(String key, bool value) async {
    _memory[key] = value;
    try { await (await SharedPreferences.getInstance()).setBool(key, value); } catch (_) {}
  }
  Future<void> setStringList(String key, List<String> value) async {
    _memory[key] = List<String>.from(value);
    try { await (await SharedPreferences.getInstance()).setStringList(key, value); } catch (_) {}
  }
  Future<bool> containsKey(String key) async {
    try { return (await SharedPreferences.getInstance()).containsKey(key) || _memory.containsKey(key); } catch (_) { return _memory.containsKey(key); }
  }
  Future<void> remove(String key) async {
    _memory.remove(key);
    try { await (await SharedPreferences.getInstance()).remove(key); } catch (_) {}
  }
}
