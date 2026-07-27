import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/property.dart';
import '../repositories/property_repository.dart';

class GetProperties extends UseCase<List<Property>, NoParams> {
  final PropertyRepository repository;

  GetProperties(this.repository);

  @override
  Future<Result<List<Property>>> call(NoParams params) =>
      repository.getProperties();
}
