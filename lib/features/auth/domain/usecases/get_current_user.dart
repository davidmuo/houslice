import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUser extends UseCase<AppUser?, NoParams> {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  @override
  Future<Result<AppUser?>> call(NoParams params) => repository.currentUser();
}
