import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

// ==================== LOCAL CLASSES ====================

class WorkoutSessionLocal {
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

class AnimatedExerciseIcon extends StatefulWidget {
  final String icon;
  final String exerciseType;
  final bool isActive;
  final double size;

  const AnimatedExerciseIcon({
    super.key,
    required this.icon,
    required this.exerciseType,
    required this.isActive,
    this.size = 40,
  });

  @override
  State<AnimatedExerciseIcon> createState() => _AnimatedExerciseIconState();
}

class _AnimatedExerciseIconState extends State<AnimatedExerciseIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _bounceAnimation = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedExerciseIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget animatedIcon;

    if (widget.exerciseType.contains('Cardio') || 
        widget.icon == '🏃' || widget.icon == '🏃‍♂️' || 
        widget.icon == '🚣' || widget.icon == '🚲') {
      animatedIcon = AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: widget.isActive ? _rotationAnimation.value : 0,
            child: child,
          );
        },
        child: Text(widget.icon, style: TextStyle(fontSize: widget.size)),
      );
    } 
    else if (widget.exerciseType.contains('Strength') || 
             widget.icon == '💪' || widget.icon == '🏋️' || 
             widget.icon == '🔱') {
      animatedIcon = AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, widget.isActive ? _bounceAnimation.value : 0),
            child: Transform.scale(
              scale: widget.isActive ? _scaleAnimation.value : 1.0,
              child: child,
            ),
          );
        },
        child: Text(widget.icon, style: TextStyle(fontSize: widget.size)),
      );
    }
    else {
      animatedIcon = AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isActive ? _scaleAnimation.value : 1.0,
            child: child,
          );
        },
        child: Text(widget.icon, style: TextStyle(fontSize: widget.size)),
      );
    }

    return animatedIcon;
  }
}

// WorkoutPlan class
class WorkoutPlanLocal {
  final dynamic goal;
  final String location;
  final int targetCalories;
  final int durationMinutes;
  final int workSeconds;
  final int restSeconds;
  final int estimatedCalories;
  final List<dynamic> exercises;
  final String intensity;
  final int userId;

  WorkoutPlanLocal({
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

// ==================== WORKOUT SCREEN ====================

class WorkoutScreen extends StatefulWidget {
  final dynamic workoutPlan;

  const WorkoutScreen({super.key, required this.workoutPlan});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> with TickerProviderStateMixin {
  late Timer _timer;
  WorkoutSessionLocal session = WorkoutSessionLocal();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  int currentExerciseIndex = 0;
  int timeRemaining = 0;
  int restTimeRemaining = 0;
  bool isActive = false;
  bool isPaused = false;
  bool isResting = false;
  
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> exerciseList = [];

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

  @override
  void initState() {
    super.initState();
    
    final exercisesList = widget.workoutPlan.exercises as List<dynamic>;
    for (var exercise in exercisesList) {
      for (int i = 0; i < 3; i++) {
        exerciseList.add({
          'name': exercise.name,
          'reps': 'x12',
          'icon': exercise.icon,
          'targetMuscle': exercise.targetMuscle,
          'location': exercise.location,
          'description': exercise.description,
          'caloriesPerMinute': exercise.caloriesPerMinute,
          'exerciseType': getExerciseType(exercise.name, exercise.targetMuscle),
        });
      }
    }
    
    timeRemaining = widget.workoutPlan.workSeconds;
    restTimeRemaining = 60;
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void startTimer() {
    if (isActive) return;
    
    setState(() {
      isActive = true;
      isPaused = false;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isPaused) return;
      
      setState(() {
        if (!isResting) {
          if (timeRemaining > 0) {
            timeRemaining--;
            session.addWorkTime(1);
            
            if (timeRemaining <= 3 && timeRemaining > 0) {
              HapticFeedback.lightImpact();
            }
          } else {
            if (currentExerciseIndex < exerciseList.length - 1) {
              _startRestPeriod();
            } else {
              _completeWorkout();
            }
          }
        } else {
          if (restTimeRemaining > 0) {
            restTimeRemaining--;
          } else {
            _skipRest();
          }
        }
      });
    });
  }
  
  void _startRestPeriod() {
    setState(() {
      isResting = true;
      restTimeRemaining = 60;
    });
    HapticFeedback.mediumImpact();
  }
  
  void _skipRest() {
    setState(() {
      isResting = false;
      currentExerciseIndex++;
      timeRemaining = widget.workoutPlan.workSeconds;
      restTimeRemaining = 60;
    });
    
    _scrollToCurrentExercise();
    HapticFeedback.lightImpact();
  }
  
  void _scrollToCurrentExercise() {
    if (_scrollController.hasClients) {
      final double position = currentExerciseIndex * 70.0;
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void scrollUp() {
    if (currentExerciseIndex > 0) {
      setState(() {
        currentExerciseIndex--;
        timeRemaining = widget.workoutPlan.workSeconds;
      });
      _scrollToCurrentExercise();
      HapticFeedback.lightImpact();
    }
  }
  
  void scrollDown() {
    if (currentExerciseIndex < exerciseList.length - 1) {
      setState(() {
        currentExerciseIndex++;
        timeRemaining = widget.workoutPlan.workSeconds;
      });
      _scrollToCurrentExercise();
      HapticFeedback.lightImpact();
    }
  }
  
  void pauseTimer() {
    setState(() {
      isPaused = true;
    });
  }
  
  void resumeTimer() {
    setState(() {
      isPaused = false;
    });
  }
  
  void stopTimer() {
    _timer.cancel();
    setState(() {
      isActive = false;
      isPaused = false;
      isResting = false;
    });
  }
  
  void _completeWorkout() {
    _timer.cancel();
    setState(() {
      isActive = false;
    });
    
    bool metCalorieGoal = session.currentCalories >= (widget.workoutPlan.targetCalories ?? 300);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(metCalorieGoal ? Icons.emoji_events : Icons.fitness_center, 
                 color: metCalorieGoal ? Colors.amber : Colors.blue, size: 32),
            const SizedBox(width: 12),
            Text(
              metCalorieGoal ? 'Goal Achieved!' : 'Workout Complete!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              metCalorieGoal ? '🏆 You crushed your calorie goal! 🏆' : '🏋️ Great workout! 🏋️',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.withOpacity(0.1), Colors.blue.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildStatRow('Calories Burned', '${session.currentCalories} / ${widget.workoutPlan.targetCalories} kcal'),
                  const Divider(),
                  _buildStatRow('Exercises Completed', '${currentExerciseIndex + 1}/${exerciseList.length}'),
                  const Divider(),
                  _buildStatRow('Total Work Time', '${session.totalWorkSeconds ~/ 60}:${(session.totalWorkSeconds % 60).toString().padLeft(2, '0')}'),
                  const Divider(),
                  _buildStatRow('Location', widget.workoutPlan.location == '🏠 Home' ? 'Home' : 'Gym'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('FINISH', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                currentExerciseIndex = 0;
                timeRemaining = widget.workoutPlan.workSeconds;
                session = WorkoutSessionLocal();
                isResting = false;
              });
              startTimer();
            },
            child: const Text('RESTART'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (_timer.isActive) _timer.cancel();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (exerciseList.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text('No exercises available', style: TextStyle(color: Colors.white)),
        ),
      );
    }
    
    final currentExercise = exerciseList[currentExerciseIndex];
    final progress = (currentExerciseIndex / exerciseList.length).clamp(0.0, 1.0);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      if (isActive) {
                        stopTimer();
                      }
                      Navigator.pop(context);
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  
                  // Timer Display
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isActive ? _pulseAnimation.value : 1.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isActive 
                                  ? [Colors.green.shade800, Colors.green.shade600]
                                  : isResting
                                      ? [Colors.orange.shade800, Colors.orange.shade600]
                                      : [Colors.grey[900]!, Colors.grey[800]!],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: isActive || isResting
                                ? [
                                    BoxShadow(
                                      color: isResting ? Colors.orange.withOpacity(0.3) : Colors.green.withOpacity(0.3),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : null,
                          ),
                          child: Text(
                            isResting 
                                ? 'REST: ${(restTimeRemaining ~/ 60).toString().padLeft(2, '0')}:${(restTimeRemaining % 60).toString().padLeft(2, '0')}'
                                : '${(timeRemaining ~/ 60).toString().padLeft(2, '0')}:${(timeRemaining % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  IconButton(
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => _buildStatsSheet(),
                    ),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bar_chart, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            
            // Progress Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '🔥 Calories: ${session.currentCalories}/${widget.workoutPlan.targetCalories}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${(progress * 100).round()}%',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue[300],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.green.shade400,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Main Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.grey[800]!,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with workout info and scroll buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).primaryColor,
                                    Theme.of(context).primaryColor.withOpacity(0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.workoutPlan.goal.toString(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.location_on, size: 10, color: Colors.grey[400]),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.workoutPlan.location == '🏠 Home' ? 'Home' : 'Gym',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Scroll Buttons
                        Row(
                          children: [
                            _buildScrollButton(Icons.arrow_upward, scrollUp),
                            const SizedBox(width: 8),
                            _buildScrollButton(Icons.arrow_downward, scrollDown),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Rest Period Display (if active)
                    if (isResting)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange.withOpacity(0.2), Colors.deepOrange.withOpacity(0.2)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.bedtime, color: Colors.orange, size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'REST TIME',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Take a break! Next exercise starts in ${restTimeRemaining}s',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _skipRest,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text('SKIP REST'),
                            ),
                          ],
                        ),
                      ),
                    
                    // Current Exercise Highlight
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isActive && !isResting
                              ? [Colors.blue.withOpacity(0.3), Colors.purple.withOpacity(0.3)]
                              : [Colors.grey[800]!.withOpacity(0.5), Colors.grey[800]!.withOpacity(0.3)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive && !isResting ? Colors.blue : Colors.grey[700]!,
                          width: isActive && !isResting ? 2 : 1,
                        ),
                        boxShadow: isActive && !isResting
                            ? [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          AnimatedExerciseIcon(
                            icon: currentExercise['icon'],
                            exerciseType: currentExercise['exerciseType'],
                            isActive: isActive && !isResting,
                            size: 48,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CURRENT EXERCISE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentExercise['name'].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        currentExercise['exerciseType'],
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.blue[300],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(Icons.fitness_center, size: 12, color: Colors.grey[500]),
                                    const SizedBox(width: 4),
                                    Text(
                                      currentExercise['targetMuscle'],
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(Icons.local_fire_department, size: 12, color: Colors.grey[500]),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${currentExercise['caloriesPerMinute']} cal/min',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          TweenAnimationBuilder(
                            duration: const Duration(milliseconds: 300),
                            tween: IntTween(begin: 0, end: 12),
                            builder: (context, value, child) {
                              return Column(
                                children: [
                                  Text(
                                    'x$value',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: isActive && !isResting ? Colors.blue : Colors.grey[500],
                                    ),
                                  ),
                                  Text(
                                    'reps',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Exercise List Title
                    Row(
                      children: [
                        const Icon(Icons.list, size: 14, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'EXERCISE LIST',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            letterSpacing: 1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${currentExerciseIndex + 1}/${exerciseList.length}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue[300],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Exercise List with ScrollController
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: exerciseList.length,
                        itemBuilder: (context, index) {
                          final exercise = exerciseList[index];
                          final isCurrent = index == currentExerciseIndex;
                          final isCompleted = index < currentExerciseIndex;
                          
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isCurrent 
                                  ? Colors.blue.withOpacity(0.15)
                                  : isCompleted
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCurrent 
                                    ? Colors.blue
                                    : isCompleted
                                        ? Colors.green.withOpacity(0.3)
                                        : Colors.grey[800]!,
                                width: isCurrent ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    AnimatedExerciseIcon(
                                      icon: exercise['icon'],
                                      exerciseType: exercise['exerciseType'],
                                      isActive: isCurrent && isActive && !isResting,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exercise['name'].toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                            color: isCompleted 
                                                ? Colors.green
                                                : isCurrent
                                                    ? Colors.blue
                                                    : Colors.white,
                                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.fitness_center, size: 10, color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              exercise['targetMuscle'],
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (isCompleted)
                                  const Icon(Icons.check_circle, color: Colors.green, size: 18)
                                else if (isCurrent && isActive && !isResting)
                                  AnimatedBuilder(
                                    animation: _pulseAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _pulseAnimation.value,
                                        child: const Icon(Icons.play_circle, color: Colors.blue, size: 20),
                                      );
                                    },
                                  )
                                else
                                  Text(
                                    exercise['reps'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isCurrent ? Colors.blue : Colors.grey[500],
                                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Control Buttons
                    if (!isActive)
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 500),
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: startTimer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 5,
                                ),
                                child: const Text(
                                  'START WORKOUT',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isPaused ? resumeTimer : pauseTimer,
                              icon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  isPaused ? Icons.play_arrow : Icons.pause,
                                  key: ValueKey(isPaused),
                                  size: 20,
                                ),
                              ),
                              label: Text(isPaused ? 'RESUME' : 'PAUSE'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: Colors.grey[700]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: stopTimer,
                              icon: const Icon(Icons.stop, size: 20),
                              label: const Text('STOP'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildScrollButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.blue, size: 18),
      ),
    );
  }
  
  Widget _buildStatsSheet() {
    final progress = (currentExerciseIndex / exerciseList.length).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Workout Statistics',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildStatRow('Calories Burned', '${session.currentCalories} / ${widget.workoutPlan.targetCalories} kcal'),
          const Divider(),
          _buildStatRow('Exercises Completed', '$currentExerciseIndex/${exerciseList.length}'),
          const Divider(),
          _buildStatRow('Total Work Time', '${session.totalWorkSeconds ~/ 60}:${(session.totalWorkSeconds % 60).toString().padLeft(2, '0')}'),
          const Divider(),
          _buildStatRow('Current Exercise', exerciseList[currentExerciseIndex]['name'].toUpperCase()),
          const Divider(),
          _buildStatRow('Exercise Type', exerciseList[currentExerciseIndex]['exerciseType']),
          const Divider(),
          _buildStatRow('Target Muscle', exerciseList[currentExerciseIndex]['targetMuscle']),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(progress * 100).round()}% Complete',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}