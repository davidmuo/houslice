import '../models/property_model.dart';
import '../seed_properties.dart';
import 'property_data_source.dart';

/// In-memory listings used in demo mode (before Firebase is configured).
class MockPropertyDataSource implements PropertyDataSource {
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
    final saved = PropertyModel.fromEntity(
      listing,
    ).withId('local-${DateTime.now().millisecondsSinceEpoch}');
    // Newest first, so the student sees their listing immediately.
    _properties.insert(0, saved);
    return saved;
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
