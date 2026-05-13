class Food {
  final int id;
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final String category;

  Food({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    this.category = 'other',
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'],
      name: json['name'],
      calories: json['calories'],
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      fiber: (json['fiber'] ?? 0).toDouble(),
      category: json['category'] ?? 'other',
    );
  }
}