import '../../../../core/error/exceptions.dart';
import '../../../auth/data/datasources/auth_data_source.dart';
import '../models/property_model.dart';
import '../seed_properties.dart';
import 'property_data_source.dart';

/// In-memory listings used in demo mode (before Firebase is configured).
class MockPropertyDataSource implements PropertyDataSource {
  /// The demo-mode stand-in for `FirebaseAuth.instance`, so a listing is
  /// stamped with the uid of whoever is actually signed in — including an
  /// account registered during the demo, not just the seeded one.
  final AuthDataSource auth;

  MockPropertyDataSource(this.auth);

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
    final uid = (await auth.currentUser())?.uid;
    if (uid == null) {
      throw const ServerException('Sign in to publish a listing.');
    }
    // Stamping the owner mirrors what FirestorePropertyDataSource does, so the
    // two implementations of this contract stay behaviourally identical and
    // "My Listings" works the same with or without a Firebase backend.
    final saved = PropertyModel.fromEntity(
      listing,
    ).withOwner(uid).withId('local-${DateTime.now().millisecondsSinceEpoch}');
    // Newest first, so the student sees their listing immediately.
    _properties.insert(0, saved);
    return saved;
  }

  @override
  Future<PropertyModel> updateListing(PropertyModel listing) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final uid = (await auth.currentUser())?.uid;
    if (uid == null) {
      throw const ServerException('Sign in to edit a listing.');
    }
    final index = _properties.indexWhere((p) => p.id == listing.id);
    if (index == -1) {
      throw const ServerException('That listing no longer exists.');
    }
    if (_properties[index].ownerUid != uid) {
      throw const ServerException('You can only edit your own listings.');
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
