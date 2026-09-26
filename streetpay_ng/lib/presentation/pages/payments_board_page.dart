import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/format_utils.dart';
import '../../models/payment.dart';
import '../../services/payment_service.dart';
import '../cubits/app_data_cubit.dart';
import '../widgets/month_selector.dart';
import '../widgets/status_chip.dart';

class PaymentsBoardPage extends StatefulWidget {
  const PaymentsBoardPage({super.key});

  @override
  State<PaymentsBoardPage> createState() => _PaymentsBoardPageState();
}

class _PaymentsBoardPageState extends State<PaymentsBoardPage> {
  String monthKey = FormatUtils.currentMonthKey();

  @override
  Widget build(BuildContext context) {
    const service = PaymentService();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Payment status board')),
      body: BlocBuilder<AppDataCubit, AppDataState>(
        builder: (context, state) {
          final summary = service.collectionSummary(state.households, state.payments, monthKey);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MonthSelector(monthKey: monthKey, onChanged: (m) => setState(() => monthKey = m)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(FormatUtils.currency(summary.totalCollected),
                            style: AppTextStyles.headlineLarge.copyWith(color: AppColors.success, fontWeight: FontWeight.w800)),
                        Text('of ${FormatUtils.currency(summary.totalExpected)} expected',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              if (summary.households.isEmpty)
                Expanded(
                  child: Center(
                    child: Text('Register households first.',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: summary.households.length,
                    separatorBuilder: (_, __) => const Gap(12),
                    itemBuilder: (context, i) {
                      final row = summary.households[i];
                      return InkWell(
                        onTap: () => _showRecordPaymentSheet(context, row.household.id, row.outstanding),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: Row(children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${row.household.houseNumber} · ${row.household.occupantName}',
                                      style:
                                          AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
                                  const Gap(4),
                                  Text(
                                    '${FormatUtils.currency(row.amountPaid)} of ${FormatUtils.currency(row.amountDue)}',
                                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            StatusChip(status: row.status),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
              const Gap(12),
            ],
          );
        },
      ),
    );
  }

  void _showRecordPaymentSheet(BuildContext context, String householdId, int outstanding) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => BlocProvider.value(
        value: context.read<AppDataCubit>(),
        child: _RecordPaymentSheet(householdId: householdId, monthKey: monthKey, suggested: outstanding),
      ),
    );
  }
}

class _RecordPaymentSheet extends StatefulWidget {
  final String householdId;
  final String monthKey;
  final int suggested;
  const _RecordPaymentSheet({required this.householdId, required this.monthKey, required this.suggested});

  @override
  State<_RecordPaymentSheet> createState() => _RecordPaymentSheetState();
}

class _RecordPaymentSheetState extends State<_RecordPaymentSheet> {
  late final TextEditingController _amountCtrl;
  PaymentMethod _method = PaymentMethod.bankTransfer;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: widget.suggested > 0 ? widget.suggested.toString() : '',
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
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
          Text('Record payment', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary)),
          const Gap(4),
          Text(FormatUtils.monthLabel(widget.monthKey),
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
          const Gap(20),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'Amount received (₦)'),
          ),
          const Gap(12),
          Wrap(
            spacing: 8,
            children: PaymentMethod.values.map((m) {
              final selected = m == _method;
              return ChoiceChip(
                label: Text(m.label),
                selected: selected,
                onSelected: (_) => setState(() => _method = m),
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                labelStyle: AppTextStyles.labelMedium.copyWith(
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
                backgroundColor: AppColors.surfaceElevated,
                side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
              );
            }).toList(),
          ),
          const Gap(20),
          ElevatedButton(
            onPressed: () async {
              final amount = int.tryParse(_amountCtrl.text.trim()) ?? 0;
              if (amount <= 0) return;
              context.read<AppDataCubit>().recordPayment(
                    householdId: widget.householdId,
                    amount: amount,
                    monthKey: widget.monthKey,
                    method: _method,
                  );
              Navigator.pop(context);
              await showPaymentRecordedAnimation(context, amount: amount);
            },
            child: const Text('Save payment'),
          ),
        ],
      ),
    );
  }
}

/// Shows a brief, non-blocking "payment recorded" celebration: a checkmark
/// that scales in and a total that counts up from zero, then dismisses
/// itself automatically.
Future<void> showPaymentRecordedAnimation(BuildContext context, {required int amount}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Payment recorded',
    barrierColor: Colors.black26,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      Future.delayed(const Duration(milliseconds: 1300), () {
        if (context.mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
      return _PaymentRecordedOverlay(amount: amount);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class _PaymentRecordedOverlay extends StatelessWidget {
  final int amount;
  const _PaymentRecordedOverlay({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 48),
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
            )
                .animate()
                .scale(
                  begin: const Offset(0.2, 0.2),
                  end: const Offset(1, 1),
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 150.ms),
            const Gap(16),
            Text('Payment recorded', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary))
                .animate()
                .fadeIn(delay: 150.ms),
            const Gap(6),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: amount.toDouble()),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => Text(
                FormatUtils.currency(value.round()),
                style: AppTextStyles.headlineLarge.copyWith(color: AppColors.success, fontWeight: FontWeight.w800),
              ),
            ).animate().fadeIn(delay: 200.ms),
          ],
        ),
      ),
    );
  }
}
