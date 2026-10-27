import 'package:shared_preferences/shared_preferences.dart';

/// تخزين نصي بسيط يعزل المصدر عن مكتبة الحفظ.
abstract class DemoStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class SharedPrefsDemoStorage implements DemoStorage {
  SharedPrefsDemoStorage([SharedPreferencesAsync? prefs])
      : _prefs = prefs ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;

  @override
  Future<String?> read(String key) => _prefs.getString(key);

  @override
  Future<void> write(String key, String value) => _prefs.setString(key, value);

  @override
  Future<void> delete(String key) => _prefs.remove(key);
}

class InMemoryDemoStorage implements DemoStorage {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}
