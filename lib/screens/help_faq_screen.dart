import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem(this.question, this.answer);
}

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  static const _faqs = [
    _FaqItem(
      'How is my calorie burn calculated?',
      'Cardio exercises use duration and distance, strength exercises use sets, reps, and weight. '
          'Each exercise type has its own formula, and your session total is the sum across every exercise you log that day.',
    ),
    _FaqItem(
      'How do goals track my progress automatically?',
      'Goals are calculated live from your logged workouts — no manual entry needed. Weekly goals look at '
          'the last 7 days, monthly goals look at the current calendar month.',
    ),
    _FaqItem(
      'Can I log in with my username instead of email?',
      'Yes — the login screen accepts either your email address or your username, whichever you find easier to remember.',
    ),
    _FaqItem(
      'What happens if I delete a workout?',
      'Deleting a workout session removes it and every exercise logged under it. Any goals tracking that period '
          'update automatically to reflect the change.',
    ),
    _FaqItem(
      'Is my data stored securely?',
      'Your password is hashed before it\'s ever stored — FitPulse never keeps your plain-text password. '
          'Your workouts, goals, and profile info are stored in the app\'s database and never shared with third parties.',
    ),
    _FaqItem(
      'How do I change my password?',
      'Go to Profile & Settings > Change Password. You\'ll need to enter your current password to confirm it\'s you.',
    ),
  ];

  Future<void> _contactSupport(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@fittrack.app',
      query: 'subject=FitPulse Support Request',
    );
    final launched = await launchUrl(uri);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No email app found on this device')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & FAQ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.workouts.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.mail_outline, color: AppColors.workouts),
              ),
              title: const Text('Contact Support'),
              subtitle: const Text('support@fittrack.app'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _contactSupport(context),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Frequently Asked Questions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (int i = 0; i < _faqs.length; i++) ...[
                  ExpansionTile(
                    title: Text(_faqs[i].question, style: const TextStyle(fontWeight: FontWeight.w600)),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_faqs[i].answer, style: const TextStyle(color: Colors.grey, height: 1.4)),
                    ],
                  ),
                  if (i < _faqs.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
