import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const WorkoutIntervalApp());
}

class WorkoutIntervalApp extends StatelessWidget {
  const WorkoutIntervalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pro Workout Generator',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF7C3AED),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF7C3AED),
          secondary: Color(0xFFF59E0B),
          surface: Colors.white,
          background: Color(0xFFF8FAFC),
          tertiary: Color(0xFF10B981),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF9B4DFF),
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF9B4DFF),
          secondary: Color(0xFFF59E0B),
          surface: Color(0xFF1E1E1E),
          background: Color(0xFF0F0F0F),
          tertiary: Color(0xFF10B981),
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}