import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class ChangePassword extends UseCase<void, String> {
  final AuthRepository repository;

  ChangePassword(this.repository);

  @override
  Future<Result<void>> call(String params) =>
      repository.changePassword(params);
}
