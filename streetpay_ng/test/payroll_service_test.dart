import 'package:flutter_test/flutter_test.dart';
import 'package:streetpay_ng/models/attendance.dart';
import 'package:streetpay_ng/models/guard.dart';
import 'package:streetpay_ng/services/payroll_service.dart';

Guard _guard({String id = 'g1', int salary = 26000}) {
  return Guard(
    id: id,
    name: 'Test Guard',
    monthlySalary: salary,
    createdAt: DateTime(2026, 1, 1),
  );
}

List<AttendanceRecord> _attendanceDays(String guardId, String monthKey, int presentDays, {int absentDays = 0}) {
  final records = <AttendanceRecord>[];
  for (var d = 1; d <= presentDays; d++) {
    records.add(AttendanceRecord(
      id: '${guardId}_p$d',
      guardId: guardId,
      dayKey: '$monthKey-${d.toString().padLeft(2, '0')}',
      present: true,
    ));
  }
  for (var d = 1; d <= absentDays; d++) {
    records.add(AttendanceRecord(
      id: '${guardId}_a$d',
      guardId: guardId,
      dayKey: '$monthKey-${(presentDays + d).toString().padLeft(2, '0')}',
      present: false,
    ));
  }
  return records;
}

void main() {
  const service = PayrollService();

  group('dailyRate', () {
    test('is monthlySalary divided by the standard working days', () {
      final guard = _guard(salary: 26000);
      expect(guard.dailyRate, 26000 / Guard.standardWorkingDays);
    });
  });

  group('calculateSalary', () {
    final guard = _guard(salary: 26000); // dailyRate = 1000

    test('zero days present pays nothing', () {
      expect(service.calculateSalary(guard, 0), 0);
    });

    test('negative days present is treated as nothing', () {
      expect(service.calculateSalary(guard, -3), 0);
    });

    test('pro-rates pay below the standard working days threshold', () {
      expect(service.calculateSalary(guard, 13), 13000);
    });

    test('pays the full salary once the standard threshold is hit', () {
      expect(service.calculateSalary(guard, Guard.standardWorkingDays), 26000);
    });

    test('caps pay at the full monthly salary beyond the threshold', () {
      expect(service.calculateSalary(guard, Guard.standardWorkingDays + 4), 26000);
    });
  });

  group('summaryFor', () {
    test('counts present and absent days for the requested month only', () {
      final guard = _guard(id: 'g1', salary: 26000);
      final attendance = [
        ..._attendanceDays('g1', '2026-09', 10, absentDays: 3),
        ..._attendanceDays('g1', '2026-08', 20), // different month, should be ignored
      ];
      final summary = service.summaryFor(guard, '2026-09', attendance);
      expect(summary.daysPresent, 10);
      expect(summary.daysAbsent, 3);
      expect(summary.calculatedSalary, service.calculateSalary(guard, 10));
    });

    test('ignores another guard\'s attendance records', () {
      final guard = _guard(id: 'g1');
      final attendance = _attendanceDays('g2', '2026-09', 15);
      final summary = service.summaryFor(guard, '2026-09', attendance);
      expect(summary.daysPresent, 0);
      expect(summary.calculatedSalary, 0);
    });
  });

  group('payrollSummary', () {
    test('sums calculated salary across all guards', () {
      final g1 = _guard(id: 'g1', salary: 26000); // full month -> 26000
      final g2 = _guard(id: 'g2', salary: 20000); // half month -> ~10000 (dailyRate*13)
      final attendance = [
        ..._attendanceDays('g1', '2026-09', Guard.standardWorkingDays),
        ..._attendanceDays('g2', '2026-09', 13),
      ];
      final summary = service.payrollSummary([g1, g2], attendance, '2026-09');
      final expectedG2 = (g2.dailyRate * 13).round();
      expect(summary.totalPayroll, 26000 + expectedG2);
      expect(summary.guards.length, 2);
    });

    test('total payroll is 0 when there are no guards', () {
      final summary = service.payrollSummary(const [], const [], '2026-09');
      expect(summary.totalPayroll, 0);
    });
  });
}
