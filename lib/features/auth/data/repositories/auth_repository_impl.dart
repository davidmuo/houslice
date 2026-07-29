import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Success(await run());
    } on AuthException catch (e) {
      return Err(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } catch (_) {
      return const Err(ServerFailure());
    }
  }

  @override
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  }) => _guard(() => dataSource.signIn(email: email, password: password));

  @override
  Future<Result<AppUser>> signUp({
    required String email,
    required String username,
    required String password,
  }) => _guard(
    () =>
        dataSource.signUp(email: email, username: username, password: password),
  );

  @override
  Future<Result<AppUser>> signInWithGoogle() =>
      _guard(() => dataSource.signInWithGoogle());

  @override
  Future<Result<void>> signOut() => _guard(() => dataSource.signOut());

  @override
  Future<Result<AppUser?>> currentUser() =>
      _guard(() => dataSource.currentUser());

  @override
  Future<Result<void>> changePassword(String newPassword) =>
      _guard(() => dataSource.changePassword(newPassword));

  @override
  Future<Result<void>> sendPasswordReset(String email) =>
      _guard(() => dataSource.sendPasswordReset(email));

  @override
  Future<Result<AppUser>> updateProfile({
    required String username,
    String? photoUrl,
    String? dateOfBirth,
  }) => _guard(
    () => dataSource.updateProfile(
      username: username,
      photoUrl: photoUrl,
      dateOfBirth: dateOfBirth,
    ),
  );

  @override
  Future<Result<void>> sendEmailVerification() =>
      _guard(() => dataSource.sendEmailVerification());
}
