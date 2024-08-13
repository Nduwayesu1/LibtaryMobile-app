import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    appBarTheme: AppBarTheme(
      color: Colors.blue, // Light mode app bar color
    ),
  );

  ThemeData _darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
      color: Colors.black, // Dark mode app bar color
    ),
  );

  bool _isDarkMode = false;
  String _sortingPreference = 'title'; // Default sorting preference

  bool get isDarkMode => _isDarkMode;

  String get sortingPreference => _sortingPreference;

  ThemeData get themeData => _isDarkMode ? _darkTheme : _lightTheme;

  ThemeProvider() {
    _loadThemePreference();
    _loadSortingPreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('theme_preference') ?? false;
    } catch (e) {
      print('Error loading theme preference: $e');
    }
    notifyListeners(); // Notify listeners after loading theme preference
  }

  Future<void> _loadSortingPreference() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _sortingPreference = prefs.getString('sorting_preference') ?? 'title';
    } catch (e) {
      print('Error loading sorting preference: $e');
    }
    notifyListeners(); // Notify listeners after loading sorting preference
  }

  Future<void> _saveThemePreference(bool value) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('theme_preference', value);
    } catch (e) {
      print('Error saving theme preference: $e');
    }
    notifyListeners(); // Notify listeners after saving theme preference
  }

  Future<void> _saveSortingPreference(String value) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('sorting_preference', value);
    } catch (e) {
      print('Error saving sorting preference: $e');
    }
    notifyListeners(); // Notify listeners after saving sorting preference
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _saveThemePreference(_isDarkMode);
    notifyListeners(); // Notify listeners to update the UI
  }

  void setSortingPreference(String value) async {
    _sortingPreference = value;
    await _saveSortingPreference(value);
    notifyListeners(); // Notify listeners to update the UI
  }
}
