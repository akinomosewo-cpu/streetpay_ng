import 'package:hive_flutter/hive_flutter.dart';

import '../models/attendance.dart';
import '../models/guard.dart';
import '../models/household.dart';
import '../models/payment.dart';

/// Thin persistence layer over Hive. Every entity is stored as a plain
/// Map<String, dynamic> keyed by its own id, so no generated TypeAdapters
/// are required.
class AppRepository {
  static const _householdsBox = 'households';
  static const _paymentsBox = 'payments';
  static const _guardsBox = 'guards';
  static const _attendanceBox = 'attendance';

  late Box _households;
  late Box _payments;
  late Box _guards;
  late Box _attendance;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _households = await Hive.openBox(_householdsBox);
    _payments = await Hive.openBox(_paymentsBox);
    _guards = await Hive.openBox(_guardsBox);
    _attendance = await Hive.openBox(_attendanceBox);
    _initialized = true;
  }

  // Households
  List<Household> getHouseholds() =>
      _households.values.map((e) => Household.fromMap(Map<dynamic, dynamic>.from(e))).toList();

  Future<void> saveHousehold(Household household) => _households.put(household.id, household.toMap());

  Future<void> deleteHousehold(String id) async {
    await _households.delete(id);
    final paymentIds = _payments.values
        .map((e) => Payment.fromMap(Map<dynamic, dynamic>.from(e)))
        .where((p) => p.householdId == id)
        .map((p) => p.id)
        .toList();
    for (final pid in paymentIds) {
      await _payments.delete(pid);
    }
  }

  // Payments
  List<Payment> getPayments() =>
      _payments.values.map((e) => Payment.fromMap(Map<dynamic, dynamic>.from(e))).toList();

  Future<void> savePayment(Payment payment) => _payments.put(payment.id, payment.toMap());

  Future<void> deletePayment(String id) => _payments.delete(id);

  // Guards
  List<Guard> getGuards() =>
      _guards.values.map((e) => Guard.fromMap(Map<dynamic, dynamic>.from(e))).toList();

  Future<void> saveGuard(Guard guard) => _guards.put(guard.id, guard.toMap());

  Future<void> deleteGuard(String id) async {
    await _guards.delete(id);
    final recordIds = _attendance.values
        .map((e) => AttendanceRecord.fromMap(Map<dynamic, dynamic>.from(e)))
        .where((a) => a.guardId == id)
        .map((a) => a.id)
        .toList();
    for (final rid in recordIds) {
      await _attendance.delete(rid);
    }
  }

  // Attendance
  List<AttendanceRecord> getAttendance() => _attendance.values
      .map((e) => AttendanceRecord.fromMap(Map<dynamic, dynamic>.from(e)))
      .toList();

  Future<void> saveAttendance(AttendanceRecord record) => _attendance.put(record.id, record.toMap());
}
