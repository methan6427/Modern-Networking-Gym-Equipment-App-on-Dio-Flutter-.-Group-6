import 'package:dio/dio.dart';

import '../models/exercise.dart';
import 'dio_client.dart';

/// Talks to the remote wger workout API (https://wger.de) via Dio.
///
/// This class only knows how to make HTTP calls and turn wger's JSON into the
/// app's [Exercise] model. wger's response shape is nested and differs from
/// our flat model, so the mapping lives here (keeping the model API-agnostic).
/// It performs no caching and holds no state — that is the repository's job.
class ExerciseApiService {
  ExerciseApiService({Dio? dio}) : _dio = dio ?? DioClient().dio;

  final Dio _dio;

  /// English language id in wger.
  static const int _english = 2;

  /// GET /exerciseinfo/ — a paginated page of fully-detailed exercises.
  Future<List<Exercise>> fetchExercises({
    int limit = 25,
    int offset = 0,
  }) async {
    final response = await _dio.get<dynamic>(
      '/exerciseinfo/',
      queryParameters: {
        'language': _english,
        'limit': limit,
        'offset': offset,
        'format': 'json',
      },
    );
    return _parseList(response.data);
  }

  /// GET /exerciseinfo/{id}/ — a single exercise.
  Future<Exercise> fetchExerciseById(String id) async {
    final response = await _dio.get<dynamic>(
      '/exerciseinfo/$id/',
      queryParameters: {'format': 'json'},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return _fromWger(data);
    }
    throw StateError('Unexpected response shape for exercise $id');
  }

  /// Server has no plain text search, so we fetch a page and filter by name.
  /// (The provider also filters locally; this keeps the repository API whole.)
  Future<List<Exercise>> searchExercises(
    String query, {
    int limit = 50,
  }) async {
    final all = await fetchExercises(limit: limit);
    final lower = query.toLowerCase();
    return all
        .where((e) => e.name.toLowerCase().contains(lower))
        .toList();
  }

  /// GET /exerciseinfo/?category= — filter by category (body part group).
  Future<List<Exercise>> fetchByCategory(
    int categoryId, {
    int limit = 25,
    int offset = 0,
  }) async {
    final response = await _dio.get<dynamic>(
      '/exerciseinfo/',
      queryParameters: {
        'language': _english,
        'category': categoryId,
        'limit': limit,
        'offset': offset,
        'format': 'json',
      },
    );
    return _parseList(response.data);
  }

  /// GET /exerciseinfo/?equipment= — filter by equipment id.
  Future<List<Exercise>> fetchByEquipment(
    int equipmentId, {
    int limit = 25,
    int offset = 0,
  }) async {
    final response = await _dio.get<dynamic>(
      '/exerciseinfo/',
      queryParameters: {
        'language': _english,
        'equipment': equipmentId,
        'limit': limit,
        'offset': offset,
        'format': 'json',
      },
    );
    return _parseList(response.data);
  }

  // ---- Parsing helpers ----

  List<Exercise> _parseList(dynamic body) {
    // wger paginates as { count, next, previous, results: [...] }.
    final results = body is Map<String, dynamic> ? body['results'] : body;
    if (results is List) {
      return results
          .whereType<Map<String, dynamic>>()
          .map(_fromWger)
          .where((e) => e.name.isNotEmpty)
          .toList();
    }
    return const [];
  }

  /// Maps a single wger `exerciseinfo` object into an [Exercise].
  Exercise _fromWger(Map<String, dynamic> json) {
    final translation = _pickEnglishTranslation(json['translations']);

    return Exercise(
      id: '${json['id']}',
      name: (translation['name'] as String?)?.trim() ?? '',
      bodyPart: _categoryName(json['category']),
      targetMuscle: _muscleNames(json['muscles']),
      equipment: _equipmentNames(json['equipment']),
      instructions: _instructions(translation['description']),
      gifUrl: _mainImage(json['images']),
      isCustom: false,
    );
  }

  Map<String, dynamic> _pickEnglishTranslation(dynamic translations) {
    if (translations is! List) return const {};
    Map<String, dynamic>? firstNamed;
    for (final t in translations.whereType<Map<String, dynamic>>()) {
      final name = (t['name'] as String?)?.trim() ?? '';
      if (name.isEmpty) continue;
      firstNamed ??= t;
      if (t['language'] == _english) return t;
    }
    return firstNamed ?? const {};
  }

  String _categoryName(dynamic category) {
    if (category is Map<String, dynamic>) {
      return (category['name'] as String?)?.trim() ?? '';
    }
    return '';
  }

  String _muscleNames(dynamic muscles) {
    if (muscles is! List) return '';
    final names = muscles
        .whereType<Map<String, dynamic>>()
        .map((m) {
          final en = (m['name_en'] as String?)?.trim() ?? '';
          return en.isNotEmpty ? en : (m['name'] as String?)?.trim() ?? '';
        })
        .where((s) => s.isNotEmpty)
        .toSet();
    return names.join(', ');
  }

  String _equipmentNames(dynamic equipment) {
    if (equipment is! List) return '';
    final names = equipment
        .whereType<Map<String, dynamic>>()
        .map((e) => (e['name'] as String?)?.trim() ?? '')
        .where((s) => s.isNotEmpty)
        .map((s) => s.toLowerCase().startsWith('none') ? 'Body weight' : s)
        .toSet();
    return names.join(', ');
  }

  String _mainImage(dynamic images) {
    if (images is! List) return '';
    final maps = images.whereType<Map<String, dynamic>>().toList();
    if (maps.isEmpty) return '';
    final main = maps.firstWhere(
      (m) => m['is_main'] == true,
      orElse: () => maps.first,
    );
    return (main['image'] as String?) ?? '';
  }

  /// wger descriptions are HTML. Strip tags and split into readable steps.
  List<String> _instructions(dynamic description) {
    if (description is! String || description.isEmpty) return const [];
    final text = description
        .replaceAll(RegExp(r'</(p|li|ol|ul|div|br)>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#39;', "'")
        .replaceAll('&quot;', '"');

    return text
        .split(RegExp(r'[\n\r]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
}
