import 'package:equatable/equatable.dart';

/// A security guard on the street's payroll.
class Guard extends Equatable {
  final String id;
  final String name;
  final String phone;

  /// Full monthly salary in naira, paid when the guard is present for
  /// [standardWorkingDays] or more in the month.
  final int monthlySalary;
  final DateTime createdAt;

  const Guard({
    required this.id,
    required this.name,
    required this.monthlySalary,
    this.phone = '',
    required this.createdAt,
  });

  /// Standard number of working days used to derive a daily rate.
  static const int standardWorkingDays = 26;

  double get dailyRate => monthlySalary / standardWorkingDays;

  Guard copyWith({String? name, String? phone, int? monthlySalary}) => Guard(
        id: id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        monthlySalary: monthlySalary ?? this.monthlySalary,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'monthlySalary': monthlySalary,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Guard.fromMap(Map<dynamic, dynamic> map) => Guard(
        id: map['id'] as String,
        name: map['name'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        monthlySalary: (map['monthlySalary'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      );

  @override
  List<Object?> get props => [id, name, phone, monthlySalary, createdAt];
}
