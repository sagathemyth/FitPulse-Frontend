import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session.dart';
import '../models/progress.dart';
import '../theme/app_theme.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final _apiService = ApiService();
  ProgressData? _progress;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _apiService.getProgress(Session.userId!);
      if (mounted) {
        setState(() {
          _progress = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  String _dayLabel(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      return days[date.weekday - 1];
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress Analytics')),
      body: RefreshIndicator(
        onRefresh: _loadProgress,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text('Error: $_error'))
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final progress = _progress!;
    final entriesList = progress.dailyCalories.entries.toList();
    double maxCal = 1.0;
    for (final entry in entriesList) {
      if (entry.value > maxCal) {
        maxCal = entry.value;
      }
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.workouts.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.calendar_today, size: 20, color: AppColors.workouts),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${progress.totalWorkouts}',
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                        ),
                        const Text('Total Workouts', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.calories.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.local_fire_department, size: 20, color: AppColors.calories),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          progress.caloriesThisWeek.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                        ),
                        const Text('Calories This Week', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Weekly Calories Burned', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 160,
                    child: _buildBars(entriesList, maxCal),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBars(List<MapEntry<String, double>> entriesList, double maxCal) {
    final List<Widget> bars = [];
    for (final entry in entriesList) {
      final heightFraction = entry.value / maxCal;
      final dayLabel = _dayLabel(entry.key);
      bars.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (entry.value > 0)
                  Text(entry.value.toStringAsFixed(0), style: const TextStyle(fontSize: 10)),
                const SizedBox(height: 4),
                Container(
                  height: (120 * heightFraction).clamp(4, 120).toDouble(),
                  decoration: BoxDecoration(
                    color: AppColors.calories,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Text(dayLabel, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: bars);
  }
}