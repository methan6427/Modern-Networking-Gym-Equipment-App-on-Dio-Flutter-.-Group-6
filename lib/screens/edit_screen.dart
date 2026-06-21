import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';
import '../providers/exercise_provider.dart';
import '../widgets/exercise_form.dart';

/// Edit an existing custom exercise. Pre-fills the form with [exercise].
class EditScreen extends StatelessWidget {
  const EditScreen({super.key, required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Exercise')),
      body: ExerciseForm(
        initial: exercise,
        submitLabel: 'Update',
        onSubmit: (updated) async {
          await _update(context, updated);
        },
      ),
    );
  }

  Future<void> _update(BuildContext context, Exercise updated) async {
    final provider = context.read<ExerciseProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    await provider.updateCustomExercise(updated);

    messenger.showSnackBar(
      const SnackBar(content: Text('Exercise updated')),
    );
    // Pop back to the list (past the detail screen) and return the update.
    navigator.pop(updated);
  }
}
