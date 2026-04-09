class AppConstants {
  static final List<String> goals = ['🔥 Weight Loss', '⚡ Endurance', '💪 Muscle Building'];
  static final List<String> locations = ['🏠 Home', '🏋️ Gym'];
  static final List<int> calorieOptions = [100, 200, 300, 400, 500, 600, 800, 1000];
  static final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  static final List<String> workoutTypes = ['🔥 Weight Loss', '⚡ Endurance', '💪 Muscle Building'];
}

class ExerciseLibrary {
  static final Map<String, List<Map<String, dynamic>>> exerciseLibrary = {
    'Weight Loss': [
      {'name': 'Jumping Jacks', 'icon': '🤸', 'desc': 'Full body cardio', 'muscle': 'Full Body', 'location': 'home', 'calories': 10},
      {'name': 'Burpees', 'icon': '🏃‍♂️', 'desc': 'Explosive full body', 'muscle': 'Full Body', 'location': 'both', 'calories': 12},
      {'name': 'High Knees', 'icon': '🏃', 'desc': 'Cardio & core', 'muscle': 'Legs', 'location': 'home', 'calories': 9},
      {'name': 'Mountain Climbers', 'icon': '🧗', 'desc': 'Core & cardio', 'muscle': 'Core', 'location': 'home', 'calories': 10},
      {'name': 'Box Jumps', 'icon': '📦', 'desc': 'Plyometric power', 'muscle': 'Legs', 'location': 'gym', 'calories': 11},
      {'name': 'Battle Ropes', 'icon': '⚡', 'desc': 'Cardio & arms', 'muscle': 'Arms', 'location': 'gym', 'calories': 13},
      {'name': 'Kettlebell Swings', 'icon': '🏋️', 'desc': 'Hip drive', 'muscle': 'Glutes', 'location': 'gym', 'calories': 11},
      {'name': 'Rowing Machine', 'icon': '🚣', 'desc': 'Full body cardio', 'muscle': 'Full Body', 'location': 'gym', 'calories': 10},
    ],
    'Endurance': [
      {'name': 'Bodyweight Squats', 'icon': '🦵', 'desc': 'Leg endurance', 'muscle': 'Legs', 'location': 'home', 'calories': 7},
      {'name': 'Walking Lunges', 'icon': '🚶', 'desc': 'Balance & stamina', 'muscle': 'Legs', 'location': 'home', 'calories': 8},
      {'name': 'Push-ups', 'icon': '💪', 'desc': 'Upper body endurance', 'muscle': 'Chest', 'location': 'home', 'calories': 8},
      {'name': 'Plank Hold', 'icon': '⭐', 'desc': 'Core stability', 'muscle': 'Core', 'location': 'home', 'calories': 6},
      {'name': 'Treadmill Jog', 'icon': '🏃', 'desc': 'Cardio endurance', 'muscle': 'Full Body', 'location': 'gym', 'calories': 9},
      {'name': 'Stationary Bike', 'icon': '🚲', 'desc': 'Leg endurance', 'muscle': 'Legs', 'location': 'gym', 'calories': 9},
      {'name': 'Jump Rope', 'icon': '🪢', 'desc': 'Cardio coordination', 'muscle': 'Full Body', 'location': 'both', 'calories': 12},
    ],
    'Muscle Building': [
      {'name': 'Push-ups', 'icon': '💪', 'desc': 'Chest & triceps', 'muscle': 'Chest', 'location': 'home', 'calories': 7},
      {'name': 'Squats', 'icon': '🦵', 'desc': 'Leg strength', 'muscle': 'Legs', 'location': 'home', 'calories': 7},
      {'name': 'Lunges', 'icon': '🚶', 'desc': 'Leg strength', 'muscle': 'Legs', 'location': 'home', 'calories': 7},
      {'name': 'Pull-ups', 'icon': '🔱', 'desc': 'Back & biceps', 'muscle': 'Back', 'location': 'gym', 'calories': 8},
      {'name': 'Bench Press', 'icon': '🏋️', 'desc': 'Chest strength', 'muscle': 'Chest', 'location': 'gym', 'calories': 7},
      {'name': 'Deadlift', 'icon': '🏋️', 'desc': 'Posterior chain', 'muscle': 'Back', 'location': 'gym', 'calories': 8},
      {'name': 'Shoulder Press', 'icon': '🏋️', 'desc': 'Shoulder strength', 'muscle': 'Shoulders', 'location': 'gym', 'calories': 7},
    ],
  };
}