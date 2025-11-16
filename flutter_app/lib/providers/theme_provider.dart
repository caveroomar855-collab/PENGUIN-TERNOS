import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';

class ThemeProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  bool _isDarkMode = false;

  ThemeProvider(this._prefs) {
    _loadTheme();
  }

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeData get lightTheme => AppTheme.lightTheme;
  ThemeData get darkTheme => AppTheme.darkTheme;

  void _loadTheme() {
    _isDarkMode = _prefs.getBool('dark_mode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    _isDarkMode = isDark;
    await _prefs.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }
}
