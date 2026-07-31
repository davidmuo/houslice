import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/core/error/exceptions.dart';
import 'package:houslice/features/auth/data/datasources/mock_auth_data_source.dart';
import 'package:houslice/features/auth/data/models/user_model.dart';
import 'package:houslice/features/property/data/datasources/mock_property_data_source.dart';
import 'package:houslice/features/property/data/models/property_model.dart';

import '../../../fixtures/property_fixtures.dart';

/// Tests for the in-memory listings used in demo mode.
void main() {
  late MockPropertyDataSource dataSource;
  late MockAuthDataSource auth;

  /// Signs the demo account in, so listings can be published and owned.
  Future<UserModel> signIn() =>
      auth.signIn(email: 'j.simmons@alustudent.com', password: 'password123');

  setUp(() {
    auth = MockAuthDataSource();
    dataSource = MockPropertyDataSource(auth);
  });

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

  group('createListing', () {
    test('stamps the signed-in uid as the owner', () async {
      final user = await signIn();

      final published = await dataSource.createListing(
        PropertyModel.fromEntity(buildProperty(id: '', name: 'My Room')),
      );

      // Regression guard: a hardcoded demo uid here meant a listing published
      // by a freshly registered account never appeared under My Listings.
      expect(published.ownerUid, user.uid);
    });

    test('an account registered in demo mode owns what it publishes', () async {
      final user = await auth.signUp(
        email: 'new.student@alustudent.com',
        username: 'New Student',
        password: 'password123',
      );

      final published = await dataSource.createListing(
        PropertyModel.fromEntity(buildProperty(id: '', name: 'Spare Room')),
      );

      expect(published.ownerUid, user.uid);
      expect(published.ownerUid, isNot('demo-user'));
    });

    test('refuses to publish while signed out', () async {
      expect(
        () => dataSource.createListing(
          PropertyModel.fromEntity(buildProperty(id: '')),
        ),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('updateListing', () {
    /// Publishes a listing owned by the signed-in demo account.
    Future<PropertyModel> publishOne() async {
      await signIn();
      return dataSource.createListing(
        PropertyModel.fromEntity(buildProperty(id: '', name: 'Original Name')),
      );
    }

    test('overwrites the stored listing in place', () async {
      final original = await publishOne();
      final edited = PropertyModel.fromEntity(
        buildProperty(
          id: original.id,
          name: 'Renamed Apartments',
          pricePerMonth: 999,
          ownerUid: original.ownerUid,
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
      final original = await publishOne();
      final before = (await dataSource.fetchProperties()).length;

      await dataSource.updateListing(
        PropertyModel.fromEntity(
          buildProperty(
            id: original.id,
            name: 'Edited',
            ownerUid: original.ownerUid,
          ),
        ),
      );

      expect((await dataSource.fetchProperties()).length, before);
    });

    test('throws when the listing no longer exists', () async {
      await signIn();

      expect(
        () => dataSource.updateListing(
          PropertyModel.fromEntity(buildProperty(id: 'not-a-real-listing')),
        ),
        throwsA(isA<ServerException>()),
      );
    });

    test('refuses to edit a listing owned by someone else', () async {
      await signIn();

      // The seeded catalogue carries an empty ownerUid, so it belongs to
      // nobody and no signed-in student may edit it.
      expect(
        () => dataSource.updateListing(
          PropertyModel.fromEntity(buildProperty(id: 'ayana', name: 'Hijack')),
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
