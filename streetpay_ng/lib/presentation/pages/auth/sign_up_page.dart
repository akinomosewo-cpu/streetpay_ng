import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../../core/navigation/page_transitions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/auth_repository.dart';
import '../dashboard_page.dart';
import 'login_page.dart';

/// Sign up screen for a street's treasurer. Since the app has no backend,
/// this creates a single local treasurer account stored in Hive.
class SignUpPage extends StatefulWidget {
  final AuthRepository authRepository;

  const SignUpPage({super.key, required this.authRepository});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _streetCtrl.dispose();
    _contactCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await widget.authRepository.signUp(
      treasurerName: _nameCtrl.text,
      streetName: _streetCtrl.text,
      contact: _contactCtrl.text,
      password: _passwordCtrl.text,
    );
    if (!mounted) return;
    if (result.success) {
      Navigator.of(context).pushAndRemoveUntil(
        FadeSlidePageRoute(builder: (_) => DashboardPage(authRepository: widget.authRepository)),
        (route) => false,
      );
    } else {
      setState(() {
        _busy = false;
        _error = result.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Set up your street', style: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary))
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.15, end: 0),
              const Gap(6),
              Text(
                'Create the treasurer account that manages levy collection and guard payroll.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ).animate().fadeIn(delay: 100.ms),
              const Gap(28),
              TextField(
                key: const Key('signup_name_field'),
                controller: _nameCtrl,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                decoration: const InputDecoration(hintText: 'Treasurer full name'),
              ).animate().fadeIn(delay: 150.ms).slideX(begin: 0.05, end: 0),
              const Gap(12),
              TextField(
                key: const Key('signup_street_field'),
                controller: _streetCtrl,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                decoration: const InputDecoration(hintText: 'Street / estate name'),
              ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.05, end: 0),
              const Gap(12),
              TextField(
                key: const Key('signup_contact_field'),
                controller: _contactCtrl,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                decoration: const InputDecoration(hintText: 'Phone number or email'),
              ).animate().fadeIn(delay: 250.ms).slideX(begin: 0.05, end: 0),
              const Gap(12),
              TextField(
                key: const Key('signup_password_field'),
                controller: _passwordCtrl,
                obscureText: true,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                decoration: const InputDecoration(hintText: 'Password (min. 4 characters)'),
              ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.05, end: 0),
              if (_error != null) ...[
                const Gap(12),
                Text(_error!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger))
                    .animate()
                    .shake(duration: 300.ms),
              ],
              const Gap(24),
              ElevatedButton(
                key: const Key('signup_submit_button'),
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text('Create account'),
              ).animate().fadeIn(delay: 350.ms),
              const Gap(16),
              Center(
                child: TextButton(
                  onPressed: _busy
                      ? null
                      : () => Navigator.of(context).pushReplacement(
                            FadeSlidePageRoute(
                              builder: (_) => LoginPage(authRepository: widget.authRepository),
                            ),
                          ),
                  child: const Text('Already have an account? Log in'),
                ),
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
