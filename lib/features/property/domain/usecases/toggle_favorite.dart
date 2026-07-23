import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/property_repository.dart';

class ToggleFavorite extends UseCase<bool, String> {
  final PropertyRepository repository;

  ToggleFavorite(this.repository);

  @override
  Future<Result<bool>> call(String params) =>
      repository.toggleFavorite(params);
}
