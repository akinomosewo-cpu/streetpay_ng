import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streetpay_ng/data/app_repository.dart';
import 'package:streetpay_ng/models/attendance.dart';
import 'package:streetpay_ng/models/guard.dart';
import 'package:streetpay_ng/models/household.dart';
import 'package:streetpay_ng/models/payment.dart';

import 'package:streetpay_ng/main.dart';

import 'helpers/fake_auth_repository.dart';

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

  testWidgets('App launches, passes through splash and shows the dashboard for a logged-in treasurer',
      (WidgetTester tester) async {
    await tester.pumpWidget(StreetPayApp(
      repository: _FakeRepository(),
      authRepository: FakeAuthRepository(hasAccount: true, isLoggedIn: true),
    ));
    await tester.pump();
    // Splash screen shows first.
    expect(find.text('Levy collection & guard payroll'), findsOneWidget);

    // Let the splash's minimum-duration delay and transition finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 2000));

    expect(find.text('StreetPay NG'), findsOneWidget);
    expect(find.text('Households'), findsOneWidget);
    expect(find.text('Payment status board'), findsOneWidget);
    expect(find.text('Guards & payroll'), findsOneWidget);
    expect(find.text('Public transparency view'), findsOneWidget);
  });

  testWidgets('A treasurer with no account is routed to sign up', (WidgetTester tester) async {
    await tester.pumpWidget(StreetPayApp(
      repository: _FakeRepository(),
      authRepository: FakeAuthRepository(),
    ));
    await tester.pumpAndSettle(const Duration(milliseconds: 2000));

    expect(find.text('Set up your street'), findsOneWidget);
    expect(find.byKey(const Key('signup_submit_button')), findsOneWidget);
  });
}
