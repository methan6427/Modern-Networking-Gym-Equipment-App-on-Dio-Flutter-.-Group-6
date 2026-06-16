/// Core data model for the app.
///
/// One model represents both:
///  - exercises fetched from the remote AscendAPI (`isCustom == false`)
///  - exercises created locally by the user (`isCustom == true`)
///
/// The remote API has been observed to return fields in slightly different
/// shapes (e.g. `bodyPart` as a String vs `bodyParts` as a List, and `id`
/// vs `exerciseId`). [Exercise.fromJson] is intentionally defensive so the
/// app keeps working regardless of which shape the API returns.
class Exercise {
  final String id;
  final String name;
  final String bodyPart;
  final String targetMuscle;
  final String equipment;
  final List<String> instructions;
  final String gifUrl;

  /// `true` when the exercise was created locally and stored in
  /// SharedPreferences. Controls whether Edit/Delete actions are shown.
  final bool isCustom;

  const Exercise({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.targetMuscle,
    required this.equipment,
    required this.instructions,
    required this.gifUrl,
    this.isCustom = false,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    // Returns the first non-empty value among [keys]. Accepts either a plain
    // String or the first element of a List (handles `bodyPart`/`bodyParts`).
    String pickString(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value is String && value.isNotEmpty) return value;
        if (value is List && value.isNotEmpty) return value.first.toString();
      }
      return '';
    }

    // Returns the first list-like value among [keys] as a List<String>.
    List<String> pickList(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value is List) {
          return value.map((e) => e.toString()).toList();
        }
        if (value is String && value.isNotEmpty) return [value];
      }
      return const [];
    }

    return Exercise(
      id: pickString(['id', 'exerciseId', '_id']),
      name: pickString(['name']),
      bodyPart: pickString(['bodyPart', 'bodyParts']),
      targetMuscle: pickString(['target', 'targetMuscle', 'targetMuscles']),
      equipment: pickString(['equipment', 'equipments']),
      instructions: pickList(['instructions']),
      gifUrl: pickString(['gifUrl', 'image', 'imageUrl']),
      isCustom: json['isCustom'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'bodyPart': bodyPart,
        'targetMuscle': targetMuscle,
        'equipment': equipment,
        'instructions': instructions,
        'gifUrl': gifUrl,
        'isCustom': isCustom,
      };

  Exercise copyWith({
    String? id,
    String? name,
    String? bodyPart,
    String? targetMuscle,
    String? equipment,
    List<String>? instructions,
    String? gifUrl,
    bool? isCustom,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      bodyPart: bodyPart ?? this.bodyPart,
      targetMuscle: targetMuscle ?? this.targetMuscle,
      equipment: equipment ?? this.equipment,
      instructions: instructions ?? this.instructions,
      gifUrl: gifUrl ?? this.gifUrl,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}
