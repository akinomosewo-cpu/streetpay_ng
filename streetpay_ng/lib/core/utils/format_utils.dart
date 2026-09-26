import 'package:intl/intl.dart';

/// Shared formatting helpers used across the app.
class FormatUtils {
  FormatUtils._();

  static final NumberFormat _naira = NumberFormat.currency(
    locale: 'en_NG',
    symbol: '₦',
    decimalDigits: 0,
  );

  /// Formats an amount in kobo-free naira, e.g. 2500 -> "₦2,500".
  static String currency(num amount) => _naira.format(amount);

  /// Returns the canonical month key for [date], e.g. "2026-09".
  static String monthKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';

  /// The current month's key.
  static String currentMonthKey() => monthKey(DateTime.now());

  /// Returns the canonical day key for [date], e.g. "2026-09-26".
  static String dayKey(DateTime date) =>
      '${monthKey(date)}-${date.day.toString().padLeft(2, '0')}';

  /// Turns a month key like "2026-09" into "September 2026".
  static String monthLabel(String monthKey) {
    final parts = monthKey.split('-');
    if (parts.length != 2) return monthKey;
    final year = int.tryParse(parts[0]) ?? DateTime.now().year;
    final month = int.tryParse(parts[1]) ?? 1;
    return DateFormat('MMMM yyyy').format(DateTime(year, month));
  }

  /// Shifts [monthKey] by [delta] whole months.
  static String shiftMonth(String monthKey, int delta) {
    final parts = monthKey.split('-');
    final year = int.tryParse(parts[0]) ?? DateTime.now().year;
    final month = int.tryParse(parts[1]) ?? 1;
    final total = (year * 12 + (month - 1)) + delta;
    final newYear = total ~/ 12;
    final newMonth = (total % 12) + 1;
    return '${newYear.toString().padLeft(4, '0')}-${newMonth.toString().padLeft(2, '0')}';
  }

  static String shortDate(DateTime date) => DateFormat('d MMM yyyy').format(date);
}
