import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/lifestyle_profile.dart';
import '../repositories/lifestyle_repository.dart';

/// Loads the student's questionnaire answers. Returns null when the quiz has
/// not been taken, which is how the app decides to show it after sign-up.
class GetLifestyleProfile extends UseCase<LifestyleProfile?, NoParams> {
  final LifestyleRepository repository;

  GetLifestyleProfile(this.repository);

  @override
  Future<Result<LifestyleProfile?>> call(NoParams params) => repository.load();
}
