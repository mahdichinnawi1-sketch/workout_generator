class User {
  final int id;
  final String username;
  final String email;
  final String preferredLocation;
  final int targetCalories;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.preferredLocation,
    required this.targetCalories,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      preferredLocation: json['preferred_location'] ?? 'home',
      targetCalories: json['target_calories'] ?? 300,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'preferred_location': preferredLocation,
      'target_calories': targetCalories,
      'created_at': createdAt.toIso8601String(),
    };
  }
}