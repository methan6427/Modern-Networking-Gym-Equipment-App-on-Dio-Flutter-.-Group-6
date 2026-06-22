import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final _picker = ImagePicker();

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

  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      _gifUrl.text = picked.path;
    }
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
          _urlField(),
          _ImagePreview(controller: _gifUrl),
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

  Widget _urlField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TextFormField(
            controller: _gifUrl,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Image/GIF URL (optional)',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null;
              final trimmed = value.trim();
              if (_isNetworkUrl(trimmed)) {
                final uri = Uri.tryParse(trimmed);
                if (uri == null || !uri.hasAbsolutePath) {
                  return 'Enter a valid http:// or https:// URL';
                }
                return null;
              }
              // Local file path picked from gallery
              if (!File(trimmed).existsSync()) {
                return 'File not found. Re-browse or enter a URL.';
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: OutlinedButton.icon(
            onPressed: _pickFromGallery,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Browse Gallery'),
          ),
        ),
      ],
    );
  }
}

bool _isNetworkUrl(String value) =>
    value.startsWith('http://') || value.startsWith('https://');

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final url = value.text.trim();
        if (url.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ExerciseImageWidget(
              gifUrl: url,
              height: 180,
              width: double.infinity,
              fit: BoxFit.contain,
              errorChild: Container(
                height: 180,
                color: Colors.grey.shade200,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Could not load image — check the URL',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Displays an exercise image from either a network URL or a local file path.
class ExerciseImageWidget extends StatelessWidget {
  const ExerciseImageWidget({
    super.key,
    required this.gifUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.errorChild,
  });

  final String gifUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Widget? errorChild;

  @override
  Widget build(BuildContext context) {
    final fallback = errorChild ??
        Container(
          height: height,
          width: width,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.fitness_center),
        );

    if (_isNetworkUrl(gifUrl)) {
      return CachedNetworkImage(
        imageUrl: gifUrl,
        height: height,
        width: width,
        fit: fit,
        placeholder: (_, _) => fallback,
        errorWidget: (_, _, _) => fallback,
      );
    }

    return Image.file(
      File(gifUrl),
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}
