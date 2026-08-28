import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/exercise.dart';
import '../models/workout_session.dart';
import '../models/progress.dart';
import '../models/goal.dart';

class ApiService {
  // 10.0.2.2 = special alias the Android emulator uses to reach your computer's localhost.
  // If testing on a real physical phone instead, replace this with your computer's actual
  // local network IP (e.g. 192.168.x.x), found via `ipconfig` on your PC.
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  Future<AppUser> register(String name, String email, String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      return AppUser.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_extractError(response.body));
    }
  }

  /// [identifier] may be either the user's email address or their username.
  Future<AppUser> login(String identifier, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier, 'password': password}),
    );
    if (response.statusCode == 200) {
      return AppUser.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_extractError(response.body));
    }
  }

  Future<AppUser> updateProfile(
    int userId,
    String name,
    String email, {
    int? age,
    String? biologicalSex,
    double? heightCm,
    double? weightKg,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'age': age,
        'biologicalSex': biologicalSex,
        'heightCm': heightCm,
        'weightKg': weightKg,
      }),
    );
    if (response.statusCode == 200) {
      return AppUser.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_extractError(response.body));
    }
  }

  Future<void> changePassword(int userId, String currentPassword, String newPassword) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId/password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'currentPassword': currentPassword, 'newPassword': newPassword}),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_extractError(response.body));
    }
  }

  Future<void> deleteAccount(int userId) async {
    final response = await http.delete(Uri.parse('$baseUrl/users/$userId'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_extractError(response.body));
    }
  }

  Future<void> verifyEmailExists(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_extractError(response.body));
    }
  }

  Future<void> resetPassword(String email, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'newPassword': newPassword}),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_extractError(response.body));
    }
  }

  Future<ExerciseModel> logWorkout(Map<String, dynamic> requestBody) async {
    final response = await http.post(
      Uri.parse('$baseUrl/workouts/log'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200) {
      return ExerciseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_extractError(response.body));
    }
  }

  Future<List<WorkoutSessionSummary>> getHistory(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/workouts/history/$userId'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => WorkoutSessionSummary.fromJson(e)).toList();
    } else {
      throw Exception(_extractError(response.body));
    }
  }

  Future<WorkoutSessionDetail> getSessionDetail(int sessionId) async {
    final response = await http.get(Uri.parse('$baseUrl/workouts/session/$sessionId'));
    if (response.statusCode == 200) {
      return WorkoutSessionDetail.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_extractError(response.body));
    }
  }

  Future<void> deleteSession(int sessionId) async {
    final response = await http.delete(Uri.parse('$baseUrl/workouts/session/$sessionId'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_extractError(response.body));
    }
  }

  Future<ProgressData> getProgress(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/workouts/progress/$userId'));
    if (response.statusCode == 200) {
      return ProgressData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_extractError(response.body));
    }
  }

  Future<List<GoalModel>> getGoals(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/goals/$userId'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => GoalModel.fromJson(e)).toList();
    } else {
      throw Exception(_extractError(response.body));
    }
  }

  Future<GoalModel> createGoal(int userId, String type, double targetValue) async {
    final response = await http.post(
      Uri.parse('$baseUrl/goals'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'type': type, 'targetValue': targetValue}),
    );
    if (response.statusCode == 200) {
      return GoalModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_extractError(response.body));
    }
  }


  Future<void> deleteGoal(int goalId) async {
    final response = await http.delete(Uri.parse('$baseUrl/goals/$goalId'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_extractError(response.body));
    }
  }

  String _extractError(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        // IllegalArgumentException failures come back as {"error": "..."}.
        final err = decoded['error'];
        if (err is String) return err;
        // @Valid failures (blank/too-short fields, bad email format, etc.)
        // come back as {"fieldName": "message", ...} instead — show the first one.
        for (final value in decoded.values) {
          if (value is String) return value;
        }
      }
      return 'Something went wrong';
    } catch (_) {
      return 'Something went wrong';
    }
  }
}