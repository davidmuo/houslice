import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/property.dart';
import '../repositories/property_repository.dart';

class SearchProperties extends UseCase<List<Property>, String> {
  final PropertyRepository repository;

  SearchProperties(this.repository);

  @override
  Future<Result<List<Property>>> call(String params) =>
      repository.search(params);
}
