import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/format_utils.dart';

class MonthSelector extends StatelessWidget {
  final String monthKey;
  final ValueChanged<String> onChanged;
  const MonthSelector({super.key, required this.monthKey, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary),
            onPressed: () => onChanged(FormatUtils.shiftMonth(monthKey, -1)),
          ),
          Text(
            FormatUtils.monthLabel(monthKey),
            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            onPressed: () => onChanged(FormatUtils.shiftMonth(monthKey, 1)),
          ),
        ],
      ),
    );
  }
}
