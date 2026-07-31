import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/features/property/data/datasources/mock_property_data_source.dart';

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
}
