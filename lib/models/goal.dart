class GoalModel {
  final int id;
  final String type;
  final double targetValue;
  final double currentValue;
  final bool achieved;

  GoalModel({
    required this.id,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    required this.achieved,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'],
      type: json['type'],
      targetValue: (json['targetValue'] as num).toDouble(),
      currentValue: (json['currentValue'] as num).toDouble(),
      achieved: json['achieved'],
    );
  }

  /// Human-readable label for this goal's type code.
  /// Falls back to the raw code for any legacy/unrecognized value
  /// (e.g. free-text goals created before auto-calculation existed).
  String get label => GoalType.labelFor(type);
}

/// The fixed set of goal types the backend knows how to auto-calculate
/// progress for, straight from the user's logged workout sessions.
class GoalType {
  static const caloriesWeek = 'CALORIES_WEEK';
  static const caloriesMonth = 'CALORIES_MONTH';
  static const workoutsWeek = 'WORKOUTS_WEEK';
  static const workoutsMonth = 'WORKOUTS_MONTH';

  static const List<String> all = [
    caloriesWeek,
    caloriesMonth,
    workoutsWeek,
    workoutsMonth,
  ];

  static String labelFor(String type) {
    switch (type) {
      case caloriesWeek:
        return 'Calories This Week';
      case caloriesMonth:
        return 'Calories This Month';
      case workoutsWeek:
        return 'Workouts This Week';
      case workoutsMonth:
        return 'Workouts This Month';
      default:
        return type;
    }
  }
}
