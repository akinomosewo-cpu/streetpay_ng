import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/format_utils.dart';
import '../../models/guard.dart';
import '../../services/payroll_service.dart';
import '../cubits/app_data_cubit.dart';

class AttendancePage extends StatefulWidget {
  final Guard guard;
  const AttendancePage({super.key, required this.guard});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  int get _daysInMonth => DateTime(_month.year, _month.month + 1, 0).day;

  @override
  Widget build(BuildContext context) {
    const payrollService = PayrollService();
    final monthKey = FormatUtils.monthKey(_month);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(widget.guard.name)),
      body: BlocBuilder<AppDataCubit, AppDataState>(
        builder: (context, state) {
          final summary = payrollService.summaryFor(widget.guard, monthKey, state.attendance);
          final presentDays = state.attendance
              .where((a) => a.guardId == widget.guard.id && a.monthKey == monthKey && a.present)
              .map((a) => a.dayKey)
              .toSet();

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MiniStat(label: 'Present', value: '${summary.daysPresent}'),
                    _MiniStat(label: 'Absent', value: '${summary.daysAbsent}'),
                    _MiniStat(label: 'Salary due', value: FormatUtils.currency(summary.calculatedSalary)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(FormatUtils.monthLabel(monthKey),
                        style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
                    Row(children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary),
                        onPressed: () => setState(() => _month = DateTime(_month.year, _month.month - 1)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                        onPressed: () => setState(() => _month = DateTime(_month.year, _month.month + 1)),
                      ),
                    ]),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: _daysInMonth,
                  itemBuilder: (context, index) {
                    final day = DateTime(_month.year, _month.month, index + 1);
                    final key = FormatUtils.dayKey(day);
                    final present = presentDays.contains(key);
                    final isFuture = day.isAfter(DateTime.now());
                    return InkWell(
                      onTap: isFuture
                          ? null
                          : () => context.read<AppDataCubit>().setAttendance(
                                guardId: widget.guard.id,
                                day: day,
                                present: !present,
                              ),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isFuture
                              ? AppColors.surfaceElevated.withValues(alpha: 0.4)
                              : present
                                  ? AppColors.success.withValues(alpha: 0.18)
                                  : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: present ? AppColors.success : AppColors.border,
                          ),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: isFuture
                                ? AppColors.textTertiary
                                : present
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
        const Gap(2),
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
      ]);
}
