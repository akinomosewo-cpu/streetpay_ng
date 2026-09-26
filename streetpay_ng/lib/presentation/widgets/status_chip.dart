import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/payment_service.dart';

class StatusChip extends StatelessWidget {
  final PaymentStatus status;
  const StatusChip({super.key, required this.status});

  Color get _color {
    switch (status) {
      case PaymentStatus.paid:
        return AppColors.success;
      case PaymentStatus.partial:
        return AppColors.warning;
      case PaymentStatus.unpaid:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.labelSmall.copyWith(color: _color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
