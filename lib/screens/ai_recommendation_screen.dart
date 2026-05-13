import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AIRecommendationScreen extends StatefulWidget {
  final int userId;

  const AIRecommendationScreen({super.key, required this.userId});

  @override
  State<AIRecommendationScreen> createState() => _AIRecommendationScreenState();
}

class _AIRecommendationScreenState extends State<AIRecommendationScreen> {
  String _selectedGoal = '🔥 Weight Loss';
  String? _selectedInjury;
  int _timeMinutes = 30;
  String _selectedEquipment = '🏠 Home';
  String _selectedExperience = '🌱 Beginner';
  
  bool _isLoading = false;
  Map<String, dynamic>? _aiWorkout;
  
  final List<String> goals = ['🔥 Weight Loss', '⚡ Endurance', '💪 Muscle Building'];
  final List<String> injuries = ['None', 'Knee Pain', 'Back Pain', 'Shoulder Pain', 'Wrist Pain', 'Ankle Pain'];
  final List<String> equipment = ['🏠 Home', '🏋️ Gym', 'Dumbbells Only', 'Bodyweight Only'];
  final List<String> experienceLevels = ['🌱 Beginner', '📈 Intermediate', '🏆 Advanced'];
  
  final TextEditingController _injuryController = TextEditingController();

  Future<void> _getAIRecommendation() async {
    setState(() {
      _isLoading = true;
    });
    
    final injuryValue = _selectedInjury == 'None' ? '' : _selectedInjury;
    
    final response = await ApiService.getAIWorkoutRecommendation(
      goal: _selectedGoal,
      injury: injuryValue,
      timeMinutes: _timeMinutes,
      equipment: _selectedEquipment,
      experienceLevel: _selectedExperience,
    );
    
    setState(() {
      _isLoading = false;
      if (response['success'] == true) {
        _aiWorkout = response['workout'];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'] ?? 'Failed to generate workout'), backgroundColor: Colors.red),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('AI Workout Assistant', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            onPressed: _getAIRecommendation,
            icon: const Icon(Icons.auto_awesome, color: Colors.amber),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade800, Colors.amber.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 32, color: Colors.white),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI-Powered Workout',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          'Get personalized workouts based on your preferences, limitations, and available equipment',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Goal Selection
            _buildSectionTitle('Fitness Goal', Icons.bolt),
            const SizedBox(height: 8),
            _buildChipGrid(goals, _selectedGoal, (value) {
              setState(() => _selectedGoal = value);
            }),
            
            const SizedBox(height: 20),
            
            // Injury/Limitation
            _buildSectionTitle('Physical Limitations / Injuries', Icons.healing),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: injuries.map((injury) {
                final isSelected = _selectedInjury == injury;
                return FilterChip(
                  selected: isSelected,
                  label: Text(injury),
                  onSelected: (selected) {
                    setState(() {
                      _selectedInjury = selected ? injury : null;
                    });
                  },
                  backgroundColor: Colors.grey[800],
                  selectedColor: Colors.red.withOpacity(0.3),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.red : Colors.white70,
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),
            
            // Duration
            _buildSectionTitle('Workout Duration (minutes)', Icons.timer),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (_timeMinutes > 15) _timeMinutes -= 5;
                      });
                    },
                    icon: const Icon(Icons.remove_circle, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      '$_timeMinutes min',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (_timeMinutes < 90) _timeMinutes += 5;
                      });
                    },
                    icon: const Icon(Icons.add_circle, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Equipment
            _buildSectionTitle('Available Equipment', Icons.fitness_center),
            const SizedBox(height: 8),
            _buildChipGrid(equipment, _selectedEquipment, (value) {
              setState(() => _selectedEquipment = value);
            }),
            
            const SizedBox(height: 20),
            
            // Experience Level
            _buildSectionTitle('Experience Level', Icons.trending_up),
            const SizedBox(height: 8),
            _buildChipGrid(experienceLevels, _selectedExperience, (value) {
              setState(() => _selectedExperience = value);
            }),
            
            const SizedBox(height: 24),
            
            // Generate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _getAIRecommendation,
                icon: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.auto_awesome),
                label: Text(_isLoading ? 'GENERATING...' : 'GENERATE AI WORKOUT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // AI Response Display
            if (_aiWorkout != null) ...[
              const Divider(color: Colors.grey),
              const SizedBox(height: 16),
              _buildSectionTitle('YOUR PERSONALIZED WORKOUT', Icons.fitness_center),
              const SizedBox(height: 16),
              
              // Warmup Section
              _buildWorkoutSection('🔥 WARM UP', _aiWorkout!['warmup']),
              const SizedBox(height: 16),
              
              // Main Workout Section
              _buildWorkoutSection('💪 MAIN WORKOUT', _aiWorkout!['mainWorkout']),
              const SizedBox(height: 16),
              
              // Cooldown Section
              _buildWorkoutSection('❄️ COOL DOWN', _aiWorkout!['cooldown']),
              const SizedBox(height: 16),
              
              // Notes
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text('Important Notes', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _aiWorkout!['notes'] ?? 'Listen to your body and maintain proper form.',
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.amber),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildChipGrid(List<String> items, String selected, Function(String) onSelected) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = selected == item;
        return FilterChip(
          selected: isSelected,
          label: Text(item),
          onSelected: (s) => onSelected(item),
          backgroundColor: Colors.grey[800],
          selectedColor: Colors.amber.withOpacity(0.3),
          labelStyle: TextStyle(
            color: isSelected ? Colors.amber : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWorkoutSection(String title, List<dynamic> exercises) {
    if (exercises == null || exercises.isEmpty) return const SizedBox();
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        leading: Icon(
          title.contains('WARM') ? Icons.whatshot : (title.contains('COOL') ? Icons.ac_unit : Icons.fitness_center),
          color: Colors.amber,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: exercises.map((ex) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🏋️ ${ex['name'] ?? 'Exercise'}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                if (ex['sets'] != null)
                  Text('• Sets: ${ex['sets']} | Reps: ${ex['reps']} | Rest: ${ex['rest']}'),
                if (ex['duration'] != null)
                  Text('• Duration: ${ex['duration']}'),
                if (ex['instructions'] != null)
                  Text('• ${ex['instructions']}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                const Divider(),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}