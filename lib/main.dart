import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/exercise_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'themes/app_theme.dart';

void main() {
  runApp(const GymEquipmentApp());
}

/// Phase 4 — Full application.
///
/// Both providers are registered, [ThemeProvider] drives the theme, and the
/// real UI (HomeScreen and its sub-screens) is now wired in.
class GymEquipmentApp extends StatelessWidget {
  const GymEquipmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => ExerciseProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Gym Equipment Manager',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
