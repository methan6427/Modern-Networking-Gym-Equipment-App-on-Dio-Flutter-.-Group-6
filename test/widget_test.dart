import 'package:flutter_test/flutter_test.dart';

import 'package:modern_networking/models/exercise.dart';

void main() {
  test('Exercise.fromJson parses both singular and plural API shapes', () {
    final singular = Exercise.fromJson({
      'id': '1',
      'name': 'Push Up',
      'bodyPart': 'chest',
      'target': 'pectorals',
      'equipment': 'body weight',
      'gifUrl': 'http://example.com/a.gif',
      'instructions': ['Step 1', 'Step 2'],
    });

    expect(singular.id, '1');
    expect(singular.bodyPart, 'chest');
    expect(singular.targetMuscle, 'pectorals');
    expect(singular.instructions.length, 2);
    expect(singular.isCustom, false);

    final plural = Exercise.fromJson({
      'exerciseId': '2',
      'name': 'Squat',
      'bodyParts': ['upper legs'],
      'targetMuscles': ['quads'],
      'equipments': ['barbell'],
      'gifUrl': 'http://example.com/b.gif',
      'instructions': ['Step 1'],
    });

    expect(plural.id, '2');
    expect(plural.bodyPart, 'upper legs');
    expect(plural.equipment, 'barbell');
  });

  test('Exercise round-trips through toJson/fromJson', () {
    const original = Exercise(
      id: 'custom-1',
      name: 'My Move',
      bodyPart: 'back',
      targetMuscle: 'lats',
      equipment: 'cable',
      instructions: ['Pull'],
      gifUrl: '',
      isCustom: true,
    );

    final restored = Exercise.fromJson(original.toJson());
    expect(restored.name, 'My Move');
    expect(restored.isCustom, true);
  });
}
