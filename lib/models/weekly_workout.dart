class WeeklyWorkout {
  final String day;
  String workoutType;
  bool isRestDay;
  bool isCompleted;

  WeeklyWorkout({
    required this.day,
    required this.workoutType,
    required this.isRestDay,
    this.isCompleted = false,
  });
}