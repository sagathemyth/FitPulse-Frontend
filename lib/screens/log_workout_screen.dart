import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session.dart';
import '../widgets/gradient_button.dart';

class LogWorkoutScreen extends StatefulWidget {
  const LogWorkoutScreen({super.key});

  @override
  State<LogWorkoutScreen> createState() => _LogWorkoutScreenState();
}

class _LogWorkoutScreenState extends State<LogWorkoutScreen> {
  final _apiService = ApiService();
  final _exerciseNameController = TextEditingController();
  final _notesController = TextEditingController();

  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();

  final _durationController = TextEditingController();
  final _distanceController = TextEditingController();

  String _exerciseType = 'STRENGTH';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _handleSave() async {
    if (_exerciseNameController.text.isEmpty) {
      _showError('Please enter an exercise name');
      return;
    }

    setState(() => _isLoading = true);

    final dateStr =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    final Map<String, dynamic> body = {
      'userId': Session.userId,
      'sessionTitle': 'Workout',
      'date': dateStr,
      'exerciseName': _exerciseNameController.text.trim(),
      'exerciseType': _exerciseType,
      'notes': _notesController.text.trim(),
    };

    if (_exerciseType == 'STRENGTH') {
      body['sets'] = int.tryParse(_setsController.text) ?? 0;
      body['reps'] = int.tryParse(_repsController.text) ?? 0;
      body['weightKg'] = double.tryParse(_weightController.text) ?? 0;
    } else {
      body['durationMinutes'] = int.tryParse(_durationController.text) ?? 0;
      body['distanceKm'] = double.tryParse(_distanceController.text) ?? 0;
    }

    try {
      await _apiService.logWorkout(body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout saved!'), backgroundColor: Colors.green),
        );
        _clearForm();
      }
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _exerciseNameController.clear();
    _notesController.clear();
    _setsController.clear();
    _repsController.clear();
    _weightController.clear();
    _durationController.clear();
    _distanceController.clear();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Workout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Exercise Name', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _exerciseNameController,
              decoration: const InputDecoration(
                hintText: 'e.g. Bench Press',
                prefixIcon: Icon(Icons.edit_outlined),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Exercise Type', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'STRENGTH', label: Text('Strength'), icon: Icon(Icons.fitness_center)),
                ButtonSegment(value: 'CARDIO', label: Text('Cardio'), icon: Icon(Icons.directions_run)),
              ],
              selected: {_exerciseType},
              onSelectionChanged: (newSelection) {
                setState(() => _exerciseType = newSelection.first);
              },
            ),
            const SizedBox(height: 16),
            if (_exerciseType == 'STRENGTH') ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Strength Performance', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _numberField('Sets', _setsController)),
                        const SizedBox(width: 8),
                        Expanded(child: _numberField('Reps', _repsController)),
                        const SizedBox(width: 8),
                        Expanded(child: _numberField('Weight (kg)', _weightController, decimal: true)),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cardio Performance', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _numberField('Duration (minutes)', _durationController)),
                        const SizedBox(width: 8),
                        Expanded(child: _numberField('Distance (km)', _distanceController, decimal: true)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text('Date', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(),
                child: Text('${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}'),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Notes', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'How did it feel? Any observations...'),
            ),
            const SizedBox(height: 24),
            GradientButton(
              onPressed: _isLoading ? null : _handleSave,
              isLoading: _isLoading,
              child: const Text('Save Workout'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberField(String label, TextEditingController controller, {bool decimal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: decimal),
          decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
        ),
      ],
    );
  }
}