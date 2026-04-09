class WorkoutSession {
  int completedExercises = 0;
  int totalWorkSeconds = 0;
  List<int> exerciseTimes = [];
  
  void addWorkTime(int seconds) {
    totalWorkSeconds += seconds;
    completedExercises++;
    exerciseTimes.add(seconds);
  }
  
  int get currentCalories {
    return (totalWorkSeconds / 60 * 9).round();
  }
  
  double get averageWorkTime {
    if (exerciseTimes.isEmpty) return 0;
    return exerciseTimes.reduce((a, b) => a + b) / exerciseTimes.length;
  }
}