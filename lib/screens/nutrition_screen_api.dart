import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NutritionScreenAPI extends StatefulWidget {
  final String userGoal;
  final int userId;

  const NutritionScreenAPI({
    super.key,
    required this.userGoal,
    required this.userId,
  });

  @override
  State<NutritionScreenAPI> createState() => _NutritionScreenAPIState();
}

class _NutritionScreenAPIState extends State<NutritionScreenAPI> {
  Map<String, dynamic> _nutritionGoals = {};
  List<dynamic> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic> _mealSuggestions = {};
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final goals = await ApiService.getNutritionGoals(widget.userId);
      final suggestions = await ApiService.getMealSuggestions(widget.userGoal);

      setState(() {
        _nutritionGoals = goals;
        _mealSuggestions = suggestions;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
        // Set default values on error
        _nutritionGoals = {
          'daily_calorie_target': 2000,
          'daily_protein_target': 150,
          'daily_carbs_target': 250,
          'daily_fat_target': 55
        };
        _mealSuggestions = {
          'breakfast': ['Oatmeal', 'Eggs', 'Greek Yogurt'],
          'lunch': ['Grilled Chicken Salad', 'Turkey Sandwich'],
          'dinner': ['Salmon with Rice', 'Chicken Stir-fry'],
          'snacks': ['Apple', 'Protein Shake']
        };
      });
    }
  }

  Future<void> _searchFood() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await ApiService.searchFoods(_searchController.text);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      print('Search error: $e');
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Nutrition Guide'),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Custom Tab Bar
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      _buildTabButton(0, 'MY PLAN', Icons.food_bank),
                      _buildTabButton(1, 'FOOD SEARCH', Icons.search),
                    ],
                  ),
                ),
                // Tab Content
                Expanded(
                  child: IndexedStack(
                    index: _selectedTab,
                    children: [
                      _buildPlanTab(),
                      _buildFoodsTab(),
                    ],
                  ),
                ),
              ],
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
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: const EdgeInsets.all(4),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanTab() {
    // Safely get values with defaults
    final calorieTarget = _nutritionGoals['daily_calorie_target'] ?? 2000;
    final proteinTarget = _nutritionGoals['daily_protein_target'] ?? 150;
    final carbsTarget = _nutritionGoals['daily_carbs_target'] ?? 250;
    final fatTarget = _nutritionGoals['daily_fat_target'] ?? 55;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calorie Target Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade800, Colors.orange.shade600],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  'YOUR DAILY TARGET',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  '$calorieTarget',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Text('calories / day', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMacroCard('🥩', 'Protein', '${proteinTarget.round()}g'),
                    _buildMacroCard('🍚', 'Carbs', '${carbsTarget.round()}g'),
                    _buildMacroCard('🧈', 'Fat', '${fatTarget.round()}g'),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Meal Suggestions
          const Text(
            'MEAL SUGGESTIONS',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          
          _buildMealSection('Breakfast', _mealSuggestions['breakfast'] ?? []),
          _buildMealSection('Lunch', _mealSuggestions['lunch'] ?? []),
          _buildMealSection('Dinner', _mealSuggestions['dinner'] ?? []),
          _buildMealSection('Snacks', _mealSuggestions['snacks'] ?? []),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildMealSection(String title, List<dynamic> suggestions) {
    // Convert to List<String> safely
    List<String> stringSuggestions = suggestions.map((e) => e.toString()).toList();
    
    if (stringSuggestions.isEmpty) {
      return Container();
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.restaurant, color: Colors.green, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        children: stringSuggestions.map((suggestion) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(child: Text(suggestion, style: const TextStyle(color: Colors.white70))),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFoodsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search food (e.g., chicken)',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _searchFood(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _searchFood,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                ),
                child: const Icon(Icons.search, color: Colors.white),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Search for food to see nutrition info',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final food = _searchResults[index];
                        // Safely access values
                        final name = food['name']?.toString() ?? 'Unknown';
                        final calories = food['calories'] ?? 0;
                        final protein = food['protein'] ?? 0;
                        
                        return Card(
                          margin: const EdgeInsets.all(8),
                          color: Colors.grey[900],
                          child: ListTile(
                            leading: const Icon(Icons.fastfood, size: 32, color: Colors.orange),
                            title: Text(
                              name,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            subtitle: Text(
                              '$calories cal | ${protein}g protein',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                            onTap: () => _showFoodDetails(food),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  void _showFoodDetails(Map<String, dynamic> food) {
    // Safely extract values
    final name = food['name']?.toString() ?? 'Unknown';
    final calories = food['calories'] ?? 0;
    final protein = food['protein'] ?? 0;
    final carbs = food['carbs'] ?? 0;
    final fat = food['fat'] ?? 0;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Divider(color: Colors.grey),
            const SizedBox(height: 16),
            _buildNutritionRow('Calories', '$calories kcal'),
            _buildNutritionRow('Protein', '${protein}g'),
            _buildNutritionRow('Carbohydrates', '${carbs}g'),
            _buildNutritionRow('Fat', '${fat}g'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.white70)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildMacroCard(String icon, String label, String value) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}