class WorkoutSession {
  final int id;
  final DateTime workoutDate;
  final int durationMinutes;
  final int totalCalories;
  final String goalType;
  final String location;

  WorkoutSession({
    required this.id,
    required this.workoutDate,
    required this.durationMinutes,
    required this.totalCalories,
    required this.goalType,
    required this.location,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'],
      workoutDate: DateTime.parse(json['workout_date']),
      durationMinutes: json['duration_minutes'],
      totalCalories: json['total_calories'],
      goalType: json['goal_type'],
      location: json['location'],
    );
  }
}

class WorkoutStats {
  final int totalWorkouts;
  final int totalCalories;
  final int totalMinutes;
  final int workoutsThisWeek;

  WorkoutStats({
    required this.totalWorkouts,
    required this.totalCalories,
    required this.totalMinutes,
    required this.workoutsThisWeek,
  });

  factory WorkoutStats.fromJson(Map<String, dynamic> json) {
    return WorkoutStats(
      totalWorkouts: json['total_workouts'] ?? 0,
      totalCalories: json['total_calories'] ?? 0,
      totalMinutes: json['total_minutes'] ?? 0,
      workoutsThisWeek: json['workouts_this_week'] ?? 0,
    );
  }
}