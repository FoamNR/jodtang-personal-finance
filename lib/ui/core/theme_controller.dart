import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Controller for managing and persisting the application ThemeMode (Light / Dark).
class ThemeController extends ChangeNotifier {
  static final ThemeController _instance = ThemeController._internal();
  factory ThemeController() => _instance;
  ThemeController._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _themeKey = 'app_theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  /// Returns whether the effective theme is dark, accounting for system setting when mode is system.
  bool isDark(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  /// Initialize and restore persisted theme mode from secure storage.
  Future<void> init() async {
    try {
      final saved = await _storage.read(key: _themeKey);
      if (saved == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (saved == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }
      notifyListeners();
    } catch (_) {}
  }

  /// Toggle or explicitly set dark mode.
  Future<void> setDarkMode(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    try {
      await _storage.write(key: _themeKey, value: isDark ? 'dark' : 'light');
    } catch (_) {}
  }

  /// Set specific ThemeMode (system, light, dark).
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    try {
      final val = mode == ThemeMode.dark ? 'dark' : (mode == ThemeMode.light ? 'light' : 'system');
      await _storage.write(key: _themeKey, value: val);
    } catch (_) {}
  }
}
