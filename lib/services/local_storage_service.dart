import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/exercise.dart';

/// Persists data locally with SharedPreferences.
///
/// Two responsibilities:
///  - store user-created ("custom") exercises as a JSON-encoded list, which is
///    how the app demonstrates full CRUD without a writable backend.
///  - remember the user's dark-mode preference.
class LocalStorageService {
  static const String _customExercisesKey = 'custom_exercises';
  static const String _darkModeKey = 'dark_mode';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // ---- Custom exercises (CRUD) ----

  Future<List<Exercise>> getCustomExercises() async {
    final prefs = await _prefs;
    final raw = prefs.getStringList(_customExercisesKey) ?? const [];
    return raw
        .map((s) => Exercise.fromJson(
              jsonDecode(s) as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<void> saveCustomExercise(Exercise exercise) async {
    final exercises = await getCustomExercises();
    exercises.add(exercise.copyWith(isCustom: true));
    await _persist(exercises);
  }

  Future<void> updateCustomExercise(Exercise exercise) async {
    final exercises = await getCustomExercises();
    final index = exercises.indexWhere((e) => e.id == exercise.id);
    if (index == -1) {
      throw StateError('Cannot update: exercise ${exercise.id} not found');
    }
    exercises[index] = exercise.copyWith(isCustom: true);
    await _persist(exercises);
  }

  Future<void> deleteCustomExercise(String id) async {
    final exercises = await getCustomExercises();
    exercises.removeWhere((e) => e.id == id);
    await _persist(exercises);
  }

  Future<void> _persist(List<Exercise> exercises) async {
    final prefs = await _prefs;
    final raw = exercises.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_customExercisesKey, raw);
  }

  // ---- Theme preference ----

  Future<bool> isDarkMode() async {
    final prefs = await _prefs;
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_darkModeKey, value);
  }
}
