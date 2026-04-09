// lib/models/workout_plan.dart
class WorkoutPlan {
  final String goal;
  final String location;
  final int targetCalories;
  final int durationMinutes;
  final int workSeconds;
  final int restSeconds;
  final int estimatedCalories;
  final List<Exercise> exercises;
  final String intensity;

  WorkoutPlan({
    required this.goal,
    required this.location,
    required this.targetCalories,
    required this.durationMinutes,
    required this.workSeconds,
    required this.restSeconds,
    required this.estimatedCalories,
    required this.exercises,
    required this.intensity,
  });
}

class Exercise {
  final String name;
  final String icon;
  final String description;
  final String targetMuscle;
  final String location;
  final int caloriesPerMinute;

  Exercise({
    required this.name,
    required this.icon,
    required this.description,
    required this.targetMuscle,
    required this.location,
    required this.caloriesPerMinute,
  });
}