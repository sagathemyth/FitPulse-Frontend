class ProgressData {
  final int totalWorkouts;
  final double caloriesThisWeek;
  final Map<String, double> dailyCalories;

  ProgressData({
    required this.totalWorkouts,
    required this.caloriesThisWeek,
    required this.dailyCalories,
  });

  factory ProgressData.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> raw = json['dailyCalories'];
    final Map<String, double> parsed = raw.map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
    );
    return ProgressData(
      totalWorkouts: json['totalWorkouts'],
      caloriesThisWeek: (json['caloriesThisWeek'] as num).toDouble(),
      dailyCalories: parsed,
    );
  }
}