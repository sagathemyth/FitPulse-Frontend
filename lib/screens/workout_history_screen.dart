import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session.dart';
import '../models/workout_session.dart';
import 'session_detail_screen.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  final _apiService = ApiService();
  List<WorkoutSessionSummary> _sessions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await _apiService.getHistory(Session.userId!);
      if (mounted) setState(() { _sessions = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout History')),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    if (_sessions.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          Padding(
            padding: EdgeInsets.only(top: 100),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.fitness_center, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No workouts logged yet', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final session = _sessions[index];
        return Card(
          child: ListTile(
            title: Text(session.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${session.date} • ${session.exerciseCount} exercise${session.exerciseCount == 1 ? '' : 's'}'),
            trailing: Text(
              '${session.totalCalories.toStringAsFixed(0)} kcal',
              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
            ),
            onTap: () async {
              final deleted = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => SessionDetailScreen(sessionId: session.id)),
              );
              if (deleted == true) _loadHistory();
            },
          ),
        );
      },
    );
  }
}