import '../models/user_model.dart';

/// Contract for auth backends. Implemented by [FirebaseAuthDataSource]
/// (production) and [MockAuthDataSource] (demo mode, used automatically
/// when Firebase has not been configured yet).
abstract class AuthDataSource {
  Future<UserModel> signIn({required String email, required String password});

  Future<UserModel> signUp({
    required String email,
    required String username,
    required String password,
  });

  Future<void> signOut();

  Future<UserModel?> currentUser();

  Future<void> changePassword(String newPassword);
}
