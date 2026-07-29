import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Re-sends the verification link to the signed-in student's address.
class SendEmailVerification extends UseCase<void, NoParams> {
  final AuthRepository repository;

  SendEmailVerification(this.repository);

  @override
  Future<Result<void>> call(NoParams params) =>
      repository.sendEmailVerification();
}
