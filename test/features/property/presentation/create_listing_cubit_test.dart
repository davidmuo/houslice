import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/core/error/result.dart';
import 'package:houslice/core/services/photo_service.dart';
import 'package:houslice/features/lifestyle/domain/entities/lifestyle_profile.dart';
import 'package:houslice/features/property/domain/entities/property.dart';
import 'package:houslice/features/property/domain/usecases/create_listing.dart';
import 'package:houslice/features/property/domain/usecases/update_listing.dart';
import 'package:houslice/features/property/presentation/cubit/create_listing_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures/property_fixtures.dart';

class _MockCreateListing extends Mock implements CreateListing {}

class _MockUpdateListing extends Mock implements UpdateListing {}

/// Photos are already remote URLs in these tests, so nothing is uploaded.
class _NoopPhotoService implements PhotoService {
  @override
  Future<List<String>> pick({int limit = 5}) async => const [];

  @override
  Future<String> upload(String localPath, {required String folder}) async =>
      localPath;
}

/// Tests for the create/edit branch of the listing form.
///
/// The edit path is where the interesting cases are: an update must not reset
/// values it never asked the user about.
void main() {
  late _MockCreateListing createListing;
  late _MockUpdateListing updateListing;

  // Captures the Property handed to the use case. mocktail marks a call as
  // verified once, so each of these may be called at most once per test —
  // hence assigning the result to a local rather than calling it per
  // assertion.
  Property capturedUpdate() =>
      (verify(() => updateListing(captureAny())).captured.single
              as UpdateListingParams)
          .listing;

  Property capturedCreate() =>
      (verify(() => createListing(captureAny())).captured.single
              as CreateListingParams)
          .listing;

  setUpAll(() {
    registerFallbackValue(const CreateListingParams(_anyProperty));
    registerFallbackValue(const UpdateListingParams(_anyProperty));
  });

  setUp(() {
    createListing = _MockCreateListing();
    updateListing = _MockUpdateListing();

    when(
      () => createListing(any()),
    ).thenAnswer((_) async => Success(buildProperty()));
    when(
      () => updateListing(any()),
    ).thenAnswer((_) async => Success(buildProperty()));
  });

  CreateListingCubit build({Property? existing}) => CreateListingCubit(
    createListing: createListing,
    updateListing: updateListing,
    photoService: _NoopPhotoService(),
    existing: existing,
  );

  /// Submits the form with the fields the page would supply.
  Future<void> submit(
    CreateListingCubit cubit, {
    LifestyleProfile? hostLifestyle,
  }) => cubit.submit(
    name: 'A Room',
    address: 'KG 11 Ave',
    description: 'Bright and close to campus.',
    pricePerMonth: 150,
    contactName: 'Jane',
    contactPhone: '+250780000000',
    images: const ['https://example.com/a.jpg'],
    hostLifestyle: hostLifestyle,
  );

  group('publishing a new listing', () {
    test('routes to CreateListing, not UpdateListing', () async {
      await submit(build());

      // capturedCreate() asserts exactly one call on its own.
      expect(capturedCreate().name, 'A Room');
      verifyNever(() => updateListing(any()));
    });

    test('starts with no rating or baseline score', () async {
      await submit(build());

      final published = capturedCreate();
      expect(published.rating, 0);
      expect(published.compatibility, 0);
    });

    test('has no id yet — the backend assigns one', () async {
      await submit(build());

      expect(capturedCreate().id, isEmpty);
    });
  });

  group('editing an existing listing', () {
    final existing = buildProperty(
      id: 'listing-1',
      name: 'Original Name',
      rating: 4.6,
      compatibility: 88,
      ownerUid: 'uid-1',
      hostLifestyle: const LifestyleProfile(),
    );

    test('routes to UpdateListing and keeps the same document id', () async {
      await submit(build(existing: existing));

      verifyNever(() => createListing(any()));
      expect(capturedUpdate().id, 'listing-1');
    });

    test('preserves the rating and baseline score already earned', () async {
      await submit(build(existing: existing));

      final saved = capturedUpdate();
      expect(saved.rating, 4.6);
      expect(saved.compatibility, 88);
    });

    test(
      'preserves ownerUid, which the security rules pin as immutable',
      () async {
        await submit(build(existing: existing));

        expect(capturedUpdate().ownerUid, 'uid-1');
      },
    );

    test('keeps the stored lifestyle when the editor has no profile', () async {
      // The quiz lives in device-local storage, so a host editing from a
      // second device supplies null here. Overwriting would strip the
      // listing's compatibility data for every student browsing it.
      await submit(build(existing: existing), hostLifestyle: null);

      final saved = capturedUpdate();
      expect(saved.hostLifestyle, isNotNull);
      expect(saved.hostLifestyle, existing.hostLifestyle);
    });

    test('adopts the editor profile when one is loaded', () async {
      const updated = LifestyleProfile(bedtime: Bedtime.afterTwo);

      await submit(build(existing: existing), hostLifestyle: updated);

      expect(capturedUpdate().hostLifestyle, updated);
    });

    test('seeds the form toggles from the listing being edited', () {
      final cubit = build(
        existing: buildProperty(
          bedrooms: 3,
          bathrooms: 2,
          hostType: HostType.realtor,
          listingKind: ListingKind.entirePlace,
        ),
      );

      expect(cubit.isEditing, isTrue);
      expect(cubit.state.bedrooms, 3);
      expect(cubit.state.bathrooms, 2);
      expect(cubit.state.hostType, HostType.realtor);
      expect(cubit.state.listingKind, ListingKind.entirePlace);
    });

    test('an entire-place listing carries no lifestyle at all', () async {
      final wholeFlat = buildProperty(
        id: 'listing-2',
        hostType: HostType.realtor,
        listingKind: ListingKind.entirePlace,
      );

      await submit(
        build(existing: wholeFlat),
        hostLifestyle: const LifestyleProfile(),
      );

      // There is no housemate to be compatible with.
      expect(capturedUpdate().hostLifestyle, isNull);
    });
  });
}

/// Fallback value for mocktail's `any()` registration.
const _anyProperty = Property(
  id: '',
  name: '',
  address: '',
  description: '',
  pricePerMonth: 0,
  rating: 0,
  compatibility: 0,
  images: [],
  bedrooms: 1,
  bathrooms: 1,
  agentName: '',
  agentPhone: '',
);
