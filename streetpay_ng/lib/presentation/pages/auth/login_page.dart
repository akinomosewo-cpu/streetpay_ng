import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../../core/navigation/page_transitions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/auth_repository.dart';
import '../dashboard_page.dart';
import 'sign_up_page.dart';

class LoginPage extends StatefulWidget {
  final AuthRepository authRepository;

  const LoginPage({super.key, required this.authRepository});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _contactCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _contactCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await widget.authRepository.login(
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
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.security_rounded, color: Colors.white, size: 28),
              ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.8, 0.8)),
              const Gap(24),
              Text('Welcome back', style: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary))
                  .animate()
                  .fadeIn(delay: 100.ms)
                  .slideY(begin: 0.15, end: 0),
              const Gap(6),
              Text(
                'Log in to manage your street\'s levy and payroll.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ).animate().fadeIn(delay: 150.ms),
              const Gap(32),
              TextField(
                key: const Key('login_contact_field'),
                controller: _contactCtrl,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                decoration: const InputDecoration(hintText: 'Phone number or email'),
              ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.05, end: 0),
              const Gap(12),
              TextField(
                key: const Key('login_password_field'),
                controller: _passwordCtrl,
                obscureText: true,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                decoration: const InputDecoration(hintText: 'Password'),
              ).animate().fadeIn(delay: 250.ms).slideX(begin: 0.05, end: 0),
              if (_error != null) ...[
                const Gap(12),
                Text(_error!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger))
                    .animate()
                    .shake(duration: 300.ms),
              ],
              const Gap(24),
              ElevatedButton(
                key: const Key('login_submit_button'),
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text('Log in'),
              ).animate().fadeIn(delay: 300.ms),
              const Gap(16),
              Center(
                child: TextButton(
                  onPressed: _busy
                      ? null
                      : () => Navigator.of(context).pushReplacement(
                            FadeSlidePageRoute(
                              builder: (_) => SignUpPage(authRepository: widget.authRepository),
                            ),
                          ),
                  child: const Text('New street? Set up an account'),
                ),
              ).animate().fadeIn(delay: 350.ms),
            ],
          ),
        ),
      ),
    );
  }
}
