import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';
import '../providers/exercise_provider.dart';
import '../widgets/exercise_form.dart';

/// Create a new custom exercise (saved to SharedPreferences).
class AddScreen extends StatelessWidget {
  const AddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Exercise')),
      body: ExerciseForm(
        submitLabel: 'Create',
        onSubmit: (exercise) async {
          await _save(context, exercise);
        },
      ),
    );
  }

  Future<void> _save(BuildContext context, Exercise exercise) async {
    final provider = context.read<ExerciseProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    await provider.addCustomExercise(exercise);

    messenger.showSnackBar(
      const SnackBar(content: Text('Exercise created')),
    );
    navigator.pop();
  }
}
