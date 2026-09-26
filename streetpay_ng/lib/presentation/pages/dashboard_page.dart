import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../core/navigation/page_transitions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format_utils.dart';
import '../../data/auth_repository.dart';
import '../../services/payment_service.dart';
import '../../services/payroll_service.dart';
import '../cubits/app_data_cubit.dart';
import 'auth/login_page.dart';
import 'guards_page.dart';
import 'households_page.dart';
import 'payments_board_page.dart';
import 'public_view_page.dart';

class DashboardPage extends StatelessWidget {
  /// Injectable so tests can supply a fake auth repository for logout.
  final AuthRepository? authRepository;

  const DashboardPage({super.key, this.authRepository});

  Future<void> _logout(BuildContext context) async {
    final auth = authRepository ?? AuthRepository();
    await auth.init();
    await auth.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      FadeSlidePageRoute(builder: (_) => LoginPage(authRepository: auth)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthKey = FormatUtils.currentMonthKey();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<AppDataCubit, AppDataState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            const paymentService = PaymentService();
            const payrollService = PayrollService();
            final collection = paymentService.collectionSummary(
              state.households,
              state.payments,
              monthKey,
            );
            final payroll = payrollService.payrollSummary(
              state.guards,
              state.attendance,
              monthKey,
            );

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  backgroundColor: AppColors.background,
                  title: Row(children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.security_rounded, color: Colors.white, size: 17),
                    ),
                    const Gap(10),
                    Text('StreetPay NG',
                        style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary)),
                  ]),
                  actions: [
                    IconButton(
                      key: const Key('logout_button'),
                      tooltip: 'Log out',
                      icon: const Icon(Icons.logout_rounded),
                      onPressed: () => _logout(context),
                    ),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const Gap(4),
                      Text(FormatUtils.monthLabel(monthKey),
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                      const Gap(16),
                      Row(children: [
                        _StatCard(
                          index: 0,
                          label: 'Collected',
                          value: FormatUtils.currency(collection.totalCollected),
                          numericValue: collection.totalCollected,
                          color: AppColors.success,
                        ),
                        const Gap(12),
                        _StatCard(
                          index: 1,
                          label: 'Outstanding',
                          value: FormatUtils.currency(collection.totalOutstanding),
                          numericValue: collection.totalOutstanding,
                          color: AppColors.danger,
                        ),
                      ]),
                      const Gap(12),
                      Row(children: [
                        _StatCard(
                          index: 2,
                          label: 'Households paid',
                          value: '${collection.paidCount}/${state.households.length}',
                          color: AppColors.primary,
                        ),
                        const Gap(12),
                        _StatCard(
                          index: 3,
                          label: 'Guard payroll due',
                          value: FormatUtils.currency(payroll.totalPayroll),
                          numericValue: payroll.totalPayroll,
                          color: AppColors.warning,
                        ),
                      ]),
                      const Gap(24),
                      Text('Manage', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary)),
                      const Gap(12),
                      _NavCard(
                        index: 0,
                        icon: Icons.home_work_outlined,
                        label: 'Households',
                        subtitle: '${state.households.length} registered',
                        color: AppColors.primary,
                        onTap: () => Navigator.push(
                          context,
                          FadeSlidePageRoute(builder: (_) => const HouseholdsPage()),
                        ),
                      ),
                      const Gap(8),
                      _NavCard(
                        index: 1,
                        icon: Icons.receipt_long_outlined,
                        label: 'Payment status board',
                        subtitle:
                            '${collection.paidCount} paid · ${collection.partialCount} partial · ${collection.unpaidCount} unpaid',
                        color: AppColors.success,
                        onTap: () => Navigator.push(
                          context,
                          FadeSlidePageRoute(builder: (_) => const PaymentsBoardPage()),
                        ),
                      ),
                      const Gap(8),
                      _NavCard(
                        index: 2,
                        icon: Icons.shield_outlined,
                        label: 'Guards & payroll',
                        subtitle: '${state.guards.length} on roster',
                        color: AppColors.warning,
                        onTap: () => Navigator.push(
                          context,
                          FadeSlidePageRoute(builder: (_) => const GuardsPage()),
                        ),
                      ),
                      const Gap(8),
                      _NavCard(
                        index: 3,
                        icon: Icons.public_outlined,
                        label: 'Public transparency view',
                        subtitle: 'Share who has paid this month',
                        color: AppColors.info,
                        onTap: () => Navigator.push(
                          context,
                          FadeSlidePageRoute(builder: (_) => const PublicViewPage()),
                        ),
                      ),
                      const Gap(32),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final int index;
  final String label;
  final String value;
  final int? numericValue;
  final Color color;
  const _StatCard({
    required this.index,
    required this.label,
    required this.value,
    required this.color,
    this.numericValue,
  });

  @override
  Widget build(BuildContext context) {
    final valueWidget = numericValue != null
        ? TweenAnimationBuilder<double>(
            key: ValueKey(numericValue),
            tween: Tween<double>(begin: 0, end: numericValue!.toDouble()),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, animated, _) => Text(
              FormatUtils.currency(animated.round()),
              style: AppTextStyles.headlineLarge.copyWith(color: color, fontWeight: FontWeight.w800),
            ),
          )
        : Text(value, style: AppTextStyles.headlineLarge.copyWith(color: color, fontWeight: FontWeight.w800));

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            valueWidget,
            const Gap(4),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 60 * index))
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic);
  }
}

class _NavCard extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _NavCard({
    required this.index,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 20),
            ),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  const Gap(2),
                  Text(subtitle, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
          ]),
        ),
      )
          .animate(delay: Duration(milliseconds: 250 + 60 * index))
          .fadeIn(duration: 350.ms)
          .slideX(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
}
