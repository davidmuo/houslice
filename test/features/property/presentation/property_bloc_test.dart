import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/core/error/failures.dart';
import 'package:houslice/core/error/result.dart';
import 'package:houslice/core/usecases/usecase.dart';
import 'package:houslice/features/property/domain/usecases/delete_listing.dart';
import 'package:houslice/features/property/domain/usecases/get_properties.dart';
import 'package:houslice/features/property/domain/usecases/toggle_favorite.dart';
import 'package:houslice/features/property/presentation/bloc/property_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures/property_fixtures.dart';

class _MockGetProperties extends Mock implements GetProperties {}

class _MockToggleFavorite extends Mock implements ToggleFavorite {}

class _MockDeleteListing extends Mock implements DeleteListing {}

/// Bloc tests for listing load, the optimistic favourite toggle, and the
/// optimistic delete.
void main() {
  late _MockGetProperties getProperties;
  late _MockToggleFavorite toggleFavorite;
  late _MockDeleteListing deleteListing;

  final listings = [
    buildProperty(id: 'a', name: 'Alpha'),
    buildProperty(id: 'b', name: 'Beta', isFavorite: true),
  ];

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const DeleteListingParams('a'));
  });

  setUp(() {
    getProperties = _MockGetProperties();
    toggleFavorite = _MockToggleFavorite();
    deleteListing = _MockDeleteListing();
  });

  PropertyBloc build() => PropertyBloc(
    getProperties: getProperties,
    toggleFavorite: toggleFavorite,
    deleteListing: deleteListing,
  );

  group('PropertiesRequested', () {
    blocTest<PropertyBloc, PropertyState>(
      'emits loading then loaded with the listings',
      setUp: () {
        when(
          () => getProperties(any()),
        ).thenAnswer((_) async => Success(listings));
      },
      build: build,
      act: (bloc) => bloc.add(const PropertiesRequested()),
      expect: () => [
        const PropertyState(status: PropertyStatus.loading),
        PropertyState(status: PropertyStatus.loaded, properties: listings),
      ],
    );

    blocTest<PropertyBloc, PropertyState>(
      'emits loading then failure with the message',
      setUp: () {
        when(
          () => getProperties(any()),
        ).thenAnswer((_) async => const Err(ServerFailure('Offline')));
      },
      build: build,
      act: (bloc) => bloc.add(const PropertiesRequested()),
      expect: () => [
        const PropertyState(status: PropertyStatus.loading),
        const PropertyState(status: PropertyStatus.failure, message: 'Offline'),
      ],
    );
  });

  group('PropertyFavoriteToggled', () {
    blocTest<PropertyBloc, PropertyState>(
      'flips the heart immediately and keeps it when the write succeeds',
      setUp: () {
        when(
          () => toggleFavorite(any()),
        ).thenAnswer((_) async => const Success(true));
      },
      build: build,
      seed: () =>
          PropertyState(status: PropertyStatus.loaded, properties: listings),
      act: (bloc) => bloc.add(const PropertyFavoriteToggled('a')),
      expect: () => [
        PropertyState(
          status: PropertyStatus.loaded,
          properties: [listings[0].copyWith(isFavorite: true), listings[1]],
        ),
      ],
    );

    blocTest<PropertyBloc, PropertyState>(
      'reverts the heart and reports the error when the write fails',
      setUp: () {
        when(
          () => toggleFavorite(any()),
        ).thenAnswer((_) async => const Err(ServerFailure('No network')));
      },
      build: build,
      seed: () =>
          PropertyState(status: PropertyStatus.loaded, properties: listings),
      act: (bloc) => bloc.add(const PropertyFavoriteToggled('a')),
      expect: () => [
        // Optimistic flip.
        PropertyState(
          status: PropertyStatus.loaded,
          properties: [listings[0].copyWith(isFavorite: true), listings[1]],
        ),
        // Reverted, with the failure surfaced.
        PropertyState(
          status: PropertyStatus.loaded,
          properties: listings,
          message: 'No network',
        ),
      ],
    );

    blocTest<PropertyBloc, PropertyState>(
      'leaves other listings untouched',
      setUp: () {
        when(
          () => toggleFavorite(any()),
        ).thenAnswer((_) async => const Success(false));
      },
      build: build,
      seed: () =>
          PropertyState(status: PropertyStatus.loaded, properties: listings),
      act: (bloc) => bloc.add(const PropertyFavoriteToggled('b')),
      verify: (bloc) {
        expect(bloc.state.byId('a')!.isFavorite, isFalse);
        expect(bloc.state.byId('b')!.isFavorite, isFalse);
      },
    );
  });

  group('PropertyDeleted', () {
    blocTest<PropertyBloc, PropertyState>(
      'removes the listing immediately and confirms when the write succeeds',
      setUp: () {
        when(
          () => deleteListing(any()),
        ).thenAnswer((_) async => const Success(null));
      },
      build: build,
      seed: () =>
          PropertyState(status: PropertyStatus.loaded, properties: listings),
      act: (bloc) => bloc.add(const PropertyDeleted('a')),
      expect: () => [
        // Optimistic removal, before the backend has answered.
        PropertyState(status: PropertyStatus.loaded, properties: [listings[1]]),
        PropertyState(
          status: PropertyStatus.loaded,
          properties: [listings[1]],
          message: 'Listing deleted.',
        ),
      ],
    );

    blocTest<PropertyBloc, PropertyState>(
      'puts the listing back and reports the error when the write fails',
      setUp: () {
        when(() => deleteListing(any())).thenAnswer(
          (_) async => const Err(ServerFailure('Permission denied')),
        );
      },
      build: build,
      seed: () =>
          PropertyState(status: PropertyStatus.loaded, properties: listings),
      act: (bloc) => bloc.add(const PropertyDeleted('a')),
      expect: () => [
        PropertyState(status: PropertyStatus.loaded, properties: [listings[1]]),
        PropertyState(
          status: PropertyStatus.loaded,
          properties: listings,
          message: 'Permission denied',
        ),
      ],
    );

    blocTest<PropertyBloc, PropertyState>(
      'passes the listing id through to the use case',
      setUp: () {
        when(
          () => deleteListing(any()),
        ).thenAnswer((_) async => const Success(null));
      },
      build: build,
      seed: () =>
          PropertyState(status: PropertyStatus.loaded, properties: listings),
      act: (bloc) => bloc.add(const PropertyDeleted('b')),
      verify: (_) {
        verify(() => deleteListing(const DeleteListingParams('b'))).called(1);
      },
    );
  });

  group('PropertyState helpers', () {
    test('favorites returns only the hearted listings', () {
      final state = PropertyState(properties: listings);

      expect(state.favorites, [listings[1]]);
    });

    test('byId finds a listing, or returns null when absent', () {
      final state = PropertyState(properties: listings);

      expect(state.byId('a')?.name, 'Alpha');
      expect(state.byId('missing'), isNull);
    });

    test('mine returns only the listings published by that uid', () {
      final state = PropertyState(
        properties: [
          buildProperty(id: 'x', ownerUid: 'uid-1'),
          buildProperty(id: 'y', ownerUid: 'uid-2'),
          buildProperty(id: 'z', ownerUid: 'uid-1'),
        ],
      );

      expect(state.mine('uid-1').map((p) => p.id), ['x', 'z']);
    });

    test(
      'mine never matches the seeded catalogue, whose ownerUid is empty',
      () {
        // Guards against an empty uid (signed out) exposing seeded listings as
        // the caller's own and offering them an edit button.
        final state = PropertyState(
          properties: [
            buildProperty(id: 'seeded'),
            buildProperty(id: 'other'),
          ],
        );

        expect(state.mine(''), isEmpty);
      },
    );
  });
}
