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

  /// Second sign-in method. Rejects accounts outside the allowed university
  /// domains, so the marketplace stays student-only.
  Future<UserModel> signInWithGoogle();

  Future<void> signOut();

  Future<UserModel?> currentUser();

  Future<void> changePassword(String newPassword);

  /// Updates the editable parts of the profile. Email is never changed here —
  /// it is the verified identity the account is built on.
  Future<UserModel> updateProfile({
    required String username,
    String? photoUrl,
    String? dateOfBirth,
  });

  /// Emails a verification link to the signed-in user.
  Future<void> sendEmailVerification();

  /// Sends a password-reset link to [email]. Succeeds silently for unknown
  /// addresses so the API cannot be used to probe which emails are registered.
  Future<void> sendPasswordReset(String email);
}
