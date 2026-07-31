import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/core/error/exceptions.dart';
import 'package:houslice/features/property/data/datasources/mock_property_data_source.dart';
import 'package:houslice/features/property/data/models/property_model.dart';

import '../../../fixtures/property_fixtures.dart';

/// Tests for the in-memory listings used in demo mode.
void main() {
  late MockPropertyDataSource dataSource;

  setUp(() => dataSource = MockPropertyDataSource());

  test('returns the seeded catalogue', () async {
    final properties = await dataSource.fetchProperties();

    expect(properties, isNotEmpty);
    expect(
      properties.map((p) => p.id).toSet().length,
      properties.length,
      reason: 'listing ids should be unique',
    );
  });

  test('marks the pre-seeded favourites', () async {
    final properties = await dataSource.fetchProperties();
    final favorites = properties.where((p) => p.isFavorite).map((p) => p.id);

    expect(favorites, containsAll(<String>['sekimondo', 'manhari']));
  });

  group('search', () {
    test('an empty query returns everything', () async {
      final all = await dataSource.fetchProperties();

      expect((await dataSource.search('   ')).length, all.length);
    });

    test('matches on name, case-insensitively', () async {
      final results = await dataSource.search('SEKIMONDO');

      expect(results, isNotEmpty);
      expect(
        results.every(
          (p) =>
              p.name.toLowerCase().contains('sekimondo') ||
              p.address.toLowerCase().contains('sekimondo'),
        ),
        isTrue,
      );
    });

    test('a query matching nothing returns an empty list', () async {
      expect(await dataSource.search('zzzz-no-such-listing'), isEmpty);
    });
  });

  group('toggleFavorite', () {
    test('adds a listing that was not favourited', () async {
      final added = await dataSource.toggleFavorite('ayana');

      expect(added, isTrue);
      final properties = await dataSource.fetchProperties();
      expect(properties.firstWhere((p) => p.id == 'ayana').isFavorite, isTrue);
    });

    test('removes a listing that was already favourited', () async {
      final removed = await dataSource.toggleFavorite('sekimondo');

      expect(removed, isFalse);
      final properties = await dataSource.fetchProperties();
      expect(
        properties.firstWhere((p) => p.id == 'sekimondo').isFavorite,
        isFalse,
      );
    });

    test('toggling twice returns to the original state', () async {
      final before = (await dataSource.fetchProperties())
          .firstWhere((p) => p.id == 'manhari')
          .isFavorite;

      await dataSource.toggleFavorite('manhari');
      await dataSource.toggleFavorite('manhari');

      final after = (await dataSource.fetchProperties())
          .firstWhere((p) => p.id == 'manhari')
          .isFavorite;

      expect(after, before);
    });
  });

  group('updateListing', () {
    test('overwrites the stored listing in place', () async {
      final original = (await dataSource.fetchProperties()).first;
      final edited = PropertyModel.fromEntity(
        buildProperty(
          id: original.id,
          name: 'Renamed Apartments',
          pricePerMonth: 999,
        ),
      );

      final saved = await dataSource.updateListing(edited);

      expect(saved.name, 'Renamed Apartments');
      final stored = (await dataSource.fetchProperties()).firstWhere(
        (p) => p.id == original.id,
      );
      expect(stored.name, 'Renamed Apartments');
      expect(stored.pricePerMonth, 999);
    });

    test('does not change how many listings exist', () async {
      final before = (await dataSource.fetchProperties()).length;
      final original = (await dataSource.fetchProperties()).first;

      await dataSource.updateListing(
        PropertyModel.fromEntity(
          buildProperty(id: original.id, name: 'Edited'),
        ),
      );

      expect((await dataSource.fetchProperties()).length, before);
    });

    test('throws when the listing no longer exists', () async {
      expect(
        () => dataSource.updateListing(
          PropertyModel.fromEntity(buildProperty(id: 'not-a-real-listing')),
        ),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('deleteListing', () {
    test('removes the listing from the catalogue', () async {
      final before = (await dataSource.fetchProperties()).length;

      await dataSource.deleteListing('ayana');

      final after = await dataSource.fetchProperties();
      expect(after.length, before - 1);
      expect(after.where((p) => p.id == 'ayana'), isEmpty);
    });

    test('also drops it from favourites, so no orphan heart remains', () async {
      // 'sekimondo' is favourited in the seeded state.
      await dataSource.deleteListing('sekimondo');

      final favorites = (await dataSource.fetchProperties()).where(
        (p) => p.isFavorite,
      );
      expect(favorites.where((p) => p.id == 'sekimondo'), isEmpty);
    });

    test('deleting something absent is a no-op rather than an error', () async {
      final before = (await dataSource.fetchProperties()).length;

      await dataSource.deleteListing('not-a-real-listing');

      expect((await dataSource.fetchProperties()).length, before);
    });
  });
}
