import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/property.dart';
import '../../domain/repositories/property_repository.dart';
import '../datasources/property_data_source.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyDataSource dataSource;

  PropertyRepositoryImpl(this.dataSource);

  Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Success(await run());
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } catch (_) {
      return const Err(ServerFailure());
    }
  }

  @override
  Future<Result<List<Property>>> getProperties() =>
      _guard(() => dataSource.fetchProperties());

  @override
  Future<Result<List<Property>>> search(String query) =>
      _guard(() => dataSource.search(query));

  @override
  Future<Result<bool>> toggleFavorite(String propertyId) =>
      _guard(() => dataSource.toggleFavorite(propertyId));
}
