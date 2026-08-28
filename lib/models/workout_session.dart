import 'exercise.dart';

class WorkoutSessionSummary {
  final int id;
  final String title;
  final String date;
  final double totalCalories;
  final int exerciseCount;

  WorkoutSessionSummary({
    required this.id,
    required this.title,
    required this.date,
    required this.totalCalories,
    required this.exerciseCount,
  });

  factory WorkoutSessionSummary.fromJson(Map<String, dynamic> json) {
    return WorkoutSessionSummary(
      id: json['id'],
      title: json['title'],
      date: json['date'],
      totalCalories: (json['totalCalories'] as num).toDouble(),
      exerciseCount: json['exerciseCount'],
    );
  }
}

class WorkoutSessionDetail {
  final int id;
  final String title;
  final String date;
  final double totalCalories;
  final List<ExerciseModel> exercises;

  WorkoutSessionDetail({
    required this.id,
    required this.title,
    required this.date,
    required this.totalCalories,
    required this.exercises,
  });

  factory WorkoutSessionDetail.fromJson(Map<String, dynamic> json) {
    return WorkoutSessionDetail(
      id: json['id'],
      title: json['title'],
      date: json['date'],
      totalCalories: (json['totalCalories'] as num).toDouble(),
      exercises: (json['exercises'] as List)
          .map((e) => ExerciseModel.fromJson(e))
          .toList(),
    );
  }
}