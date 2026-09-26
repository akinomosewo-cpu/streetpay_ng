import 'package:flutter_test/flutter_test.dart';
import 'package:streetpay_ng/core/utils/format_utils.dart';

void main() {
  group('shiftMonth', () {
    test('moves forward within the same year', () {
      expect(FormatUtils.shiftMonth('2026-01', 2), '2026-03');
    });

    test('rolls over into the next year', () {
      expect(FormatUtils.shiftMonth('2026-11', 2), '2027-01');
    });

    test('rolls back into the previous year', () {
      expect(FormatUtils.shiftMonth('2026-01', -1), '2025-12');
    });
  });

  group('monthLabel', () {
    test('formats a month key as a readable label', () {
      expect(FormatUtils.monthLabel('2026-09'), 'September 2026');
    });
  });

  group('currency', () {
    test('formats whole naira amounts with no decimals', () {
      expect(FormatUtils.currency(2500), '₦2,500');
    });
  });
}
