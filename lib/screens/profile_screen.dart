import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session.dart';
import '../services/theme_controller.dart';
import '../services/profile_photo_service.dart';
import '../widgets/gradient_button.dart';
import 'login_screen.dart';
import 'help_faq_screen.dart';
import 'about_legal_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _apiService = ApiService();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _ageController;
  late final TextEditingController _heightCmController;
  late final TextEditingController _heightFtController;
  late final TextEditingController _heightInController;
  late final TextEditingController _weightController;
  String? _biologicalSex;
  bool _heightImperial = false;
  bool _weightImperial = false;
  bool _isSaving = false;
  File? _photoFile;
  bool _isPickingPhoto = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: Session.userName);
    _emailController = TextEditingController(text: Session.userEmail);
    _ageController = TextEditingController(text: Session.age?.toString() ?? '');
    _biologicalSex = Session.biologicalSex;
    _heightCmController = TextEditingController(text: Session.heightCm != null ? _fmtNum(Session.heightCm!) : '');
    _heightFtController = TextEditingController();
    _heightInController = TextEditingController();
    _weightController = TextEditingController(text: Session.weightKg != null ? _fmtNum(Session.weightKg!) : '');
    _loadPhoto();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _heightCmController.dispose();
    _heightFtController.dispose();
    _heightInController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  static String _fmtNum(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  void _toggleHeightUnit() {
    setState(() {
      if (!_heightImperial) {
        final cm = double.tryParse(_heightCmController.text.trim());
        if (cm != null) {
          final totalInches = cm / 2.54;
          final ft = totalInches ~/ 12;
          final inch = totalInches - (ft * 12);
          _heightFtController.text = ft.toStringAsFixed(0);
          _heightInController.text = _fmtNum(inch);
        }
      } else {
        final ft = double.tryParse(_heightFtController.text.trim()) ?? 0;
        final inch = double.tryParse(_heightInController.text.trim()) ?? 0;
        final totalInches = ft * 12 + inch;
        if (totalInches > 0) {
          _heightCmController.text = _fmtNum(totalInches * 2.54);
        }
      }
      _heightImperial = !_heightImperial;
    });
  }

  void _toggleWeightUnit() {
    setState(() {
      final val = double.tryParse(_weightController.text.trim());
      if (val != null) {
        _weightController.text = _fmtNum(_weightImperial ? val / 2.20462 : val * 2.20462);
      }
      _weightImperial = !_weightImperial;
    });
  }

  double? _canonicalHeightCm() {
    if (_heightImperial) {
      final ft = double.tryParse(_heightFtController.text.trim()) ?? 0;
      final inch = double.tryParse(_heightInController.text.trim()) ?? 0;
      final totalInches = ft * 12 + inch;
      return totalInches > 0 ? totalInches * 2.54 : null;
    }
    return double.tryParse(_heightCmController.text.trim());
  }

  double? _canonicalWeightKg() {
    final val = double.tryParse(_weightController.text.trim());
    if (val == null) return null;
    return _weightImperial ? val / 2.20462 : val;
  }

  Future<void> _loadPhoto() async {
    final file = await ProfilePhotoService.getExisting(Session.userId!);
    if (mounted) setState(() => _photoFile = file);
  }

  Future<void> _handlePickPhoto() async {
    setState(() => _isPickingPhoto = true);
    try {
      final file = await ProfilePhotoService.pickAndSave(Session.userId!);
      if (file != null && mounted) setState(() => _photoFile = file);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open gallery: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      final user = await _apiService.updateProfile(
        Session.userId!,
        _nameController.text.trim(),
        _emailController.text.trim(),
        age: int.tryParse(_ageController.text.trim()),
        biologicalSex: _biologicalSex,
        heightCm: _canonicalHeightCm(),
        weightKg: _canonicalWeightKg(),
      );
      Session.setUser(
        Session.userId!,
        _nameController.text.trim(),
        _emailController.text.trim(),
        username: Session.username,
        memberSince: Session.memberSince,
        age: user.age,
        biologicalSex: user.biologicalSex,
        heightCm: user.heightCm,
        weightKg: user.weightKg,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _handleLogout() {
    Session.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          Future<void> submit() async {
            if (currentController.text.isEmpty || newController.text.isEmpty) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('Fill in both fields'), backgroundColor: Colors.red),
              );
              return;
            }
            if (newController.text.length < 6) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('New password must be at least 6 characters'), backgroundColor: Colors.red),
              );
              return;
            }
            setDialogState(() => isSubmitting = true);
            try {
              await _apiService.changePassword(Session.userId!, currentController.text, newController.text);
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password changed'), backgroundColor: Colors.green),
                );
              }
            } catch (e) {
              setDialogState(() => isSubmitting = false);
              if (mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
                );
              }
            }
          }

          return AlertDialog(
            title: const Text('Change Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Current password'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New password'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: isSubmitting ? null : submit,
                child: isSubmitting
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleDeleteAccount() async {
    final confirmController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final canDelete = confirmController.text.trim().toUpperCase() == 'DELETE';
          return AlertDialog(
            title: const Text('Delete account?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This permanently deletes your account, along with every workout and goal you\'ve logged. This cannot be undone.',
                ),
                const SizedBox(height: 16),
                Text.rich(
                  TextSpan(
                    text: 'Type ',
                    children: [
                      const TextSpan(text: 'DELETE', style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: ' to confirm.'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmController,
                  textCapitalization: TextCapitalization.characters,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'DELETE'),
                  onChanged: (_) => setDialogState(() {}),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(
                onPressed: canDelete ? () => Navigator.pop(ctx, true) : null,
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      ),
    );
    if (confirmed != true) return;

    try {
      await _apiService.deleteAccount(Session.userId!);
      Session.clear();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
            Center(
              child: GestureDetector(
                onTap: _isPickingPhoto ? null : _handlePickPhoto,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: _photoFile != null ? FileImage(_photoFile!) : null,
                      child: _photoFile == null
                          ? Icon(Icons.person, size: 40, color: Theme.of(context).colorScheme.primary)
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                        ),
                        child: _isPickingPhoto
                            ? const SizedBox(
                                height: 12,
                                width: 12,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (Session.memberSinceLabel != null) ...[
              const SizedBox(height: 10),
              Center(
                child: Text(
                  Session.memberSinceLabel!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text('Full Name', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.badge_outlined)),
            ),
            const SizedBox(height: 16),
            const Text('Username', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              enabled: false,
              controller: TextEditingController(text: Session.username ?? ''),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.alternate_email),
                helperText: "Username can't be changed",
              ),
            ),
            const SizedBox(height: 16),
            const Text('Email Address', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                if (!_isSaving) _handleSave();
              },
              decoration: const InputDecoration(prefixIcon: Icon(Icons.mail_outline)),
            ),
            const SizedBox(height: 24),
            const Text('Body Metrics', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Age', prefixIcon: Icon(Icons.cake_outlined)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Male'),
                          selected: _biologicalSex == 'Male',
                          onSelected: (_) => setState(() => _biologicalSex = 'Male'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Female'),
                          selected: _biologicalSex == 'Female',
                          onSelected: (_) => setState(() => _biologicalSex = 'Female'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Height', style: TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton.icon(
                  onPressed: _toggleHeightUnit,
                  icon: const Icon(Icons.swap_horiz, size: 16),
                  label: Text(_heightImperial ? 'Switch to cm' : 'Switch to ft/in'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _heightImperial
                ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _heightFtController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'ft', prefixIcon: Icon(Icons.height)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _heightInController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'in'),
                        ),
                      ),
                    ],
                  )
                : TextField(
                    controller: _heightCmController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'cm', prefixIcon: Icon(Icons.height)),
                  ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Weight', style: TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton.icon(
                  onPressed: _toggleWeightUnit,
                  icon: const Icon(Icons.swap_horiz, size: 16),
                  label: Text(_weightImperial ? 'Switch to kg' : 'Switch to lbs'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: _weightImperial ? 'lbs' : 'kg',
                prefixIcon: const Icon(Icons.monitor_weight_outlined),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ValueListenableBuilder<ThemeMode>(
                  valueListenable: ThemeController.mode,
                  builder: (context, mode, _) {
                    return SwitchListTile(
                      title: const Text('Dark Mode'),
                      secondary: Icon(mode == ThemeMode.dark ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
                      value: mode == ThemeMode.dark,
                      onChanged: (value) => ThemeController.setDark(value),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.lock_reset_outlined),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showChangePasswordDialog,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Help & FAQ'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpFaqScreen())),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About & Legal'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutLegalScreen())),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _handleLogout,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Log Out'),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: _handleDeleteAccount,
                child: const Text('Delete Account', style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
            ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: GradientButton(
                onPressed: _isSaving ? null : _handleSave,
                isLoading: _isSaving,
                child: const Text('Save Changes'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}