import 'package:workout_interval_app/models/workout_plan.dart';
import 'package:workout_interval_app/utils/constants.dart';
import 'dart:math';

class WorkoutGenerator {
  static int calculateRequiredDuration(String goal, String location, int targetCalories) {
    double caloriesPerMinute;
    
    if (goal == '🔥 Weight Loss') {
      caloriesPerMinute = 9.5;
    } else if (goal == '⚡ Endurance') {
      caloriesPerMinute = 8.0;
    } else {
      caloriesPerMinute = 6.5;
    }
    
    if (location == '🏋️ Gym') {
      caloriesPerMinute *= 1.2;
    }
    
    int requiredMinutes = (targetCalories / caloriesPerMinute).ceil();
    return requiredMinutes.clamp(10, 90);
  }

  static Map<String, dynamic> getWorkoutConfig(String goal, String location) {
    int workSec = 40;
    int restSec = 20;
    String intensity = 'High';
    
    if (goal == '🔥 Weight Loss') {
      workSec = 45;
      restSec = 15;
      intensity = 'High';
    } else if (goal == '⚡ Endurance') {
      workSec = 60;
      restSec = 15;
      intensity = 'Moderate';
    } else if (goal == '💪 Muscle Building') {
      workSec = 35;
      restSec = 45;
      intensity = 'High';
    }
    
    if (location == '🏋️ Gym') {
      workSec = (workSec * 1.1).round();
    }
    
    workSec = workSec.clamp(20, 90);
    restSec = restSec.clamp(10, 60);
    
    return {
      'work': workSec,
      'rest': restSec,
      'intensity': intensity,
    };
  }

  static List<Exercise> getExercisesByGoal(String goal, String location, int durationMinutes) {
    List<Exercise> exercises = [];
    String baseGoal = goal.replaceAll('🔥 ', '').replaceAll('⚡ ', '').replaceAll('💪 ', '');
    
    List<Map<String, dynamic>>? tempExercises = ExerciseLibrary.exerciseLibrary[baseGoal];
    List<Map<String, dynamic>> allExercises = tempExercises ?? ExerciseLibrary.exerciseLibrary['Weight Loss']!;
    
    List<Map<String, dynamic>> filteredExercises = allExercises.where((ex) {
      if (location == '🏠 Home') {
        return ex['location'] == 'home' || ex['location'] == 'both';
      } else {
        return ex['location'] == 'gym' || ex['location'] == 'both';
      }
    }).toList();
    
    int exerciseCount = (durationMinutes / 5).ceil().clamp(4, 12);
    
    for (int i = 0; i < exerciseCount; i++) {
      var ex = filteredExercises[i % filteredExercises.length];
      exercises.add(Exercise(
        name: ex['name']!,
        icon: ex['icon']!,
        description: ex['desc']!,
        targetMuscle: ex['muscle']!,
        location: ex['location']!,
        caloriesPerMinute: ex['calories']!,
      ));
    }
    
    return exercises;
  }

  static int calculateActualCalories(String goal, String location, int duration) {
    double intensityMultiplier;
    if (goal == '🔥 Weight Loss') intensityMultiplier = 9.5;
    else if (goal == '⚡ Endurance') intensityMultiplier = 8.0;
    else intensityMultiplier = 6.5;
    
    if (location == '🏋️ Gym') intensityMultiplier *= 1.2;
    
    return (duration * intensityMultiplier).round();
  }
}