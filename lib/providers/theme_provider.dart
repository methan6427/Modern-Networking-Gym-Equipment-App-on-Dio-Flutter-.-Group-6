import 'package:flutter/material.dart';

import '../repositories/exercise_repository.dart';

/// Holds the active [ThemeMode] and persists the user's choice.
///
/// The preference is stored via [ExerciseRepository] (which uses
/// SharedPreferences underneath), so dark mode survives app restarts.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider({ExerciseRepository? repository})
      : _repository = repository ?? ExerciseRepository();

  final ExerciseRepository _repository;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Load the saved preference. Call once at startup.
  Future<void> load() async {
    final dark = await _repository.isDarkMode();
    _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme(bool enableDark) async {
    _themeMode = enableDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await _repository.setDarkMode(enableDark);
  }
}
