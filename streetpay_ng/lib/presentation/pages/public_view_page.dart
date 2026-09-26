import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/format_utils.dart';
import '../../services/payment_service.dart';
import '../cubits/app_data_cubit.dart';
import '../widgets/month_selector.dart';
import '../widgets/status_chip.dart';

/// A read-only board meant to be displayed publicly (e.g. printed and
/// pinned at the street gate, or shared to the residents' WhatsApp group)
/// to create social pressure around unpaid dues. It intentionally shows
/// no phone numbers and no editing controls.
class PublicViewPage extends StatefulWidget {
  const PublicViewPage({super.key});

  @override
  State<PublicViewPage> createState() => _PublicViewPageState();
}

class _PublicViewPageState extends State<PublicViewPage> {
  String monthKey = FormatUtils.currentMonthKey();

  @override
  Widget build(BuildContext context) {
    const service = PaymentService();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Public transparency board'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: () => _share(context, service),
          ),
        ],
      ),
      body: BlocBuilder<AppDataCubit, AppDataState>(
        builder: (context, state) {
          final summary = service.collectionSummary(state.households, state.payments, monthKey);
          final sorted = [...summary.households]
            ..sort((a, b) => a.household.houseNumber.compareTo(b.household.houseNumber));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    MonthSelector(monthKey: monthKey, onChanged: (m) => setState(() => monthKey = m)),
                    const Gap(12),
                    Text(
                      '${summary.paidCount} of ${summary.households.length} households have paid '
                      '(${(summary.collectionRate * 100).toStringAsFixed(0)}%)',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: sorted.isEmpty
                    ? Center(
                        child: Text('Nothing to show yet.',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: sorted.length,
                        separatorBuilder: (_, __) => const Gap(8),
                        itemBuilder: (context, i) {
                          final row = sorted[i];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(children: [
                              Text('House ${row.household.houseNumber}',
                                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                              const Spacer(),
                              StatusChip(status: row.status),
                            ]),
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

  void _share(BuildContext context, PaymentService service) {
    final state = context.read<AppDataCubit>().state;
    final summary = service.collectionSummary(state.households, state.payments, monthKey);
    final sorted = [...summary.households]
      ..sort((a, b) => a.household.houseNumber.compareTo(b.household.houseNumber));
    final buffer = StringBuffer()
      ..writeln('StreetPay NG — ${FormatUtils.monthLabel(monthKey)}')
      ..writeln('${summary.paidCount}/${summary.households.length} households paid')
      ..writeln('');
    for (final row in sorted) {
      buffer.writeln('House ${row.household.houseNumber}: ${row.status.label}');
    }
    Share.share(buffer.toString());
  }
}
