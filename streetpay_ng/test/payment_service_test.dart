import 'package:flutter_test/flutter_test.dart';
import 'package:streetpay_ng/models/household.dart';
import 'package:streetpay_ng/models/payment.dart';
import 'package:streetpay_ng/services/payment_service.dart';

Household _household({
  String id = 'h1',
  ResidentType type = ResidentType.landlord,
  int? due,
}) {
  return Household(
    id: id,
    occupantName: 'Test Occupant',
    houseNumber: '12',
    type: type,
    monthlyDue: due ?? Household.defaultDueFor(type),
    createdAt: DateTime(2026, 1, 1),
  );
}

Payment _payment({
  required String householdId,
  required int amount,
  String monthKey = '2026-09',
  String id = '',
}) {
  return Payment(
    id: id.isEmpty ? '${householdId}_$amount' : id,
    householdId: householdId,
    monthKey: monthKey,
    amount: amount,
    datePaid: DateTime(2026, 9, 10),
  );
}

void main() {
  const service = PaymentService();

  group('default dues', () {
    test('landlord default is 2500', () {
      expect(Household.defaultDueFor(ResidentType.landlord), 2500);
    });

    test('tenant default is 500', () {
      expect(Household.defaultDueFor(ResidentType.tenant), 500);
    });
  });

  group('amountPaidFor', () {
    test('sums multiple payments for the same household and month', () {
      final payments = [
        _payment(householdId: 'h1', amount: 1000, id: 'p1'),
        _payment(householdId: 'h1', amount: 500, id: 'p2'),
        _payment(householdId: 'h2', amount: 2500, id: 'p3'),
      ];
      expect(service.amountPaidFor('h1', '2026-09', payments), 1500);
    });

    test('ignores payments from other months', () {
      final payments = [
        _payment(householdId: 'h1', amount: 1000, monthKey: '2026-08', id: 'p1'),
        _payment(householdId: 'h1', amount: 500, monthKey: '2026-09', id: 'p2'),
      ];
      expect(service.amountPaidFor('h1', '2026-09', payments), 500);
    });

    test('returns 0 when there are no payments', () {
      expect(service.amountPaidFor('h1', '2026-09', const []), 0);
    });
  });

  group('statusFor', () {
    final household = _household(due: 2500);

    test('unpaid when nothing has been paid', () {
      expect(service.statusFor(household, 0), PaymentStatus.unpaid);
    });

    test('partial when less than the due amount has been paid', () {
      expect(service.statusFor(household, 1000), PaymentStatus.partial);
    });

    test('paid when exactly the due amount has been paid', () {
      expect(service.statusFor(household, 2500), PaymentStatus.paid);
    });

    test('paid when overpaid', () {
      expect(service.statusFor(household, 3000), PaymentStatus.paid);
    });
  });

  group('collectionSummary', () {
    test('computes totals, counts and outstanding across households', () {
      final landlord = _household(id: 'h1', type: ResidentType.landlord); // due 2500
      final tenant = _household(id: 'h2', type: ResidentType.tenant); // due 500
      final unpaidTenant = _household(id: 'h3', type: ResidentType.tenant); // due 500

      final payments = [
        _payment(householdId: 'h1', amount: 2500, id: 'p1'), // fully paid
        _payment(householdId: 'h2', amount: 200, id: 'p2'), // partial
      ];

      final summary = service.collectionSummary(
        [landlord, tenant, unpaidTenant],
        payments,
        '2026-09',
      );

      expect(summary.totalExpected, 2500 + 500 + 500);
      expect(summary.totalCollected, 2500 + 200);
      expect(summary.totalOutstanding, 300 + 500);
      expect(summary.paidCount, 1);
      expect(summary.partialCount, 1);
      expect(summary.unpaidCount, 1);
      expect(summary.collectionRate, closeTo((2700) / 3500, 0.0001));
    });

    test('collection rate is 0 when there are no households', () {
      final summary = service.collectionSummary(const [], const [], '2026-09');
      expect(summary.collectionRate, 0);
      expect(summary.totalExpected, 0);
    });

    test('outstanding never goes negative even if overpaid', () {
      final household = _household(id: 'h1', due: 1000);
      final payments = [_payment(householdId: 'h1', amount: 5000, id: 'p1')];
      final summary = service.collectionSummary([household], payments, '2026-09');
      expect(summary.households.first.outstanding, 0);
      expect(summary.totalOutstanding, 0);
    });
  });
}
