import 'package:flutter/material.dart';
import 'package:workout_interval_app/theme/app_theme.dart';
import 'package:workout_interval_app/screens/splash_screen.dart';

void main() {
  runApp(const WorkoutIntervalApp());
}

class WorkoutIntervalApp extends StatelessWidget {
  const WorkoutIntervalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pro Workout Generator',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}