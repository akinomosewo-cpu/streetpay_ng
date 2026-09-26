import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Result of a sign up / login attempt.
class AuthResult {
  final bool success;
  final String? error;
  const AuthResult._(this.success, this.error);
  const AuthResult.ok() : this._(true, null);
  const AuthResult.failure(String message) : this._(false, message);
}

/// Local-only authentication for the street's treasurer. There is no
/// backend: a single treasurer account is created on sign up and stored
/// (with a hashed password) in Hive, then validated on login. A
/// "logged in" flag is persisted so returning users skip straight to the
/// dashboard.
class AuthRepository {
  static const _boxName = 'auth';
  static const _accountKey = 'account';
  static const _loggedInKey = 'loggedIn';

  late Box _box;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    _initialized = true;
  }

  /// Whether a treasurer account has ever been created on this device.
  bool get hasAccount => _box.containsKey(_accountKey);

  /// Whether the treasurer is currently signed in.
  bool get isLoggedIn => _box.get(_loggedInKey, defaultValue: false) as bool;

  String? get treasurerName => _account?['treasurerName'] as String?;

  String? get streetName => _account?['streetName'] as String?;

  Map? get _account => _box.get(_accountKey) as Map?;

  Future<AuthResult> signUp({
    required String treasurerName,
    required String streetName,
    required String contact,
    required String password,
  }) async {
    if (treasurerName.trim().isEmpty || streetName.trim().isEmpty || contact.trim().isEmpty) {
      return const AuthResult.failure('Please fill in every field.');
    }
    if (password.length < 4) {
      return const AuthResult.failure('Password must be at least 4 characters.');
    }
    if (hasAccount) {
      return const AuthResult.failure('An account already exists on this device. Please log in.');
    }
    await _box.put(_accountKey, {
      'treasurerName': treasurerName.trim(),
      'streetName': streetName.trim(),
      'contact': contact.trim(),
      'passwordHash': _hash(password),
    });
    await _box.put(_loggedInKey, true);
    return const AuthResult.ok();
  }

  Future<AuthResult> login({required String contact, required String password}) async {
    final account = _account;
    if (account == null) {
      return const AuthResult.failure('No account found on this device. Please sign up first.');
    }
    final matches = account['contact'] == contact.trim() && account['passwordHash'] == _hash(password);
    if (!matches) {
      return const AuthResult.failure('Incorrect phone/email or password.');
    }
    await _box.put(_loggedInKey, true);
    return const AuthResult.ok();
  }

  Future<void> logout() => _box.put(_loggedInKey, false);

  static String _hash(String input) => sha256.convert(utf8.encode(input)).toString();
}
