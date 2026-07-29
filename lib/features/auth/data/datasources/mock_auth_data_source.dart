import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';
import 'auth_data_source.dart';

/// In-memory auth backend used when Firebase is not configured, so the app
/// is fully demoable out of the box.
///
/// Demo account: `j.simmons@alustudent.com` / `password123`
class MockAuthDataSource implements AuthDataSource {
  final Map<String, ({UserModel user, String password})> _accounts = {
    'j.simmons@alustudent.com': (
      user: const UserModel(
        uid: 'demo-user',
        email: 'j.simmons@alustudent.com',
        username: 'John Simmons',
        photoUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&q=60',
      ),
      password: 'password123',
    ),
  };

  UserModel? _current;

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw const AuthException('Incorrect email or password.');
    }
    _current = account.user;
    return account.user;
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String username,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final key = email.trim().toLowerCase();
    if (_accounts.containsKey(key)) {
      throw const AuthException(
        'An account already exists with this email. Sign in instead.',
      );
    }
    final user = UserModel(
      uid: 'user-${DateTime.now().millisecondsSinceEpoch}',
      email: key,
      username: username,
    );
    _accounts[key] = (user: user, password: password);
    _current = user;
    return user;
  }

  /// Demo mode has no Google SDK, so this stands in with a fixed university
  /// account — enough to exercise the whole flow before Firebase is wired.
  @override
  Future<UserModel> signInWithGoogle() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    const user = UserModel(
      uid: 'demo-google-user',
      email: 'g.demo@alustudent.com',
      username: 'Google Demo Student',
    );
    _accounts[user.email] = (user: user, password: 'google');
    _current = user;
    return user;
  }

  @override
  Future<UserModel> updateProfile({
    required String username,
    String? photoUrl,
    String? dateOfBirth,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final current = _current;
    if (current == null) {
      throw const AuthException('You need to be signed in to do that.');
    }
    final updated = UserModel(
      uid: current.uid,
      email: current.email,
      username: username,
      photoUrl: photoUrl ?? current.photoUrl,
      dateOfBirth: dateOfBirth ?? current.dateOfBirth,
      emailVerified: current.emailVerified,
    );
    final password = _accounts[current.email]?.password ?? '';
    _accounts[current.email] = (user: updated, password: password);
    _current = updated;
    return updated;
  }

  @override
  Future<void> sendEmailVerification() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _current = null;
  }

  @override
  Future<UserModel?> currentUser() async => _current;

  @override
  Future<void> sendPasswordReset(String email) async {
    // Demo mode has no mail server; the delay stands in for the round trip so
    // the UI exercises its loading state.
    await Future<void>.delayed(const Duration(milliseconds: 700));
  }

  @override
  Future<void> changePassword(String newPassword) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final current = _current;
    if (current == null) {
      throw const AuthException('You need to be signed in to do that.');
    }
    _accounts[current.email] = (user: current, password: newPassword);
  }
}
