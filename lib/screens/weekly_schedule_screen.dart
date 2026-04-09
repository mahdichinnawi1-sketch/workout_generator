import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';  // ADD THIS LINE for max() function
import 'package:workout_interval_app/models/weekly_workout.dart';
import 'package:workout_interval_app/models/workout_plan.dart';
import 'package:workout_interval_app/utils/constants.dart';
import 'package:workout_interval_app/utils/workout_generator.dart';
import 'package:workout_interval_app/screens/workout_screen.dart';
import 'dart:async';

class WeeklyScheduleScreen extends StatefulWidget {
  const WeeklyScheduleScreen({super.key});

  @override
  State<WeeklyScheduleScreen> createState() => _WeeklyScheduleScreenState();
}

class _WeeklyScheduleScreenState extends State<WeeklyScheduleScreen> {
  List<WeeklyWorkout> weeklySchedule = [];
  String selectedWorkoutType = '🔥 Weight Loss';
  String selectedLocation = '🏠 Home';
  int targetCalories = 300;
  bool isGenerating = false;

  @override
  void initState() {
    super.initState();
    _initializeEmptySchedule();
  }

  void _initializeEmptySchedule() {
    weeklySchedule = [];
    for (var day in AppConstants.days) {
      weeklySchedule.add(WeeklyWorkout(
        day: day,
        workoutType: '🔥 Weight Loss',
        isRestDay: day == 'Sunday',
      ));
    }
  }

  void generateWeeklyPlan() {
    setState(() {
      isGenerating = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        for (int i = 0; i < AppConstants.days.length; i++) {
          String workoutType;
          
          if (selectedWorkoutType == '🔥 Weight Loss') {
            if (i % 3 == 0) {
              workoutType = '🔥 Weight Loss';
            } else if (i % 3 == 1) {
              workoutType = '⚡ Endurance';
            } else {
              workoutType = '💪 Muscle Building';
            }
          } else if (selectedWorkoutType == '⚡ Endurance') {
            if (i % 3 == 0) {
              workoutType = '⚡ Endurance';
            } else if (i % 3 == 1) {
              workoutType = '🔥 Weight Loss';
            } else {
              workoutType = '💪 Muscle Building';
            }
          } else {
            if (i % 3 == 0) {
              workoutType = '💪 Muscle Building';
            } else if (i % 3 == 1) {
              workoutType = '🔥 Weight Loss';
            } else {
              workoutType = '⚡ Endurance';
            }
          }
          
          bool isRestDay = (i == 2 || i == 6);
          
          weeklySchedule[i] = WeeklyWorkout(
            day: AppConstants.days[i],
            workoutType: workoutType,
            isRestDay: isRestDay,
            isCompleted: false,
          );
        }
        isGenerating = false;
        HapticFeedback.mediumImpact();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Weekly workout plan generated!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      });
    });
  }

  void updateWorkoutForDay(int index, String workoutType) {
    setState(() {
      weeklySchedule[index].workoutType = workoutType;
    });
  }

  void toggleRestDay(int index) {
    setState(() {
      weeklySchedule[index].isRestDay = !weeklySchedule[index].isRestDay;
    });
  }

  void markAsCompleted(int index) {
    setState(() {
      weeklySchedule[index].isCompleted = !weeklySchedule[index].isCompleted;
    });
    HapticFeedback.lightImpact();
  }

  void resetWeeklyPlan() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Weekly Plan'),
        content: const Text('Are you sure you want to reset all progress?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              _initializeEmptySchedule();
              Navigator.pop(context);
              HapticFeedback.lightImpact();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }

  void startWorkoutFromDay(int index, String selectedLocationParam) {
    final schedule = weeklySchedule[index];
    final goal = schedule.workoutType;
    
    double caloriesPerMinute;
    if (goal == '🔥 Weight Loss') {
      caloriesPerMinute = 9.5;
    } else if (goal == '⚡ Endurance') {
      caloriesPerMinute = 8.0;
    } else {
      caloriesPerMinute = 6.5;
    }
    
    int calculatedDuration = (targetCalories / caloriesPerMinute).ceil().clamp(10, 90);
    int finalDuration = max(30, calculatedDuration);
    
    int workSec = 40;
    int restSec = 20;
    String intensity = 'High';
    
    if (goal == '🔥 Weight Loss') {
      workSec = 45;
      restSec = 15;
    } else if (goal == '⚡ Endurance') {
      workSec = 60;
      restSec = 15;
    } else if (goal == '💪 Muscle Building') {
      workSec = 35;
      restSec = 45;
    }
    
    List<Exercise> exercises = WorkoutGenerator.getExercisesByGoal(goal, selectedLocationParam, finalDuration);
    
    final workoutPlan = WorkoutPlan(
      goal: goal,
      location: selectedLocationParam,
      targetCalories: targetCalories,
      durationMinutes: finalDuration,
      workSeconds: workSec,
      restSeconds: restSec,
      estimatedCalories: (finalDuration * caloriesPerMinute).round(),
      exercises: exercises,
      intensity: intensity,
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutScreen(workoutPlan: workoutPlan),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = weeklySchedule.where((w) => !w.isRestDay && w.isCompleted).length;
    final totalWorkouts = weeklySchedule.where((w) => !w.isRestDay).length;
    final progressPercent = totalWorkouts > 0 ? (completedCount / totalWorkouts) : 0.0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '📅',
                    style: TextStyle(fontSize: 40),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'WEEKLY WORKOUT PLAN',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Plan your fitness journey for the week',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Generation Controls Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.2),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⚡ GENERATE WEEKLY PLAN',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                
                const Text(
                  'Focus Area:',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: AppConstants.workoutTypes.map((type) {
                    bool isSelected = selectedWorkoutType == type;
                    return FilterChip(
                      selected: isSelected,
                      label: Text(type, style: const TextStyle(fontSize: 12)),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            selectedWorkoutType = type;
                            HapticFeedback.lightImpact();
                          });
                        }
                      },
                      backgroundColor: Colors.grey[800],
                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.3),
                      labelStyle: TextStyle(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.white70,
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 12),
                
                const Text(
                  'Workout Location:',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: AppConstants.locations.map((location) {
                    bool isSelected = selectedLocation == location;
                    return FilterChip(
                      selected: isSelected,
                      label: Text(location, style: const TextStyle(fontSize: 12)),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            selectedLocation = location;
                            HapticFeedback.lightImpact();
                          });
                        }
                      },
                      backgroundColor: Colors.grey[800],
                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.3),
                      labelStyle: TextStyle(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.white70,
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isGenerating ? null : generateWeeklyPlan,
                        icon: isGenerating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(isGenerating ? 'GENERATING...' : 'GENERATE WEEKLY PLAN'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: resetWeeklyPlan,
                      icon: const Icon(Icons.refresh, color: Colors.red),
                      tooltip: 'Reset Plan',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Legend
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem('Rest Day', Colors.red),
                _buildLegendItem('Completed', Colors.green),
                _buildLegendItem('Pending', Colors.blue),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Weekly Progress
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Weekly Progress',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '$completedCount/$totalWorkouts workouts done',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[300],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressPercent,
                    backgroundColor: Colors.grey[800],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Weekly Schedule List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: AppConstants.days.length,
            itemBuilder: (context, index) {
              final schedule = weeklySchedule[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: schedule.isCompleted 
                      ? Colors.green.withOpacity(0.2)
                      : Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: schedule.isRestDay 
                        ? Colors.red.withOpacity(0.5)
                        : schedule.isCompleted
                            ? Colors.green.withOpacity(0.5)
                            : Theme.of(context).primaryColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: ExpansionTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: schedule.isRestDay 
                          ? Colors.red.withOpacity(0.2)
                          : schedule.isCompleted
                              ? Colors.green.withOpacity(0.2)
                              : Theme.of(context).primaryColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        schedule.day.substring(0, 3),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: schedule.isRestDay 
                              ? Colors.red
                              : schedule.isCompleted
                                  ? Colors.green
                                  : Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    schedule.day,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      decoration: schedule.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(
                    schedule.isRestDay 
                        ? 'Rest Day - Take a break! 🧘'
                        : 'Workout: ${schedule.workoutType.replaceAll('🔥 ', '').replaceAll('⚡ ', '').replaceAll('💪 ', '')}',
                    style: TextStyle(
                      color: schedule.isRestDay ? Colors.red : Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!schedule.isRestDay && !schedule.isCompleted)
                        IconButton(
                          onPressed: () => markAsCompleted(index),
                          icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                          tooltip: 'Mark as Completed',
                        ),
                      if (schedule.isCompleted)
                        const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Rest Day:',
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(width: 12),
                              Switch(
                                value: schedule.isRestDay,
                                onChanged: (value) => toggleRestDay(index),
                                activeColor: Colors.red,
                              ),
                              if (schedule.isRestDay)
                                const Text(
                                  'Take a break!',
                                  style: TextStyle(color: Colors.red, fontSize: 12),
                                ),
                            ],
                          ),
                          
                          if (!schedule.isRestDay) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'Select Workout Type:',
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: AppConstants.workoutTypes.map((type) {
                                bool isSelected = schedule.workoutType == type;
                                return FilterChip(
                                  selected: isSelected,
                                  label: Text(
                                    type,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      updateWorkoutForDay(index, type);
                                      HapticFeedback.lightImpact();
                                    }
                                  },
                                  backgroundColor: Colors.grey[800],
                                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.3),
                                  labelStyle: TextStyle(
                                    color: isSelected ? Theme.of(context).primaryColor : Colors.white70,
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => startWorkoutFromDay(index, selectedLocation),
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('START WORKOUT'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 16),
                          
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.lightbulb, size: 16, color: Colors.blue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    schedule.isRestDay
                                        ? 'Rest days are important for muscle recovery and growth!'
                                        : '💡 Tip: Stay hydrated and warm up before starting your workout!',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue[300],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Weekly Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.3),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'Weekly Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      '$completedCount',
                      'Completed',
                      Colors.green,
                    ),
                    _buildSummaryItem(
                      '${totalWorkouts - completedCount}',
                      'Pending',
                      Colors.orange,
                    ),
                    _buildSummaryItem(
                      '${weeklySchedule.where((w) => w.isRestDay).length}',
                      'Rest Days',
                      Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressPercent,
                    backgroundColor: Colors.grey[800],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progressPercent * 100).round()}% Weekly Progress',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}