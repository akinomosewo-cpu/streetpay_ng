import '../models/household.dart';
import '../models/payment.dart';

enum PaymentStatus { paid, partial, unpaid }

extension PaymentStatusX on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.partial:
        return 'Partial';
      case PaymentStatus.unpaid:
        return 'Unpaid';
    }
  }
}

/// Per-household result for a given month.
class HouseholdMonthSummary {
  final Household household;
  final int amountPaid;
  final PaymentStatus status;

  const HouseholdMonthSummary({
    required this.household,
    required this.amountPaid,
    required this.status,
  });

  int get amountDue => household.monthlyDue;
  int get outstanding => (amountDue - amountPaid).clamp(0, amountDue);
}

/// Street-wide totals for a given month.
class CollectionSummary {
  final String monthKey;
  final List<HouseholdMonthSummary> households;

  const CollectionSummary({required this.monthKey, required this.households});

  int get totalExpected => households.fold(0, (sum, h) => sum + h.amountDue);
  int get totalCollected => households.fold(0, (sum, h) => sum + h.amountPaid);
  int get totalOutstanding => (totalExpected - totalCollected).clamp(0, totalExpected);

  int get paidCount => households.where((h) => h.status == PaymentStatus.paid).length;
  int get partialCount => households.where((h) => h.status == PaymentStatus.partial).length;
  int get unpaidCount => households.where((h) => h.status == PaymentStatus.unpaid).length;

  double get collectionRate => totalExpected == 0 ? 0 : totalCollected / totalExpected;
}

/// Pure, side-effect-free calculations for household levy collection.
/// Kept free of Flutter/Hive so it can be unit tested in isolation.
class PaymentService {
  const PaymentService();

  /// Sums every payment a household has made for [monthKey].
  int amountPaidFor(String householdId, String monthKey, List<Payment> payments) {
    return payments
        .where((p) => p.householdId == householdId && p.monthKey == monthKey)
        .fold(0, (sum, p) => sum + p.amount);
  }

  /// Determines paid/partial/unpaid for a household in a given month.
  PaymentStatus statusFor(Household household, int amountPaid) {
    if (amountPaid <= 0) return PaymentStatus.unpaid;
    if (amountPaid >= household.monthlyDue) return PaymentStatus.paid;
    return PaymentStatus.partial;
  }

  HouseholdMonthSummary summaryFor(
    Household household,
    String monthKey,
    List<Payment> payments,
  ) {
    final paid = amountPaidFor(household.id, monthKey, payments);
    return HouseholdMonthSummary(
      household: household,
      amountPaid: paid,
      status: statusFor(household, paid),
    );
  }

  /// Builds the full street collection board for [monthKey].
  CollectionSummary collectionSummary(
    List<Household> households,
    List<Payment> payments,
    String monthKey,
  ) {
    final rows = households
        .map((h) => summaryFor(h, monthKey, payments))
        .toList(growable: false);
    return CollectionSummary(monthKey: monthKey, households: rows);
  }
}
