import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/property_fixtures.dart';

/// Unit tests for the Property entity.
void main() {
  group('coverImage', () {
    test('is the first image when there are any', () {
      final property = buildProperty(images: const ['first.jpg', 'second.jpg']);

      expect(property.coverImage, 'first.jpg');
    });

    test('is an empty string when the listing has no photos', () {
      final property = buildProperty(images: const []);

      expect(property.coverImage, '');
    });
  });

  group('copyWith', () {
    test('flips the favourite flag and leaves everything else alone', () {
      final original = buildProperty(isFavorite: false);
      final updated = original.copyWith(isFavorite: true);

      expect(updated.isFavorite, isTrue);
      expect(updated.id, original.id);
      expect(updated.name, original.name);
      expect(updated.pricePerMonth, original.pricePerMonth);
      expect(updated.images, original.images);
    });

    test('keeps the current value when nothing is passed', () {
      final original = buildProperty(isFavorite: true);

      expect(original.copyWith().isFavorite, isTrue);
    });
  });

  group('equality', () {
    test('two listings with identical fields are equal', () {
      expect(buildProperty(), buildProperty());
    });

    test('the favourite flag participates in equality', () {
      expect(
        buildProperty(isFavorite: true),
        isNot(buildProperty(isFavorite: false)),
      );
    });
  });
}
