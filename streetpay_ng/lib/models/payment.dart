import 'package:equatable/equatable.dart';

enum PaymentMethod { bankTransfer, cash, pos }

extension PaymentMethodX on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.pos:
        return 'POS';
    }
  }

  static PaymentMethod fromName(String name) => PaymentMethod.values.firstWhere(
        (e) => e.name == name,
        orElse: () => PaymentMethod.bankTransfer,
      );
}

/// A single levy payment made by a household towards a given [monthKey]
/// (format "yyyy-MM"). Multiple partial payments can exist for one month;
/// the sum of all of them is what determines paid/partial/unpaid status.
class Payment extends Equatable {
  final String id;
  final String householdId;
  final String monthKey;
  final int amount;
  final DateTime datePaid;
  final PaymentMethod method;
  final String reference;

  const Payment({
    required this.id,
    required this.householdId,
    required this.monthKey,
    required this.amount,
    required this.datePaid,
    this.method = PaymentMethod.bankTransfer,
    this.reference = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'householdId': householdId,
        'monthKey': monthKey,
        'amount': amount,
        'datePaid': datePaid.toIso8601String(),
        'method': method.name,
        'reference': reference,
      };

  factory Payment.fromMap(Map<dynamic, dynamic> map) => Payment(
        id: map['id'] as String,
        householdId: map['householdId'] as String,
        monthKey: map['monthKey'] as String,
        amount: (map['amount'] as num?)?.toInt() ?? 0,
        datePaid: DateTime.tryParse(map['datePaid'] as String? ?? '') ?? DateTime.now(),
        method: PaymentMethodX.fromName(map['method'] as String? ?? 'bankTransfer'),
        reference: map['reference'] as String? ?? '',
      );

  @override
  List<Object?> get props => [id, householdId, monthKey, amount, datePaid, method, reference];
}
