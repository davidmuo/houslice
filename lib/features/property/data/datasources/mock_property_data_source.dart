import '../../../../core/error/exceptions.dart';
import '../models/property_model.dart';
import '../seed_properties.dart';
import 'property_data_source.dart';

/// In-memory listings used in demo mode (before Firebase is configured).
class MockPropertyDataSource implements PropertyDataSource {
  /// Stands in for the signed-in uid, which demo mode has no Firebase session
  /// to read. It matches [MockAuthDataSource]'s demo account so a listing
  /// published in demo mode shows up under "My Listings", exactly as it would
  /// against Firebase.
  static const demoOwnerUid = 'demo-user';

  final List<PropertyModel> _properties = List.of(kSeedProperties);
  final Set<String> _favoriteIds = {'sekimondo', 'manhari'};

  @override
  Future<List<PropertyModel>> fetchProperties() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _properties
        .map((p) => p.withFavorite(_favoriteIds.contains(p.id)))
        .toList();
  }

  @override
  Future<List<PropertyModel>> search(String query) async {
    final all = await fetchProperties();
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              p.address.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Future<PropertyModel> createListing(PropertyModel listing) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    // Stamping the owner mirrors what FirestorePropertyDataSource does, so the
    // two implementations of this contract stay behaviourally identical.
    final saved = PropertyModel.fromEntity(listing)
        .withOwner(demoOwnerUid)
        .withId('local-${DateTime.now().millisecondsSinceEpoch}');
    // Newest first, so the student sees their listing immediately.
    _properties.insert(0, saved);
    return saved;
  }

  @override
  Future<PropertyModel> updateListing(PropertyModel listing) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final index = _properties.indexWhere((p) => p.id == listing.id);
    if (index == -1) {
      throw const ServerException('That listing no longer exists.');
    }
    final saved = PropertyModel.fromEntity(listing);
    _properties[index] = saved;
    return saved;
  }

  @override
  Future<void> deleteListing(String propertyId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _properties.removeWhere((p) => p.id == propertyId);
    _favoriteIds.remove(propertyId);
  }

  @override
  Future<bool> toggleFavorite(String propertyId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (_favoriteIds.contains(propertyId)) {
      _favoriteIds.remove(propertyId);
      return false;
    }
    _favoriteIds.add(propertyId);
    return true;
  }
}
