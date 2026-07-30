import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/core/error/failures.dart';
import 'package:houslice/core/error/result.dart';
import 'package:houslice/core/usecases/usecase.dart';
import 'package:houslice/features/property/domain/usecases/get_properties.dart';
import 'package:houslice/features/property/domain/usecases/toggle_favorite.dart';
import 'package:houslice/features/property/presentation/bloc/property_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures/property_fixtures.dart';

class _MockGetProperties extends Mock implements GetProperties {}

class _MockToggleFavorite extends Mock implements ToggleFavorite {}

/// Bloc tests for listing load and the optimistic favourite toggle.
void main() {
  late _MockGetProperties getProperties;
  late _MockToggleFavorite toggleFavorite;

  final listings = [
    buildProperty(id: 'a', name: 'Alpha'),
    buildProperty(id: 'b', name: 'Beta', isFavorite: true),
  ];

  setUpAll(() => registerFallbackValue(const NoParams()));

  setUp(() {
    getProperties = _MockGetProperties();
    toggleFavorite = _MockToggleFavorite();
  });

  PropertyBloc build() => PropertyBloc(
    getProperties: getProperties,
    toggleFavorite: toggleFavorite,
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
  });
}
