import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Houseslice's second authentication method. The repository rejects Google
/// accounts outside the allowed university domains, so this cannot be used to
/// get around the student-only rule.
class SignInWithGoogle extends UseCase<AppUser, NoParams> {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  @override
  Future<Result<AppUser>> call(NoParams params) =>
      repository.signInWithGoogle();
}
