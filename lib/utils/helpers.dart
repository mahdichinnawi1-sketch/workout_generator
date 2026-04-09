import 'package:flutter/material.dart';

String getExerciseType(String exerciseName, String targetMuscle) {
  String name = exerciseName.toLowerCase();
  if (name.contains('jump') || name.contains('run') || name.contains('sprint') || 
      name.contains('rope') || name.contains('bike') || name.contains('row')) {
    return 'Cardio';
  } else if (name.contains('press') || name.contains('curl') || name.contains('deadlift') ||
             name.contains('pull') || name.contains('squat') || name.contains('lunge')) {
    return 'Strength';
  } else {
    return 'General';
  }
}