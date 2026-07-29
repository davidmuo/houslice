import '../../../../core/error/result.dart';
import '../entities/property.dart';

abstract class PropertyRepository {
  Future<Result<List<Property>>> getProperties();

  Future<Result<List<Property>>> search(String query);

  /// Flips the favorite flag for the current user; returns the new value.
  Future<Result<bool>> toggleFavorite(String propertyId);

  /// Publishes a listing owned by the signed-in user.
  Future<Result<Property>> createListing(Property listing);
}
