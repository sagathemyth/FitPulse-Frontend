class AppUser {
  final int id;
  final String name;
  final String email;
  final String username;
  final DateTime? createdAt;
  final int? age;
  final String? biologicalSex;
  final double? heightCm;
  final double? weightKg;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    this.createdAt,
    this.age,
    this.biologicalSex,
    this.heightCm,
    this.weightKg,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      username: json['username'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      age: json['age'],
      biologicalSex: json['biologicalSex'],
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
    );
  }
}
