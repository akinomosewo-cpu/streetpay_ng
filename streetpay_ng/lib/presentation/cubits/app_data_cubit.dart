import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/format_utils.dart';
import '../../data/app_repository.dart';
import '../../models/attendance.dart';
import '../../models/guard.dart';
import '../../models/household.dart';
import '../../models/payment.dart';

class AppDataState extends Equatable {
  final bool loading;
  final List<Household> households;
  final List<Payment> payments;
  final List<Guard> guards;
  final List<AttendanceRecord> attendance;

  const AppDataState({
    this.loading = true,
    this.households = const [],
    this.payments = const [],
    this.guards = const [],
    this.attendance = const [],
  });

  AppDataState copyWith({
    bool? loading,
    List<Household>? households,
    List<Payment>? payments,
    List<Guard>? guards,
    List<AttendanceRecord>? attendance,
  }) {
    return AppDataState(
      loading: loading ?? this.loading,
      households: households ?? this.households,
      payments: payments ?? this.payments,
      guards: guards ?? this.guards,
      attendance: attendance ?? this.attendance,
    );
  }

  @override
  List<Object?> get props => [loading, households, payments, guards, attendance];
}

/// Single source of truth for the app's data, backed by [AppRepository].
/// Kept as one cubit for simplicity since every feature reads and writes
/// across households, payments, guards and attendance together.
class AppDataCubit extends Cubit<AppDataState> {
  final AppRepository repository;
  final _uuid = const Uuid();

  AppDataCubit(this.repository) : super(const AppDataState());

  Future<void> load() async {
    await repository.init();
    emit(AppDataState(
      loading: false,
      households: repository.getHouseholds(),
      payments: repository.getPayments(),
      guards: repository.getGuards(),
      attendance: repository.getAttendance(),
    ));
  }

  Future<void> addHousehold({
    required String occupantName,
    required String houseNumber,
    required ResidentType type,
    String phone = '',
    int? monthlyDue,
  }) async {
    final household = Household(
      id: _uuid.v4(),
      occupantName: occupantName,
      houseNumber: houseNumber,
      type: type,
      phone: phone,
      monthlyDue: monthlyDue ?? Household.defaultDueFor(type),
      createdAt: DateTime.now(),
    );
    await repository.saveHousehold(household);
    emit(state.copyWith(households: [...state.households, household]));
  }

  Future<void> updateHousehold(Household household) async {
    await repository.saveHousehold(household);
    emit(state.copyWith(
      households: state.households.map((h) => h.id == household.id ? household : h).toList(),
    ));
  }

  Future<void> deleteHousehold(String id) async {
    await repository.deleteHousehold(id);
    emit(state.copyWith(
      households: state.households.where((h) => h.id != id).toList(),
      payments: state.payments.where((p) => p.householdId != id).toList(),
    ));
  }

  Future<void> recordPayment({
    required String householdId,
    required int amount,
    required String monthKey,
    PaymentMethod method = PaymentMethod.bankTransfer,
    String reference = '',
    DateTime? datePaid,
  }) async {
    final payment = Payment(
      id: _uuid.v4(),
      householdId: householdId,
      monthKey: monthKey,
      amount: amount,
      datePaid: datePaid ?? DateTime.now(),
      method: method,
      reference: reference,
    );
    await repository.savePayment(payment);
    emit(state.copyWith(payments: [...state.payments, payment]));
  }

  Future<void> deletePayment(String id) async {
    await repository.deletePayment(id);
    emit(state.copyWith(payments: state.payments.where((p) => p.id != id).toList()));
  }

  Future<void> addGuard({
    required String name,
    required int monthlySalary,
    String phone = '',
  }) async {
    final guard = Guard(
      id: _uuid.v4(),
      name: name,
      phone: phone,
      monthlySalary: monthlySalary,
      createdAt: DateTime.now(),
    );
    await repository.saveGuard(guard);
    emit(state.copyWith(guards: [...state.guards, guard]));
  }

  Future<void> updateGuard(Guard guard) async {
    await repository.saveGuard(guard);
    emit(state.copyWith(guards: state.guards.map((g) => g.id == guard.id ? guard : g).toList()));
  }

  Future<void> deleteGuard(String id) async {
    await repository.deleteGuard(id);
    emit(state.copyWith(
      guards: state.guards.where((g) => g.id != id).toList(),
      attendance: state.attendance.where((a) => a.guardId != id).toList(),
    ));
  }

  /// Toggles a guard's attendance for a given day, creating the record if
  /// it doesn't already exist.
  Future<void> setAttendance({
    required String guardId,
    required DateTime day,
    required bool present,
  }) async {
    final dayKey = FormatUtils.dayKey(day);
    final existing = state.attendance.where(
      (a) => a.guardId == guardId && a.dayKey == dayKey,
    );
    final record = AttendanceRecord(
      id: existing.isNotEmpty ? existing.first.id : _uuid.v4(),
      guardId: guardId,
      dayKey: dayKey,
      present: present,
    );
    await repository.saveAttendance(record);
    final updated = [
      for (final a in state.attendance)
        if (a.guardId != guardId || a.dayKey != dayKey) a,
      record,
    ];
    emit(state.copyWith(attendance: updated));
  }
}
