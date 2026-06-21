import 'package:flutter/foundation.dart';

import '../models/exercise.dart';
import '../repositories/exercise_repository.dart';
import '../services/interceptors/error_interceptor.dart';

/// High-level status of the screen, used to pick what the UI shows.
enum ViewStatus { initial, loading, success, error }

/// Owns all exercise state and the logic that mutates it.
///
/// The UI never calls the repository directly — it reads the lists/flags this
/// provider exposes and calls its methods. Both remote (read-only) exercises
/// and local custom exercises are combined here.
class ExerciseProvider extends ChangeNotifier {
  ExerciseProvider({ExerciseRepository? repository})
      : _repository = repository ?? ExerciseRepository();

  final ExerciseRepository _repository;

  ViewStatus _status = ViewStatus.initial;
  ViewStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _query = '';
  String get query => _query;

  List<Exercise> _remote = const [];
  List<Exercise> _custom = const [];

  bool get isLoading => _status == ViewStatus.loading;
  bool get hasError => _status == ViewStatus.error;

  /// All exercises (custom first), filtered by the current search [query].
  List<Exercise> get exercises {
    final all = [..._custom, ..._remote];
    if (_query.isEmpty) return all;

    final lower = _query.toLowerCase();
    return all.where((e) {
      return e.name.toLowerCase().contains(lower) ||
          e.bodyPart.toLowerCase().contains(lower) ||
          e.equipment.toLowerCase().contains(lower) ||
          e.targetMuscle.toLowerCase().contains(lower);
    }).toList();
  }

  bool get isEmpty => exercises.isEmpty;

  /// Initial load + reload. Fetches remote exercises and local custom ones.
  Future<void> loadExercises() async {
    _status = ViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getRemoteExercises(limit: 30),
        _repository.getCustomExercises(),
      ]);
      _remote = results[0];
      _custom = results[1];
      _status = ViewStatus.success;
    } catch (e) {
      _errorMessage = _messageFor(e);
      _status = ViewStatus.error;
    }
    notifyListeners();
  }

  /// Pull-to-refresh: re-fetch remote data, keep local data in sync.
  Future<void> refresh() => loadExercises();

  /// Update the search term and re-filter (purely local, no network call).
  void search(String value) {
    _query = value;
    notifyListeners();
  }

  // ---- CRUD on custom exercises ----

  Future<void> addCustomExercise(Exercise exercise) async {
    await _repository.addCustomExercise(exercise);
    _custom = await _repository.getCustomExercises();
    notifyListeners();
  }

  Future<void> updateCustomExercise(Exercise exercise) async {
    await _repository.updateCustomExercise(exercise);
    _custom = await _repository.getCustomExercises();
    notifyListeners();
  }

  Future<void> deleteCustomExercise(String id) async {
    await _repository.deleteCustomExercise(id);
    _custom = await _repository.getCustomExercises();
    notifyListeners();
  }

  String _messageFor(Object error) {
    if (error is AppException) return error.message;
    return 'Something went wrong. Please try again.';
  }
}
