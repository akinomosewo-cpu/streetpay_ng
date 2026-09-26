import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/format_utils.dart';
import '../../services/payroll_service.dart';
import '../cubits/app_data_cubit.dart';
import 'attendance_page.dart';

class GuardsPage extends StatelessWidget {
  const GuardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const payrollService = PayrollService();
    final monthKey = FormatUtils.currentMonthKey();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Guards & payroll')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showEditSheet(context),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: BlocBuilder<AppDataCubit, AppDataState>(
        builder: (context, state) {
          if (state.guards.isEmpty) {
            return Center(
              child: Text('No guards yet. Tap + to add one.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: state.guards.length,
            separatorBuilder: (_, __) => const Gap(10),
            itemBuilder: (context, i) {
              final g = state.guards[i];
              final summary = payrollService.summaryFor(g, monthKey, state.attendance);
              return InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AttendancePage(guard: g)),
                ),
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
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.shield_outlined, color: AppColors.warning, size: 18),
                    ),
                    const Gap(14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(g.name, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                          Text(
                            '${summary.daysPresent} days present · ${FormatUtils.currency(summary.calculatedSalary)}',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 18),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => BlocProvider.value(
        value: context.read<AppDataCubit>(),
        child: const _GuardForm(),
      ),
    );
  }
}

class _GuardForm extends StatefulWidget {
  const _GuardForm();

  @override
  State<_GuardForm> createState() => _GuardFormState();
}

class _GuardFormState extends State<_GuardForm> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController(text: '40000');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _salaryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add guard', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary)),
          const Gap(20),
          TextField(
            controller: _nameCtrl,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'Guard name'),
          ),
          const Gap(12),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'Phone (optional)'),
          ),
          const Gap(12),
          TextField(
            controller: _salaryCtrl,
            keyboardType: TextInputType.number,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'Monthly salary (₦)'),
          ),
          const Gap(20),
          ElevatedButton(
            onPressed: () {
              final name = _nameCtrl.text.trim();
              if (name.isEmpty) return;
              final salary = int.tryParse(_salaryCtrl.text.trim()) ?? 0;
              context.read<AppDataCubit>().addGuard(
                    name: name,
                    monthlySalary: salary,
                    phone: _phoneCtrl.text.trim(),
                  );
              Navigator.pop(context);
            },
            child: const Text('Add guard'),
          ),
        ],
      ),
    );
  }
}
