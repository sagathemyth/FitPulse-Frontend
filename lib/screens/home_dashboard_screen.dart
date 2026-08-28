import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session.dart';
import '../models/progress.dart';
import '../theme/app_theme.dart';
import 'log_workout_screen.dart';
import 'workout_history_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';
import 'goals_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final _apiService = ApiService();
  ProgressData? _progress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final data = await _apiService.getProgress(Session.userId!);
      if (mounted) setState(() { _progress = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, ${Session.userName ?? ''}!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProgress,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
              else
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.fitness_center,
                        label: 'Workouts',
                        value: '${_progress?.totalWorkouts ?? 0}',
                        color: AppColors.workouts,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.local_fire_department,
                        label: 'Calories This Week',
                        value: '${_progress?.caloriesThisWeek.toStringAsFixed(0) ?? 0}',
                        color: AppColors.calories,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.add_circle_outline,
                title: 'Log Workout',
                subtitle: 'Log your latest session stats',
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const LogWorkoutScreen()));
                  _loadProgress();
                },
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.history,
                title: 'View History',
                subtitle: 'Check your past routines',
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkoutHistoryScreen()));
                  _loadProgress();
                },
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.show_chart,
                title: 'View Progress',
                subtitle: 'See calories and charts',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressScreen())),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.flag_outlined,
                title: 'Goals',
                subtitle: 'Set and track your targets',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}