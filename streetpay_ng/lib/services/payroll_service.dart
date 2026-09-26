import '../models/attendance.dart';
import '../models/guard.dart';

/// Per-guard payroll result for a given month.
class GuardMonthSummary {
  final Guard guard;
  final int daysPresent;
  final int daysAbsent;
  final int calculatedSalary;

  const GuardMonthSummary({
    required this.guard,
    required this.daysPresent,
    required this.daysAbsent,
    required this.calculatedSalary,
  });
}

/// Street-wide payroll totals for a given month.
class PayrollSummary {
  final String monthKey;
  final List<GuardMonthSummary> guards;

  const PayrollSummary({required this.monthKey, required this.guards});

  int get totalPayroll => guards.fold(0, (sum, g) => sum + g.calculatedSalary);
}

/// Pure, side-effect-free guard salary calculations based on attendance.
/// A guard earns a full month's salary once they hit
/// [Guard.standardWorkingDays] days present; otherwise pay is pro-rated
/// by the daily rate. Kept Flutter-free so it is easily unit tested.
class PayrollService {
  const PayrollService();

  List<AttendanceRecord> _recordsFor(
    String guardId,
    String monthKey,
    List<AttendanceRecord> attendance,
  ) {
    return attendance
        .where((a) => a.guardId == guardId && a.monthKey == monthKey)
        .toList(growable: false);
  }

  int daysPresentFor(String guardId, String monthKey, List<AttendanceRecord> attendance) {
    return _recordsFor(guardId, monthKey, attendance).where((a) => a.present).length;
  }

  /// Salary owed for a guard given how many days they were marked present.
  /// Pro-rated below the standard working-day threshold, capped at the
  /// full monthly salary once the threshold is met or exceeded.
  int calculateSalary(Guard guard, int daysPresent) {
    if (daysPresent <= 0) return 0;
    if (daysPresent >= Guard.standardWorkingDays) return guard.monthlySalary;
    return (guard.dailyRate * daysPresent).round();
  }

  GuardMonthSummary summaryFor(
    Guard guard,
    String monthKey,
    List<AttendanceRecord> attendance,
  ) {
    final records = _recordsFor(guard.id, monthKey, attendance);
    final present = records.where((a) => a.present).length;
    final absent = records.where((a) => !a.present).length;
    return GuardMonthSummary(
      guard: guard,
      daysPresent: present,
      daysAbsent: absent,
      calculatedSalary: calculateSalary(guard, present),
    );
  }

  PayrollSummary payrollSummary(
    List<Guard> guards,
    List<AttendanceRecord> attendance,
    String monthKey,
  ) {
    final rows = guards
        .map((g) => summaryFor(g, monthKey, attendance))
        .toList(growable: false);
    return PayrollSummary(monthKey: monthKey, guards: rows);
  }
}
