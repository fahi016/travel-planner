import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeBoxName = 'theme';
  static const String _isDarkModeKey = 'isDarkMode';
  
  late Box<bool> _themeBox;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  // Initialize the provider
  static Future<ThemeProvider> initialize() async {
    final provider = ThemeProvider();
    await provider._initializeTheme();
    return provider;
  }

  // Private initialize method
  Future<void> _initializeTheme() async {
    _themeBox = await Hive.openBox<bool>(_themeBoxName);
    _isDarkMode = _themeBox.get(_isDarkModeKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _themeBox.put(_isDarkModeKey, _isDarkMode);
    notifyListeners();
  }
} 