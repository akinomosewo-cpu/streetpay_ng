import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../../core/navigation/page_transitions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/auth_repository.dart';
import '../dashboard_page.dart';
import 'login_page.dart';
import 'sign_up_page.dart';

/// Animated brand splash, shown briefly on launch while it checks whether
/// a treasurer account already exists and is logged in, then routes to the
/// dashboard, login or sign up screen accordingly.
class SplashPage extends StatefulWidget {
  final AuthRepository authRepository;

  const SplashPage({super.key, required this.authRepository});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final auth = widget.authRepository;
    await auth.init();
    // Minimum splash duration so the brand reveal always gets to play,
    // even if init resolves instantly.
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final Widget destination = auth.hasAccount && auth.isLoggedIn
        ? DashboardPage(authRepository: auth)
        : auth.hasAccount
            ? LoginPage(authRepository: auth)
            : SignUpPage(authRepository: auth);

    Navigator.of(context).pushReplacement(
      FadeSlidePageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppColors.cardShadow,
              ),
              child: const Icon(Icons.security_rounded, color: Colors.white, size: 44),
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 300.ms),
            const Gap(20),
            Text(
              'StreetPay NG',
              style: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary),
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),
            const Gap(8),
            Text(
              'Levy collection & guard payroll',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
