import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/exercise_provider.dart';
import '../widgets/error_retry.dart';
import '../widgets/exercise_card.dart';
import '../widgets/loading_shimmer.dart';
import 'add_screen.dart';
import 'detail_screen.dart';
import 'settings_screen.dart';

/// The main screen: searchable, refreshable list of all exercises.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExerciseProvider>().loadExercises();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Equipment Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: Column(
        children: [
          _SearchBar(controller: _searchController),
          Expanded(
            child: Consumer<ExerciseProvider>(
              builder: (context, provider, _) => _buildContent(provider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ExerciseProvider provider) {
    if (provider.isLoading && provider.exercises.isEmpty) {
      return const LoadingShimmer();
    }

    if (provider.hasError && provider.exercises.isEmpty) {
      return ErrorRetry(
        message: provider.errorMessage ?? 'Unknown error',
        onRetry: provider.refresh,
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: provider.isEmpty
          ? _EmptyState(hasQuery: provider.query.isNotEmpty)
          : ListView.builder(
              itemCount: provider.exercises.length,
              itemBuilder: (context, index) {
                final exercise = provider.exercises[index];
                return ExerciseCard(
                  exercise: exercise,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(exercise: exercise),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    // Watch the query so the clear button shows/hides reactively.
    final hasQuery =
        context.select<ExerciseProvider, bool>((p) => p.query.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search exercises...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: !hasQuery
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    context.read<ExerciseProvider>().search('');
                  },
                ),
        ),
        onChanged: (value) =>
            context.read<ExerciseProvider>().search(value),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasQuery});

  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    // Wrapped in a scrollable so pull-to-refresh still works when empty.
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Icon(
          hasQuery ? Icons.search_off : Icons.fitness_center,
          size: 64,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            hasQuery
                ? 'No exercises match your search.'
                : 'No exercises yet. Pull to refresh or add one.',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
