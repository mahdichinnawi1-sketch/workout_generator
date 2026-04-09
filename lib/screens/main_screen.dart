import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:workout_interval_app/utils/constants.dart';
import 'package:workout_interval_app/utils/workout_generator.dart';
import 'package:workout_interval_app/models/workout_plan.dart';  // ADD THIS LINE
import 'package:workout_interval_app/screens/workout_screen.dart';
import 'package:workout_interval_app/screens/weekly_schedule_screen.dart';
import 'package:workout_interval_app/widgets/glass_section.dart';
import 'package:workout_interval_app/widgets/custom_chip.dart';
import 'dart:ui';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedTab = 0;
  late PageController _pageController;
  
  String selectedGoal = '🔥 Weight Loss';
  String selectedLocation = '🏠 Home';
  int targetCalories = 300;
  int durationMinutes = 30;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void generateWorkout() {
    int calculatedDuration = WorkoutGenerator.calculateRequiredDuration(selectedGoal, selectedLocation, targetCalories);
    int finalDuration = max(durationMinutes, calculatedDuration);
    
    final config = WorkoutGenerator.getWorkoutConfig(selectedGoal, selectedLocation);
    
    final int workTime = config['work'] as int;
    final int restTime = config['rest'] as int;
    final String intensity = config['intensity'] as String;
    
    final exercises = WorkoutGenerator.getExercisesByGoal(selectedGoal, selectedLocation, finalDuration);
    final actualCalories = WorkoutGenerator.calculateActualCalories(selectedGoal, selectedLocation, finalDuration);
    
    final workoutPlan = WorkoutPlan(
      goal: selectedGoal,
      location: selectedLocation,
      targetCalories: targetCalories,
      durationMinutes: finalDuration,
      workSeconds: workTime,
      restSeconds: restTime,
      estimatedCalories: actualCalories,
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
    final recommendedDuration = WorkoutGenerator.calculateRequiredDuration(selectedGoal, selectedLocation, targetCalories);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          image: DecorationImage(
            image: const NetworkImage(
              'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=2070&auto=format&fit=crop',
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
          ),
        ),
        child: Column(
          children: [
            // Custom Tab Bar
            Container(
              margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  _buildTabButton(0, 'Generate', Icons.fitness_center),
                  _buildTabButton(1, 'Weekly Plan', Icons.calendar_today),
                ],
              ),
            ),
            
            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedTab = index;
                  });
                },
                children: [
                  // Generate Workout Tab
                  _buildGenerateWorkoutTab(recommendedDuration),
                  
                  // Weekly Schedule Tab
                  const WeeklyScheduleScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String title, IconData icon) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.white70),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenerateWorkoutTab(int recommendedDuration) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Header
            Center(
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, sin(_floatController.value * pi) * 5),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).primaryColor.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Text(
                            '🏋️',
                            style: TextStyle(fontSize: 54),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      'PRO WORKOUT',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Smart Workout Generator',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            GlassSection(
              title: 'WORKOUT GOAL',
              icon: Icons.bolt,
              child: CustomChipGrid(
                items: AppConstants.goals,
                selected: selectedGoal,
                onSelected: (value) {
                  setState(() {
                    selectedGoal = value;
                    HapticFeedback.lightImpact();
                  });
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            GlassSection(
              title: 'WORKOUT LOCATION',
              icon: Icons.location_on,
              child: Column(
                children: [
                  CustomChipGrid(
                    items: AppConstants.locations,
                    selected: selectedLocation,
                    onSelected: (value) {
                      setState(() {
                        selectedLocation = value;
                        HapticFeedback.lightImpact();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selectedLocation == '🏠 Home' 
                          ? Colors.green.withOpacity(0.2) 
                          : Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selectedLocation == '🏠 Home' 
                              ? Icons.home 
                              : Icons.fitness_center,
                          size: 16,
                          color: selectedLocation == '🏠 Home' 
                              ? Colors.green 
                              : Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selectedLocation == '🏠 Home' 
                                ? 'Bodyweight exercises, minimal equipment needed' 
                                : 'Full gym equipment, weights and machines available',
                            style: TextStyle(
                              fontSize: 11,
                              color: selectedLocation == '🏠 Home' 
                                  ? Colors.green[300] 
                                  : Colors.blue[300],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            GlassSection(
              title: 'TARGET CALORIES',
              icon: Icons.local_fire_department,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAnimatedButton(Icons.remove, () {
                          setState(() {
                            int currentIndex = AppConstants.calorieOptions.indexOf(targetCalories);
                            if (currentIndex > 0) {
                              targetCalories = AppConstants.calorieOptions[currentIndex - 1];
                              HapticFeedback.lightImpact();
                            }
                          });
                        }),
                        Column(
                          children: [
                            TweenAnimationBuilder(
                              duration: const Duration(milliseconds: 300),
                              tween: IntTween(begin: targetCalories, end: targetCalories),
                              builder: (context, value, child) {
                                return Text(
                                  '$value',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                    color: Colors.orange,
                                  ),
                                );
                              },
                            ),
                            Text(
                              'calories',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        _buildAnimatedButton(Icons.add, () {
                          setState(() {
                            int currentIndex = AppConstants.calorieOptions.indexOf(targetCalories);
                            if (currentIndex < AppConstants.calorieOptions.length - 1) {
                              targetCalories = AppConstants.calorieOptions[currentIndex + 1];
                              HapticFeedback.lightImpact();
                            }
                          });
                        }),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.timer, size: 16, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'To burn $targetCalories calories, you need ~$recommendedDuration minutes',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[300],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            GlassSection(
              title: 'MAX DURATION',
              icon: Icons.timer,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAnimatedButton(Icons.remove, () {
                      setState(() {
                        if (durationMinutes > 10) durationMinutes -= 5;
                        HapticFeedback.lightImpact();
                      });
                    }),
                    Column(
                      children: [
                        TweenAnimationBuilder(
                          duration: const Duration(milliseconds: 300),
                          tween: IntTween(begin: durationMinutes, end: durationMinutes),
                          builder: (context, value, child) {
                            return Text(
                              '$value',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                        Text(
                          'minutes max',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    _buildAnimatedButton(Icons.add, () {
                      setState(() {
                        if (durationMinutes < 90) durationMinutes += 5;
                        HapticFeedback.lightImpact();
                      });
                    }),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.3),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Workout Summary',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '• Goal: ${selectedGoal.replaceAll('🔥 ', '').replaceAll('⚡ ', '').replaceAll('💪 ', '')}\n'
                          '• Location: ${selectedLocation == '🏠 Home' ? 'Home Workout' : 'Gym Workout'}\n'
                          '• Target: $targetCalories calories\n'
                          '• Duration: ${max(durationMinutes, recommendedDuration)} min',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    generateWorkout();
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 48,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'GENERATE WORKOUT',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 28, color: Theme.of(context).primaryColor),
      ),
    );
  }
}