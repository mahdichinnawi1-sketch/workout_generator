class ExerciseAPI {
  final String name;
  final String type;
  final String muscle;
  final String equipment;
  final String difficulty;
  final String instructions;
  final String? imageUrl;

  ExerciseAPI({
    required this.name,
    required this.type,
    required this.muscle,
    required this.equipment,
    required this.difficulty,
    required this.instructions,
    this.imageUrl,
  });

  factory ExerciseAPI.fromJson(Map<String, dynamic> json) {
    return ExerciseAPI(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      muscle: json['muscle'] ?? '',
      equipment: json['equipment'] ?? '',
      difficulty: json['difficulty'] ?? '',
      instructions: json['instructions'] ?? '',
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'muscle': muscle,
      'equipment': equipment,
      'difficulty': difficulty,
      'instructions': instructions,
      'image_url': imageUrl,
    };
  }
}