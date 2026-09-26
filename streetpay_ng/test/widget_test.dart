import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streetpay_ng/data/app_repository.dart';
import 'package:streetpay_ng/models/attendance.dart';
import 'package:streetpay_ng/models/guard.dart';
import 'package:streetpay_ng/models/household.dart';
import 'package:streetpay_ng/models/payment.dart';

import 'package:streetpay_ng/main.dart';

/// An in-memory stand-in for the Hive-backed repository, so widget tests
/// don't depend on the path_provider platform plugin.
class _FakeRepository extends AppRepository {
  @override
  Future<void> init() async {}

  @override
  List<Household> getHouseholds() => const [];

  @override
  Future<void> saveHousehold(Household household) async {}

  @override
  Future<void> deleteHousehold(String id) async {}

  @override
  List<Payment> getPayments() => const [];

  @override
  Future<void> savePayment(Payment payment) async {}

  @override
  Future<void> deletePayment(String id) async {}

  @override
  List<Guard> getGuards() => const [];

  @override
  Future<void> saveGuard(Guard guard) async {}

  @override
  Future<void> deleteGuard(String id) async {}

  @override
  List<AttendanceRecord> getAttendance() => const [];

  @override
  Future<void> saveAttendance(AttendanceRecord record) async {}
}

void main() {
  setUpAll(() {
    // Avoid network font fetches in the test sandbox; GoogleFonts falls
    // back to the platform default font when this is disabled.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('App launches and shows the dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(StreetPayApp(repository: _FakeRepository()));
    await tester.pump();
    await tester.pump();

    expect(find.text('StreetPay NG'), findsOneWidget);
    expect(find.text('Households'), findsOneWidget);
    expect(find.text('Payment status board'), findsOneWidget);
    expect(find.text('Guards & payroll'), findsOneWidget);
    expect(find.text('Public transparency view'), findsOneWidget);
  });
}
