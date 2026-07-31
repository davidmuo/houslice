import '../models/property_model.dart';

/// Contract for listing backends. Implemented by
/// [FirestorePropertyDataSource] (production) and
/// [MockPropertyDataSource] (demo mode).
abstract class PropertyDataSource {
  Future<List<PropertyModel>> fetchProperties();

  Future<List<PropertyModel>> search(String query);

  Future<bool> toggleFavorite(String propertyId);

  /// Publishes a new listing and returns it with its assigned id.
  Future<PropertyModel> createListing(PropertyModel listing);

  /// Saves edits to an existing listing and returns the stored version.
  ///
  /// Only the owner may do this — enforced by the Firestore rules, not just by
  /// hiding the button.
  Future<PropertyModel> updateListing(PropertyModel listing);

  /// Permanently removes a listing the signed-in user owns.
  Future<void> deleteListing(String propertyId);
}
