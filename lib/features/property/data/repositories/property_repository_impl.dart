import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/property.dart';
import '../../domain/repositories/property_repository.dart';
import '../datasources/property_data_source.dart';
import '../models/property_model.dart';

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

  @override
  Future<Result<Property>> createListing(Property listing) =>
      _guard(() => dataSource.createListing(PropertyModel.fromEntity(listing)));

  @override
  Future<Result<Property>> updateListing(Property listing) =>
      _guard(() => dataSource.updateListing(PropertyModel.fromEntity(listing)));

  @override
  Future<Result<void>> deleteListing(String propertyId) =>
      _guard(() => dataSource.deleteListing(propertyId));
}
