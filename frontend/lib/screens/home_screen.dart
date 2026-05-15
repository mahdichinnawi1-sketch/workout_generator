import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:async';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'workout_screen.dart';
import 'weekly_schedule_screen.dart';
import 'nutrition_screen_api.dart';
import 'ai_recommendation_screen.dart';

// WorkoutPlan class
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
  final int userId;

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
    required this.userId,
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedTab = 0;
  late PageController _pageController;
  int _userId = 0;
  String _username = '';
  
  final List<String> goals = ['🔥 Weight Loss', '⚡ Endurance', '💪 Muscle Building'];
  final List<String> locations = ['🏠 Home', '🏋️ Gym'];
  final List<int> calorieOptions = [100, 200, 300, 400, 500, 600, 800, 1000];
  
  String selectedGoal = '🔥 Weight Loss';
  String selectedLocation = '🏠 Home';
  int targetCalories = 300;
  int durationMinutes = 30;
  late AnimationController _floatController;
  
  // User physical data for nutrition
  int _userWeight = 70;
  int _userHeight = 170;
  int _userAge = 25;
  String _userGender = 'male';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _loadUserData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id') ?? 0;
      _username = prefs.getString('username') ?? 'User';
      _userWeight = prefs.getInt('user_weight') ?? 70;
      _userHeight = prefs.getInt('user_height') ?? 170;
      _userAge = prefs.getInt('user_age') ?? 25;
      _userGender = prefs.getString('user_gender') ?? 'male';
    });
    
    // Load user preferences from backend
    if (_userId > 0) {
      try {
        final userData = await ApiService.getUserProfile(_userId);
        if (!userData.containsKey('error')) {
          setState(() {
            if (userData['preferred_location'] == 'home') {
              selectedLocation = '🏠 Home';
            } else {
              selectedLocation = '🏋️ Gym';
            }
            targetCalories = userData['target_calories'] ?? 300;
          });
        }
      } catch (e) {
        print('Error loading preferences: $e');
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  int calculateRequiredDuration(String goal, String location, int targetCalories) {
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

  Map<String, dynamic> getWorkoutConfig(String goal, String location) {
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

  List<Exercise> getExercisesByGoal(String goal, String location, int durationMinutes) {
    List<Exercise> exercises = [];
    String baseGoal = goal.replaceAll('🔥 ', '').replaceAll('⚡ ', '').replaceAll('💪 ', '');
    
    Map<String, List<Map<String, dynamic>>> exerciseLibrary = {
      'Weight Loss': [
        {'name': 'Jumping Jacks', 'icon': '🤸', 'desc': 'Full body cardio', 'muscle': 'Full Body', 'location': 'home', 'calories': 10},
        {'name': 'Burpees', 'icon': '🏃‍♂️', 'desc': 'Explosive full body', 'muscle': 'Full Body', 'location': 'both', 'calories': 12},
        {'name': 'High Knees', 'icon': '🏃', 'desc': 'Cardio & core', 'muscle': 'Legs', 'location': 'home', 'calories': 9},
        {'name': 'Mountain Climbers', 'icon': '🧗', 'desc': 'Core & cardio', 'muscle': 'Core', 'location': 'home', 'calories': 10},
        {'name': 'Box Jumps', 'icon': '📦', 'desc': 'Plyometric power', 'muscle': 'Legs', 'location': 'gym', 'calories': 11},
        {'name': 'Battle Ropes', 'icon': '⚡', 'desc': 'Cardio & arms', 'muscle': 'Arms', 'location': 'gym', 'calories': 13},
      ],
      'Endurance': [
        {'name': 'Bodyweight Squats', 'icon': '🦵', 'desc': 'Leg endurance', 'muscle': 'Legs', 'location': 'home', 'calories': 7},
        {'name': 'Walking Lunges', 'icon': '🚶', 'desc': 'Balance & stamina', 'muscle': 'Legs', 'location': 'home', 'calories': 8},
        {'name': 'Push-ups', 'icon': '💪', 'desc': 'Upper body endurance', 'muscle': 'Chest', 'location': 'home', 'calories': 8},
        {'name': 'Plank Hold', 'icon': '⭐', 'desc': 'Core stability', 'muscle': 'Core', 'location': 'home', 'calories': 6},
        {'name': 'Treadmill Jog', 'icon': '🏃', 'desc': 'Cardio endurance', 'muscle': 'Full Body', 'location': 'gym', 'calories': 9},
        {'name': 'Stationary Bike', 'icon': '🚲', 'desc': 'Leg endurance', 'muscle': 'Legs', 'location': 'gym', 'calories': 9},
      ],
      'Muscle Building': [
        {'name': 'Push-ups', 'icon': '💪', 'desc': 'Chest & triceps', 'muscle': 'Chest', 'location': 'home', 'calories': 7},
        {'name': 'Squats', 'icon': '🦵', 'desc': 'Leg strength', 'muscle': 'Legs', 'location': 'home', 'calories': 7},
        {'name': 'Lunges', 'icon': '🚶', 'desc': 'Leg strength', 'muscle': 'Legs', 'location': 'home', 'calories': 7},
        {'name': 'Pull-ups', 'icon': '🔱', 'desc': 'Back & biceps', 'muscle': 'Back', 'location': 'gym', 'calories': 8},
        {'name': 'Bench Press', 'icon': '🏋️', 'desc': 'Chest strength', 'muscle': 'Chest', 'location': 'gym', 'calories': 7},
        {'name': 'Deadlift', 'icon': '🏋️', 'desc': 'Posterior chain', 'muscle': 'Back', 'location': 'gym', 'calories': 8},
      ],
    };
    
    List<Map<String, dynamic>>? tempExercises = exerciseLibrary[baseGoal];
    List<Map<String, dynamic>> allExercises = tempExercises ?? exerciseLibrary['Weight Loss']!;
    
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

  int calculateActualCalories(String goal, String location, int duration) {
    double intensityMultiplier;
    if (goal == '🔥 Weight Loss') intensityMultiplier = 9.5;
    else if (goal == '⚡ Endurance') intensityMultiplier = 8.0;
    else intensityMultiplier = 6.5;
    
    if (location == '🏋️ Gym') intensityMultiplier *= 1.2;
    
    return (duration * intensityMultiplier).round();
  }

  void generateWorkout() {
    int calculatedDuration = calculateRequiredDuration(selectedGoal, selectedLocation, targetCalories);
    int finalDuration = max(durationMinutes, calculatedDuration);
    
    final config = getWorkoutConfig(selectedGoal, selectedLocation);
    
    final int workTime = config['work'] as int;
    final int restTime = config['rest'] as int;
    final String intensity = config['intensity'] as String;
    
    final exercises = getExercisesByGoal(selectedGoal, selectedLocation, finalDuration);
    final actualCalories = calculateActualCalories(selectedGoal, selectedLocation, finalDuration);
    
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
      userId: _userId,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutScreen(workoutPlan: workoutPlan),
      ),
    );
  }

  void _openNutritionGuide() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NutritionScreenAPI(
          userGoal: selectedGoal,
          userId: _userId,
        ),
      ),
    );
  }

  void _openAIAssistant() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AIRecommendationScreen(userId: _userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recommendedDuration = calculateRequiredDuration(selectedGoal, selectedLocation, targetCalories);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('PRO WORKOUT'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              ).then((_) => _loadUserData());
            },
            icon: const Icon(Icons.person),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.red),
          ),
        ],
      ),
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
              margin: const EdgeInsets.symmetric(horizontal: 20),
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
            
            // Welcome Message
            Center(
              child: Text(
                'Welcome back, $_username! 👋',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
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
            
            _buildGlassSection(
              title: 'WORKOUT GOAL',
              icon: Icons.bolt,
              child: _buildChipGrid(goals, selectedGoal, (value) {
                setState(() {
                  selectedGoal = value;
                  HapticFeedback.lightImpact();
                });
              }),
            ),
            
            const SizedBox(height: 24),
            
            _buildGlassSection(
              title: 'WORKOUT LOCATION',
              icon: Icons.location_on,
              child: Column(
                children: [
                  _buildChipGrid(locations, selectedLocation, (value) {
                    setState(() {
                      selectedLocation = value;
                      HapticFeedback.lightImpact();
                    });
                  }),
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
            
            _buildGlassSection(
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
                            int currentIndex = calorieOptions.indexOf(targetCalories);
                            if (currentIndex > 0) {
                              targetCalories = calorieOptions[currentIndex - 1];
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
                            int currentIndex = calorieOptions.indexOf(targetCalories);
                            if (currentIndex < calorieOptions.length - 1) {
                              targetCalories = calorieOptions[currentIndex + 1];
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
            
            _buildGlassSection(
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
            
            // Generate Workout Button
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
            
            const SizedBox(height: 24),
            
            // Professional Square Buttons Row
            Row(
              children: [
                // Nutrition Guide Button (Square)
                Expanded(
                  child: GestureDetector(
                    onTap: _openNutritionGuide,
                    child: Container(
                      height: 130,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.green.shade600,
                            Colors.green.shade900,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.shade900.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.restaurant,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'NUTRITION',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Guide & Tracking',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // AI Assistant Button (Square)
                Expanded(
                  child: GestureDetector(
                    onTap: _openAIAssistant,
                    child: Container(
                      height: 130,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.purple.shade600,
                            Colors.purple.shade900,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.shade900.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'AI ASSISTANT',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Smart Workouts',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassSection({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChipGrid(List<String> items, String selected, Function(String) onSelected) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) {
        bool isSelected = selected == item;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: FilterChip(
            selected: isSelected,
            label: Text(item),
            onSelected: (selected) {
              if (selected) onSelected(item);
            },
            backgroundColor: Colors.grey[800],
            selectedColor: Theme.of(context).primaryColor.withOpacity(0.3),
            checkmarkColor: Theme.of(context).primaryColor,
            labelStyle: TextStyle(
              color: isSelected ? Theme.of(context).primaryColor : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            shape: StadiumBorder(
              side: BorderSide(
                color: isSelected ? Theme.of(context).primaryColor : Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
          ),
        );
      }).toList(),
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