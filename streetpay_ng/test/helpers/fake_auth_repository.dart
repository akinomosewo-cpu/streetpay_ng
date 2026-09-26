import 'package:streetpay_ng/data/auth_repository.dart';

/// An in-memory stand-in for the Hive-backed [AuthRepository], so tests
/// don't depend on the path_provider platform plugin.
class FakeAuthRepository extends AuthRepository {
  bool _hasAccount;
  bool _isLoggedIn;
  Map<String, String>? _account;

  FakeAuthRepository({bool hasAccount = false, bool isLoggedIn = false})
      : _hasAccount = hasAccount,
        _isLoggedIn = isLoggedIn;

  @override
  Future<void> init() async {}

  @override
  bool get hasAccount => _hasAccount;

  @override
  bool get isLoggedIn => _isLoggedIn;

  @override
  String? get treasurerName => _account?['treasurerName'];

  @override
  String? get streetName => _account?['streetName'];

  @override
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
    if (_hasAccount) {
      return const AuthResult.failure('An account already exists on this device. Please log in.');
    }
    _account = {
      'treasurerName': treasurerName.trim(),
      'streetName': streetName.trim(),
      'contact': contact.trim(),
      'password': password,
    };
    _hasAccount = true;
    _isLoggedIn = true;
    return const AuthResult.ok();
  }

  @override
  Future<AuthResult> login({required String contact, required String password}) async {
    final account = _account;
    if (account == null) {
      return const AuthResult.failure('No account found on this device. Please sign up first.');
    }
    if (account['contact'] != contact.trim() || account['password'] != password) {
      return const AuthResult.failure('Incorrect phone/email or password.');
    }
    _isLoggedIn = true;
    return const AuthResult.ok();
  }

  @override
  Future<void> logout() async {
    _isLoggedIn = false;
  }
}
