import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/gradient_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _apiService = ApiService();
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _step = 0; // 0 = enter email, 1 = enter new password
  bool _isLoading = false;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _handleVerifyEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Please enter your email');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _apiService.verifyEmailExists(email);
      if (mounted) setState(() => _step = 1);
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResetPassword() async {
    if (_newPasswordController.text.length < 6) {
      _showError('New password must be at least 6 characters');
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _apiService.resetPassword(_emailController.text.trim(), _newPasswordController.text);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset — you can log in now'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _step == 0
                ? [
                    const Text(
                      "Enter the email on your account and we'll let you set a new password.",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    const Text('Email Address', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        if (!_isLoading) _handleVerifyEmail();
                      },
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.mail_outline)),
                    ),
                    const SizedBox(height: 24),
                    GradientButton(
                      onPressed: _isLoading ? null : _handleVerifyEmail,
                      isLoading: _isLoading,
                      child: const Text('Continue'),
                    ),
                  ]
                : [
                    const Text(
                      'Email verified. Choose a new password.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    const Text('New Password', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _newPasswordController,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_outline)),
                    ),
                    const SizedBox(height: 16),
                    const Text('Confirm New Password', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        if (!_isLoading) _handleResetPassword();
                      },
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_outline)),
                    ),
                    const SizedBox(height: 24),
                    GradientButton(
                      onPressed: _isLoading ? null : _handleResetPassword,
                      isLoading: _isLoading,
                      child: const Text('Reset Password'),
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
