import 'package:flutter/material.dart';

class AboutLegalScreen extends StatelessWidget {
  const AboutLegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About & Legal')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                Icon(Icons.favorite, size: 48, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 8),
                const Text('FitPulse', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Version 1.0.0 (Build 1)', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const _LegalTextScreen(
                        title: 'Terms of Service',
                        body: _termsOfServiceText,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const _LegalTextScreen(
                        title: 'Privacy Policy',
                        body: _privacyPolicyText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalTextScreen extends StatelessWidget {
  final String title;
  final String body;
  const _LegalTextScreen({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Text(body, style: const TextStyle(height: 1.5)),
      ),
    );
  }
}

const _termsOfServiceText = '''
Terms of Service

Last updated: 2026

By using FitPulse, you agree to the following terms.

1. Purpose
FitPulse is a personal workout and fitness goal tracking application developed as an academic project.

2. Your Account
You are responsible for keeping your login credentials secure. You may register, update, or delete your account at any time from Profile & Settings.

3. Your Data
Workouts, exercises, and goals you log belong to you. Deleting your account permanently removes this data.

4. Acceptable Use
You agree not to use FitPulse for any unlawful purpose or to attempt to access accounts other than your own.

5. No Warranty
FitPulse is provided "as is" without warranties of any kind. Calorie and progress calculations are estimates and should not be treated as medical advice.

6. Changes
These terms may be updated as the app evolves.
''';

const _privacyPolicyText = '''
Privacy Policy

Last updated: 2026

Your privacy matters. Here's what FitPulse collects and how it's used.

1. What We Collect
Name, email address, username, and a securely hashed password when you register. Workout, exercise, and goal data you choose to log. An optional profile photo, stored locally on your device only.

2. How It's Used
Your data is used solely to power the app's features — tracking workouts, calculating progress, and displaying your goals. It is never sold or shared with third parties.

3. Password Security
Passwords are hashed before storage and are never stored or transmitted in plain text.

4. Data Retention
Your data is retained until you delete your account, at which point it is permanently removed.

5. Contact
Questions about this policy can be sent via Help & FAQ > Contact Support.
''';
