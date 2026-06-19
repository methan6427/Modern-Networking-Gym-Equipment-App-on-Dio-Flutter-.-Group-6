import 'package:flutter/material.dart';

import '../models/exercise.dart';

/// Reusable validated form for creating and editing custom exercises.
///
/// Shared by [AddScreen] and [EditScreen]. When [initial] is provided the
/// fields are pre-filled (edit mode); otherwise they start empty (add mode).
/// On a valid save, [onSubmit] receives the assembled [Exercise].
class ExerciseForm extends StatefulWidget {
  const ExerciseForm({
    super.key,
    this.initial,
    required this.onSubmit,
    this.submitLabel = 'Save',
  });

  final Exercise? initial;
  final Future<void> Function(Exercise exercise) onSubmit;
  final String submitLabel;

  @override
  State<ExerciseForm> createState() => _ExerciseFormState();
}

class _ExerciseFormState extends State<ExerciseForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _bodyPart;
  late final TextEditingController _target;
  late final TextEditingController _equipment;
  late final TextEditingController _instructions;
  late final TextEditingController _gifUrl;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final e = widget.initial;
    _name = TextEditingController(text: e?.name ?? '');
    _bodyPart = TextEditingController(text: e?.bodyPart ?? '');
    _target = TextEditingController(text: e?.targetMuscle ?? '');
    _equipment = TextEditingController(text: e?.equipment ?? '');
    _instructions =
        TextEditingController(text: e?.instructions.join('\n') ?? '');
    _gifUrl = TextEditingController(text: e?.gifUrl ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _bodyPart.dispose();
    _target.dispose();
    _equipment.dispose();
    _instructions.dispose();
    _gifUrl.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final existing = widget.initial;
    final instructions = _instructions.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final exercise = Exercise(
      id: existing?.id ??
          'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: _name.text.trim(),
      bodyPart: _bodyPart.text.trim(),
      targetMuscle: _target.text.trim(),
      equipment: _equipment.text.trim(),
      instructions: instructions,
      gifUrl: _gifUrl.text.trim(),
      isCustom: true,
    );

    try {
      await widget.onSubmit(exercise);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field(_name, 'Name', validator: _required),
          _field(_bodyPart, 'Body part', validator: _required),
          _field(_target, 'Target muscle', validator: _required),
          _field(_equipment, 'Equipment', validator: _required),
          _field(
            _instructions,
            'Instructions (one step per line)',
            maxLines: 5,
          ),
          _field(_gifUrl, 'Image/GIF URL (optional)'),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submitting ? null : _handleSubmit,
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
