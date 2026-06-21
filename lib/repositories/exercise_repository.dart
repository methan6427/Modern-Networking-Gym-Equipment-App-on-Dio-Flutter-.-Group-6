import '../models/exercise.dart';
import '../services/exercise_api_service.dart';
import '../services/local_storage_service.dart';

/// Single source of truth for exercise data.
///
/// The repository hides *where* data comes from: remote exercises are fetched
/// over the network via [ExerciseApiService], while user-created exercises live
/// in [LocalStorageService]. Providers and UI talk only to this class.
class ExerciseRepository {
  ExerciseRepository({
    ExerciseApiService? apiService,
    LocalStorageService? localStorage,
  })  : _api = apiService ?? ExerciseApiService(),
        _local = localStorage ?? LocalStorageService();

  final ExerciseApiService _api;
  final LocalStorageService _local;

  // ---- Remote (read-only) ----

  Future<List<Exercise>> getRemoteExercises({
    int limit = 25,
    int offset = 0,
  }) {
    return _api.fetchExercises(limit: limit, offset: offset);
  }

  Future<Exercise> getExerciseById(String id) => _api.fetchExerciseById(id);

  Future<List<Exercise>> searchRemote(String query) =>
      _api.searchExercises(query);

  // ---- Local custom exercises (CRUD) ----

  Future<List<Exercise>> getCustomExercises() => _local.getCustomExercises();

  Future<void> addCustomExercise(Exercise exercise) =>
      _local.saveCustomExercise(exercise);

  Future<void> updateCustomExercise(Exercise exercise) =>
      _local.updateCustomExercise(exercise);

  Future<void> deleteCustomExercise(String id) =>
      _local.deleteCustomExercise(id);

  // ---- Theme preference ----

  Future<bool> isDarkMode() => _local.isDarkMode();

  Future<void> setDarkMode(bool value) => _local.setDarkMode(value);
}
