import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';
import '../providers/exercise_provider.dart';
import '../widgets/exercise_form.dart';
import 'edit_screen.dart';

/// Shows the full details of an exercise.
///
/// Edit and Delete actions are only available for custom exercises
/// (`exercise.isCustom == true`) — remote exercises are read-only.
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.exercise});

  final Exercise exercise;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Exercise _exercise = widget.exercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_exercise.name),
        actions: [
          if (_exercise.isCustom) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: _onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete',
              onPressed: _onDelete,
            ),
          ],
        ],
      ),
      body: ListView(
        children: [
          if (_exercise.gifUrl.isNotEmpty)
            ExerciseImageWidget(
              gifUrl: _exercise.gifUrl,
              height: 240,
              width: double.infinity,
              fit: BoxFit.contain,
              errorChild: const SizedBox(
                height: 240,
                child: Center(child: Icon(Icons.broken_image, size: 64)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_exercise.isCustom)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Chip(
                      label: const Text('Custom exercise'),
                      backgroundColor: theme.colorScheme.secondaryContainer,
                    ),
                  ),
                _InfoRow(label: 'Body part', value: _exercise.bodyPart),
                _InfoRow(label: 'Target muscle', value: _exercise.targetMuscle),
                _InfoRow(label: 'Equipment', value: _exercise.equipment),
                const SizedBox(height: 16),
                if (_exercise.instructions.isNotEmpty) ...[
                  Text('Instructions', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ..._exercise.instructions.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text('${entry.key + 1}. ${entry.value}'),
                        ),
                      ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onEdit() async {
    final updated = await Navigator.of(context).push<Exercise>(
      MaterialPageRoute(
        builder: (_) => EditScreen(exercise: _exercise),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _exercise = updated);
    }
  }

  Future<void> _onDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete exercise?'),
        content: Text('"${_exercise.name}" will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<ExerciseProvider>();
    final navigator = Navigator.of(context);
    await provider.deleteCustomExercise(_exercise.id);
    navigator.pop();
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
