import '../../../../core/error/result.dart';
import '../entities/property.dart';

abstract class PropertyRepository {
  Future<Result<List<Property>>> getProperties();

  Future<Result<List<Property>>> search(String query);

  /// Flips the favorite flag for the current user; returns the new value.
  Future<Result<bool>> toggleFavorite(String propertyId);
}
