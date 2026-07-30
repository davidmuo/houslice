import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/features/property/data/models/property_model.dart';
import 'package:houslice/features/property/data/seed_properties.dart';

/// Unit tests for listing serialisation to and from Firestore documents.
void main() {
  group('toMap', () {
    test('writes every catalogue field', () {
      final map = kSeedProperties.first.toMap();

      expect(map['name'], 'Ayana');
      expect(map['address'], isNotEmpty);
      expect(map['description'], isNotEmpty);
      expect(map['pricePerMonth'], 120);
      expect(map['rating'], 4.6);
      expect(map['compatibility'], 87);
      expect(map['images'], isA<List<String>>());
      expect(map['bedrooms'], 3);
      expect(map['bathrooms'], 2);
      expect(map['agentName'], 'Aline Uwase');
      expect(map['agentPhone'], isNotEmpty);
    });

    test('persists neither the id nor the per-user favourite flag', () {
      final map = kSeedProperties.first.toMap();

      expect(map.containsKey('id'), isFalse);
      // Favourites live under users/{uid}/favorites, never on the listing.
      expect(map.containsKey('isFavorite'), isFalse);
    });
  });

  group('fromMap', () {
    test('round-trips a listing through toMap', () {
      final original = kSeedProperties.first;

      final restored = PropertyModel.fromMap(original.id, original.toMap());

      expect(restored, original);
    });

    test('falls back to safe defaults for an empty document', () {
      final restored = PropertyModel.fromMap('x', <String, dynamic>{});

      expect(restored.id, 'x');
      expect(restored.name, '');
      expect(restored.pricePerMonth, 0);
      expect(restored.rating, 0);
      expect(restored.compatibility, 0);
      expect(restored.images, isEmpty);
      expect(restored.bedrooms, 1);
      expect(restored.bathrooms, 1);
      expect(restored.isFavorite, isFalse);
    });

    test('coerces numeric types coming back from Firestore', () {
      final restored = PropertyModel.fromMap('x', {
        'rating': 4, // int where a double is expected
        'compatibility': 87.0, // double where an int is expected
        'bedrooms': 2.0,
      });

      expect(restored.rating, 4.0);
      expect(restored.compatibility, 87);
      expect(restored.bedrooms, 2);
    });

    test('reads the images list', () {
      final restored = PropertyModel.fromMap('x', {
        'images': ['a.jpg', 'b.jpg'],
      });

      expect(restored.images, ['a.jpg', 'b.jpg']);
      expect(restored.coverImage, 'a.jpg');
    });
  });

  group('withFavorite', () {
    test('sets the flag without touching anything else', () {
      final original = kSeedProperties.first;

      final favourited = original.withFavorite(true);

      expect(favourited.isFavorite, isTrue);
      expect(favourited.id, original.id);
      expect(favourited.name, original.name);
      expect(favourited.images, original.images);
    });

    test('can clear the flag again', () {
      expect(
        kSeedProperties.first.withFavorite(true).withFavorite(false).isFavorite,
        isFalse,
      );
    });
  });

  group('seed catalogue', () {
    test('every listing has the fields the UI needs', () {
      for (final property in kSeedProperties) {
        expect(property.id, isNotEmpty);
        expect(property.name, isNotEmpty);
        expect(property.images, isNotEmpty);
        expect(property.pricePerMonth, greaterThan(0));
        expect(property.compatibility, inInclusiveRange(0, 100));
        expect(property.rating, inInclusiveRange(0, 5));
      }
    });
  });
}
