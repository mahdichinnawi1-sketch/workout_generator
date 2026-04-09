import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Update this import to match your app's name
import 'package:workout_interval_app/main.dart';  // Change this to your actual app name

void main() {
  testWidgets('Workout app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WorkoutIntervalApp());

    // Wait for splash screen to transition (2 seconds)
    await tester.pump(const Duration(seconds: 3));

    // Verify that the app loads and shows the main screen elements
    // Check for workout goal options
    expect(find.text('🔥 Weight Loss'), findsOneWidget);
    expect(find.text('⚡ Endurance'), findsOneWidget);
    expect(find.text('💪 Muscle Building'), findsOneWidget);
    
    // Verify that location selection exists
    expect(find.text('🏠 Home'), findsOneWidget);
    expect(find.text('🏋️ Gym'), findsOneWidget);
    
    // Verify the generate button exists
    expect(find.text('GENERATE WORKOUT'), findsOneWidget);
  });
}