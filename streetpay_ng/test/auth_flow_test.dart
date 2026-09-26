import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streetpay_ng/data/app_repository.dart';
import 'package:streetpay_ng/main.dart';
import 'package:streetpay_ng/models/attendance.dart';
import 'package:streetpay_ng/models/guard.dart';
import 'package:streetpay_ng/models/household.dart';
import 'package:streetpay_ng/models/payment.dart';

import 'helpers/fake_auth_repository.dart';

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
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('signing up with valid details takes the treasurer to the dashboard', (WidgetTester tester) async {
    final auth = FakeAuthRepository();
    await tester.pumpWidget(StreetPayApp(repository: _FakeRepository(), authRepository: auth));
    await tester.pumpAndSettle(const Duration(milliseconds: 2000));

    expect(find.text('Set up your street'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('signup_name_field')), 'Ada Obi');
    await tester.enterText(find.byKey(const Key('signup_street_field')), 'Sunrise Close');
    await tester.enterText(find.byKey(const Key('signup_contact_field')), 'ada@streetpay.ng');
    await tester.enterText(find.byKey(const Key('signup_password_field')), 'secure1');
    await tester.tap(find.byKey(const Key('signup_submit_button')));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    expect(auth.isLoggedIn, isTrue);
    expect(find.text('StreetPay NG'), findsOneWidget);
  });

  testWidgets('logging out from the dashboard returns to the login screen', (WidgetTester tester) async {
    final auth = FakeAuthRepository(hasAccount: true, isLoggedIn: true);
    await tester.pumpWidget(StreetPayApp(repository: _FakeRepository(), authRepository: auth));
    await tester.pumpAndSettle(const Duration(milliseconds: 2000));

    expect(find.text('StreetPay NG'), findsOneWidget);

    await tester.tap(find.byKey(const Key('logout_button')));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    expect(auth.isLoggedIn, isFalse);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
