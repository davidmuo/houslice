import '../models/property_model.dart';

/// Contract for listing backends. Implemented by
/// [FirestorePropertyDataSource] (production) and
/// [MockPropertyDataSource] (demo mode).
abstract class PropertyDataSource {
  Future<List<PropertyModel>> fetchProperties();

  Future<List<PropertyModel>> search(String query);

  Future<bool> toggleFavorite(String propertyId);
}
