class ExerciseModel {
  final int id;
  final String name;
  final String type; // "CARDIO" or "STRENGTH"
  final String date;
  final String? notes;
  final double caloriesBurned;
  final int? durationMinutes;
  final double? distanceKm;
  final int? sets;
  final int? reps;
  final double? weightKg;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
    this.notes,
    required this.caloriesBurned,
    this.durationMinutes,
    this.distanceKm,
    this.sets,
    this.reps,
    this.weightKg,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      date: json['date'],
      notes: json['notes'],
      caloriesBurned: (json['caloriesBurned'] as num).toDouble(),
      durationMinutes: json['durationMinutes'],
      distanceKm: json['distanceKm'] != null ? (json['distanceKm'] as num).toDouble() : null,
      sets: json['sets'],
      reps: json['reps'],
      weightKg: json['weightKg'] != null ? (json['weightKg'] as num).toDouble() : null,
    );
  }
}