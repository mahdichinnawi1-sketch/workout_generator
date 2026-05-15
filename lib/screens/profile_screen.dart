import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_session_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  WorkoutStats? _stats;
  bool _isLoading = true;
  int _userId = 0;
  String _username = '';
  
  // Physical data
  int _userWeight = 70;
  int _userHeight = 170;
  int _userAge = 25;
  String _userGender = 'male';
  
  bool _isEditing = false;
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id') ?? 0;
    _username = prefs.getString('username') ?? 'User';
    
    // Load physical data from SharedPreferences
    _userWeight = prefs.getInt('user_weight') ?? 70;
    _userHeight = prefs.getInt('user_height') ?? 170;
    _userAge = prefs.getInt('user_age') ?? 25;
    _userGender = prefs.getString('user_gender') ?? 'male';
    
    _weightController.text = _userWeight.toString();
    _heightController.text = _userHeight.toString();
    _ageController.text = _userAge.toString();

    try {
      final userResponse = await ApiService.getUserProfile(_userId);
      final statsResponse = await ApiService.getWorkoutStats(_userId);

      setState(() {
        _userData = userResponse;
        _stats = WorkoutStats.fromJson(statsResponse);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _savePhysicalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_weight', int.parse(_weightController.text));
    await prefs.setInt('user_height', int.parse(_heightController.text));
    await prefs.setInt('user_age', int.parse(_ageController.text));
    await prefs.setString('user_gender', _userGender);
    
    setState(() {
      _userWeight = int.parse(_weightController.text);
      _userHeight = int.parse(_heightController.text);
      _userAge = int.parse(_ageController.text);
      _isEditing = false;
    });
    
    // Also update backend
    try {
      await ApiService.updateUserProfile(
        userId: _userId,
        preferredLocation: _userData?['preferred_location'] ?? 'home',
        targetCalories: _userData?['target_calories'] ?? 300,
        weightKg: _userWeight,
        heightCm: _userHeight,
        age: _userAge,
        gender: _userGender,
      );
    } catch (e) {
      print('Error updating backend: $e');
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Physical data saved!'),
        backgroundColor: Colors.green,
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.red),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Profile Image
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      _username.isNotEmpty ? _username[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _username,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    _userData?['email'] ?? '',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Workout Statistics Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Workout Statistics',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCard(
                              '🏋️',
                              '${_stats?.totalWorkouts ?? 0}',
                              'Workouts',
                            ),
                            _buildStatCard(
                              '🔥',
                              '${_stats?.totalCalories ?? 0}',
                              'Calories',
                            ),
                            _buildStatCard(
                              '⏱️',
                              '${_stats?.totalMinutes ?? 0}',
                              'Minutes',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: Colors.grey),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('This Week:', style: TextStyle(color: Colors.white70)),
                            Text(
                              '${_stats?.workoutsThisWeek ?? 0} workouts',
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Physical Information Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Physical Information',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = !_isEditing;
                                  if (!_isEditing) {
                                    _loadUserData();
                                  }
                                });
                              },
                              icon: Icon(
                                _isEditing ? Icons.close : Icons.edit,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        if (_isEditing) ...[
                          // Edit Mode
                          _buildEditableField('Weight (kg)', _weightController),
                          const SizedBox(height: 12),
                          _buildEditableField('Height (cm)', _heightController),
                          const SizedBox(height: 12),
                          _buildEditableField('Age (years)', _ageController),
                          const SizedBox(height: 12),
                          _buildGenderSelector(),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _savePhysicalData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text('SAVE CHANGES'),
                            ),
                          ),
                        ] else ...[
                          // View Mode
                          _buildInfoRow('Weight:', '${_userWeight} kg'),
                          const SizedBox(height: 12),
                          _buildInfoRow('Height:', '${_userHeight} cm'),
                          const SizedBox(height: 12),
                          _buildInfoRow('Age:', '${_userAge} years'),
                          const SizedBox(height: 12),
                          _buildInfoRow('Gender:', _userGender == 'male' ? 'Male' : 'Female'),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Preferences Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Preferences',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Preferred Location:', style: TextStyle(color: Colors.white70)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _userData?['preferred_location'] == 'home' ? '🏠 Home' : '🏋️ Gym',
                                style: const TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Daily Target:', style: TextStyle(color: Colors.white70)),
                            Text(
                              '${_userData?['target_calories'] ?? 300} calories',
                              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Member Since:', style: TextStyle(color: Colors.white70)),
                            Text(
                              _userData?['created_at'] != null
                                  ? DateTime.parse(_userData!['created_at']).toString().split(' ')[0]
                                  : 'N/A',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender:',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _userGender = 'male';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _userGender == 'male' ? Colors.blue.withOpacity(0.3) : Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _userGender == 'male' ? Colors.blue : Colors.transparent,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Male',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _userGender = 'female';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _userGender == 'female' ? Colors.pink.withOpacity(0.3) : Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _userGender == 'female' ? Colors.pink : Colors.transparent,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Female',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}