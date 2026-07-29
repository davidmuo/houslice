import '../../../../core/error/result.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  });

  Future<Result<AppUser>> signUp({
    required String email,
    required String username,
    required String password,
  });

  Future<Result<AppUser>> signInWithGoogle();

  Future<Result<void>> signOut();

  Future<Result<AppUser?>> currentUser();

  Future<Result<void>> changePassword(String newPassword);

  Future<Result<AppUser>> updateProfile({
    required String username,
    String? photoUrl,
    String? dateOfBirth,
  });

  Future<Result<void>> sendEmailVerification();

  Future<Result<void>> sendPasswordReset(String email);
}
