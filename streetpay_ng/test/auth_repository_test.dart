import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_auth_repository.dart';

void main() {
  group('AuthRepository (local-only auth)', () {
    test('sign up creates an account and logs the treasurer in', () async {
      final auth = FakeAuthRepository();
      expect(auth.hasAccount, isFalse);
      expect(auth.isLoggedIn, isFalse);

      final result = await auth.signUp(
        treasurerName: 'Ada Obi',
        streetName: 'Sunrise Close',
        contact: 'ada@streetpay.ng',
        password: 'secure1',
      );

      expect(result.success, isTrue);
      expect(auth.hasAccount, isTrue);
      expect(auth.isLoggedIn, isTrue);
      expect(auth.treasurerName, 'Ada Obi');
      expect(auth.streetName, 'Sunrise Close');
    });

    test('sign up rejects a short password', () async {
      final auth = FakeAuthRepository();
      final result = await auth.signUp(
        treasurerName: 'Ada Obi',
        streetName: 'Sunrise Close',
        contact: 'ada@streetpay.ng',
        password: '123',
      );

      expect(result.success, isFalse);
      expect(auth.hasAccount, isFalse);
    });

    test('sign up refuses a second account on the same device', () async {
      final auth = FakeAuthRepository(hasAccount: true);
      final result = await auth.signUp(
        treasurerName: 'Bola',
        streetName: 'Palm Ave',
        contact: 'bola@streetpay.ng',
        password: 'secure1',
      );

      expect(result.success, isFalse);
      expect(result.error, contains('already exists'));
    });

    test('login succeeds with matching credentials and fails otherwise', () async {
      final auth = FakeAuthRepository();
      await auth.signUp(
        treasurerName: 'Ada Obi',
        streetName: 'Sunrise Close',
        contact: 'ada@streetpay.ng',
        password: 'secure1',
      );
      await auth.logout();
      expect(auth.isLoggedIn, isFalse);

      final wrong = await auth.login(contact: 'ada@streetpay.ng', password: 'wrongpass');
      expect(wrong.success, isFalse);
      expect(auth.isLoggedIn, isFalse);

      final right = await auth.login(contact: 'ada@streetpay.ng', password: 'secure1');
      expect(right.success, isTrue);
      expect(auth.isLoggedIn, isTrue);
    });

    test('login fails when no account has been created yet', () async {
      final auth = FakeAuthRepository();
      final result = await auth.login(contact: 'nobody@streetpay.ng', password: 'whatever');

      expect(result.success, isFalse);
      expect(result.error, contains('sign up'));
    });
  });
}
