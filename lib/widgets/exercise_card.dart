import 'package:flutter/material.dart';

import '../models/exercise.dart';
import 'exercise_form.dart';

/// A single exercise row in the list.
///
/// Shows the GIF thumbnail (cached), the name, body part and a "Custom" badge
/// for user-created exercises.
class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onTap,
  });

  final Exercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        leading: _Thumbnail(exercise: exercise),
        title: Text(
          exercise.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          [exercise.bodyPart, exercise.equipment]
              .where((s) => s.isNotEmpty)
              .join(' • '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: exercise.isCustom
            ? Chip(
                label: const Text('Custom'),
                visualDensity: VisualDensity.compact,
                backgroundColor: theme.colorScheme.secondaryContainer,
              )
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 56,
      height: 56,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.fitness_center),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: exercise.gifUrl.isEmpty
          ? placeholder
          : ExerciseImageWidget(
              gifUrl: exercise.gifUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorChild: placeholder,
            ),
    );
  }
}
