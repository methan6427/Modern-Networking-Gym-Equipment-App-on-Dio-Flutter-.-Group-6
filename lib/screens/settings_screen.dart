import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

/// App settings. Currently hosts the dark-mode toggle (FR-10).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            subtitle: const Text('Use a dark colour scheme'),
            secondary: Icon(
              theme.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            value: theme.isDarkMode,
            onChanged: theme.toggleTheme,
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Gym Equipment Manager'),
            subtitle: Text('Modern networking with Dio • v1.0.0'),
          ),
        ],
      ),
    );
  }
}
