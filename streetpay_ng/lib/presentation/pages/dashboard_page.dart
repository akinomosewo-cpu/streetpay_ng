import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/format_utils.dart';
import '../../services/payment_service.dart';
import '../../services/payroll_service.dart';
import '../cubits/app_data_cubit.dart';
import 'guards_page.dart';
import 'households_page.dart';
import 'payments_board_page.dart';
import 'public_view_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
                          label: 'Collected',
                          value: FormatUtils.currency(collection.totalCollected),
                          color: AppColors.success,
                        ),
                        const Gap(12),
                        _StatCard(
                          label: 'Outstanding',
                          value: FormatUtils.currency(collection.totalOutstanding),
                          color: AppColors.danger,
                        ),
                      ]),
                      const Gap(12),
                      Row(children: [
                        _StatCard(
                          label: 'Households paid',
                          value: '${collection.paidCount}/${state.households.length}',
                          color: AppColors.primary,
                        ),
                        const Gap(12),
                        _StatCard(
                          label: 'Guard payroll due',
                          value: FormatUtils.currency(payroll.totalPayroll),
                          color: AppColors.warning,
                        ),
                      ]),
                      const Gap(24),
                      Text('Manage', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
                      const Gap(12),
                      _NavCard(
                        icon: Icons.home_work_outlined,
                        label: 'Households',
                        subtitle: '${state.households.length} registered',
                        color: AppColors.primary,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HouseholdsPage()),
                        ),
                      ),
                      const Gap(8),
                      _NavCard(
                        icon: Icons.receipt_long_outlined,
                        label: 'Payment status board',
                        subtitle:
                            '${collection.paidCount} paid · ${collection.partialCount} partial · ${collection.unpaidCount} unpaid',
                        color: AppColors.success,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PaymentsBoardPage()),
                        ),
                      ),
                      const Gap(8),
                      _NavCard(
                        icon: Icons.shield_outlined,
                        label: 'Guards & payroll',
                        subtitle: '${state.guards.length} on roster',
                        color: AppColors.warning,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const GuardsPage()),
                        ),
                      ),
                      const Gap(8),
                      _NavCard(
                        icon: Icons.public_outlined,
                        label: 'Public transparency view',
                        subtitle: 'Share who has paid this month',
                        color: AppColors.info,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PublicViewPage()),
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
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: AppTextStyles.headlineLarge.copyWith(color: color, fontWeight: FontWeight.w800)),
              const Gap(4),
              Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _NavCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                  const Gap(2),
                  Text(subtitle, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 18),
          ]),
        ),
      );
}
