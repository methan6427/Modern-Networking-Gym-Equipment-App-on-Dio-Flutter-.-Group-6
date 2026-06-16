import 'package:flutter/material.dart';

import 'models/exercise.dart';
import 'repositories/exercise_repository.dart';
import 'services/interceptors/error_interceptor.dart';
import 'themes/app_theme.dart';

void main() {
  runApp(const GymEquipmentApp());
}

/// Phase 2 — Networking layer.
///
/// There is no real UI yet. This screen is a "smoke test": it calls the
/// repository (which goes through Dio + all interceptors) and shows the raw
/// result. Watch the debug console to see the LoggingInterceptor output.
class GymEquipmentApp extends StatelessWidget {
  const GymEquipmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Equipment Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const NetworkingSmokeTestScreen(),
    );
  }
}

class NetworkingSmokeTestScreen extends StatefulWidget {
  const NetworkingSmokeTestScreen({super.key});

  @override
  State<NetworkingSmokeTestScreen> createState() =>
      _NetworkingSmokeTestScreenState();
}

class _NetworkingSmokeTestScreenState
    extends State<NetworkingSmokeTestScreen> {
  final ExerciseRepository _repository = ExerciseRepository();

  bool _loading = false;
  String? _error;
  List<Exercise> _exercises = const [];

  Future<void> _runTest() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _repository.getRemoteExercises(limit: 10);
      if (!mounted) return;
      setState(() => _exercises = result);
    } catch (e) {
      final message = e is AppException ? e.message : e.toString();
      if (!mounted) return;
      setState(() => _error = message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gym Equipment Manager')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : _runTest,
        icon: const Icon(Icons.cloud_download),
        label: const Text('Fetch'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Error: $_error', textAlign: TextAlign.center),
        ),
      );
    }
    if (_exercises.isEmpty) {
      return const Center(
        child: Text('Tap "Fetch" to call the API through Dio.'),
      );
    }
    return ListView.builder(
      itemCount: _exercises.length,
      itemBuilder: (context, index) {
        final exercise = _exercises[index];
        return ListTile(
          leading: const Icon(Icons.fitness_center),
          title: Text(exercise.name),
          subtitle: Text('${exercise.bodyPart} • ${exercise.equipment}'),
        );
      },
    );
  }
}
