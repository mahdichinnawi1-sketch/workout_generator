import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // =====================================================
  // IMPORTANT: Change this based on where you're running
  // =====================================================
  
  // FOR LOCAL DEVELOPMENT (Backend on your computer)
  static const String localBaseUrl = 'http://localhost:3000/api';
  
  // FOR PRODUCTION (After deploying to Render)
  // Replace with your actual Render URL after deployment
  static const String productionBaseUrl = 'https://mahdichinnawi1-sketch.github.io/workout_generator';
  
  // Set this to false when deploying to production
  static const bool isDevelopment = true;  // Change to false for production
  
  static String get baseUrl => isDevelopment ? localBaseUrl : productionBaseUrl;

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'x-auth-token': token ?? '',
    };
  }

  // ==================== AUTH ENDPOINTS ====================

  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    String preferredLocation = 'home',
    int targetCalories = 300,
    int weightKg = 70,
    int heightCm = 170,
    int age = 25,
    String gender = 'male',
  }) async {
    try {
      print('Registering user: $email');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'preferred_location': preferredLocation,
          'target_calories': targetCalories,
          'weight_kg': weightKg,
          'height_cm': heightCm,
          'age': age,
          'gender': gender,
        }),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return json.decode(response.body);
    } catch (e) {
      print('Network error: $e');
      return {'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('Logging in: $email');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return json.decode(response.body);
    } catch (e) {
      print('Network error: $e');
      return {'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getUserProfile(int userId) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile/$userId'),
        headers: headers,
      );
      return json.decode(response.body);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateUserProfile({
    required int userId,
    required String preferredLocation,
    required int targetCalories,
    int? weightKg,
    int? heightCm,
    int? age,
    String? gender,
  }) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile/$userId'),
        headers: headers,
        body: json.encode({
          'preferred_location': preferredLocation,
          'target_calories': targetCalories,
          'weight_kg': weightKg,
          'height_cm': heightCm,
          'age': age,
          'gender': gender,
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  // ==================== WORKOUT ENDPOINTS ====================

  static Future<Map<String, dynamic>> saveWorkout({
    required int userId,
    required int durationMinutes,
    required int totalCalories,
    required String goalType,
    required String location,
    required List<Map<String, dynamic>> exercises,
  }) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/workouts/save'),
        headers: headers,
        body: json.encode({
          'user_id': userId,
          'duration_minutes': durationMinutes,
          'total_calories': totalCalories,
          'goal_type': goalType,
          'location': location,
          'exercises': exercises,
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  static Future<List<dynamic>> getWorkoutHistory(int userId) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/workouts/history/$userId'),
        headers: headers,
      );
      final data = json.decode(response.body);
      return data as List<dynamic>;
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getWorkoutStats(int userId) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/workouts/stats/$userId'),
        headers: headers,
      );
      return json.decode(response.body);
    } catch (e) {
      return {
        'total_workouts': 0,
        'total_calories': 0,
        'total_minutes': 0,
        'workouts_this_week': 0,
      };
    }
  }

  static Future<Map<String, dynamic>> deleteWorkout(int workoutId) async {
    try {
      final headers = await getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/workouts/$workoutId'),
        headers: headers,
      );
      return json.decode(response.body);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  // ==================== NUTRITION ENDPOINTS ====================

  static Future<List<dynamic>> searchFoods(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/nutrition/foods?search=$query'),
      );
      return json.decode(response.body);
    } catch (e) {
      print('Error searching foods: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getFoodsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/nutrition/foods?category=$category'),
      );
      return json.decode(response.body);
    } catch (e) {
      print('Error fetching foods: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getNutritionGoals(int userId) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/nutrition/goals/$userId'),
        headers: headers,
      );
      return json.decode(response.body);
    } catch (e) {
      print('Error fetching nutrition goals: $e');
      return {
        'daily_calorie_target': 2000,
        'daily_protein_target': 150,
        'daily_carbs_target': 250,
        'daily_fat_target': 55
      };
    }
  }

  static Future<Map<String, dynamic>> updateNutritionGoals({
    required int userId,
    required int dailyCalorieTarget,
    required double dailyProteinTarget,
    required double dailyCarbsTarget,
    required double dailyFatTarget,
  }) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/nutrition/goals/$userId'),
        headers: headers,
        body: json.encode({
          'daily_calorie_target': dailyCalorieTarget,
          'daily_protein_target': dailyProteinTarget,
          'daily_carbs_target': dailyCarbsTarget,
          'daily_fat_target': dailyFatTarget,
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> logMeal({
    required int userId,
    required int foodId,
    required double servingSize,
    required String mealType,
    String? logDate,
  }) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/nutrition/log'),
        headers: headers,
        body: json.encode({
          'user_id': userId,
          'food_id': foodId,
          'serving_size_g': servingSize,
          'meal_type': mealType,
          'log_date': logDate ?? DateTime.now().toIso8601String().split('T')[0],
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getNutritionLogs(int userId, {String? date}) async {
    try {
      final headers = await getHeaders();
      String url = '$baseUrl/nutrition/logs/$userId';
      if (date != null) {
        url += '?date=$date';
      }
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      return json.decode(response.body);
    } catch (e) {
      return {'logs': [], 'totals': {'calories': 0, 'protein': 0, 'carbs': 0, 'fat': 0}};
    }
  }

  static Future<Map<String, dynamic>> getMealSuggestions(String goal) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/nutrition/suggestions/${Uri.encodeComponent(goal)}'),
      );
      return json.decode(response.body);
    } catch (e) {
      return {
        'breakfast': ['Oatmeal', 'Eggs', 'Greek Yogurt'],
        'lunch': ['Grilled Chicken Salad', 'Turkey Sandwich', 'Quinoa Bowl'],
        'dinner': ['Salmon with Rice', 'Chicken Stir-fry', 'Lean Beef with Vegetables'],
        'snacks': ['Apple', 'Protein Shake', 'Nuts']
      };
    }
  }

  // ==================== AI RECOMMENDATION ENDPOINTS ====================

  static Future<Map<String, dynamic>> getAIWorkoutRecommendation({
    required String goal,
    String? injury,
    required int timeMinutes,
    String? equipment,
    String? experienceLevel,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/recommend-workout'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'goal': goal,
          'injury': injury,
          'timeMinutes': timeMinutes,
          'equipment': equipment,
          'experienceLevel': experienceLevel,
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      print('AI API error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ==================== SCHEDULE ENDPOINTS ====================

  static Future<List<dynamic>> getWeeklySchedule(int userId) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/schedule/$userId'),
        headers: headers,
      );
      return json.decode(response.body);
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> updateScheduleDay({
    required int userId,
    required String day,
    required String workoutType,
    required bool isRestDay,
    required bool isCompleted,
  }) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/schedule/$userId/$day'),
        headers: headers,
        body: json.encode({
          'workout_type': workoutType,
          'is_rest_day': isRestDay,
          'is_completed': isCompleted,
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }
}