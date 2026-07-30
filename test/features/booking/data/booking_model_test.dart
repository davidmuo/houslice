import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/features/booking/data/models/booking_model.dart';
import 'package:houslice/features/booking/domain/entities/booking.dart';

import '../../../fixtures/booking_fixtures.dart';

/// Unit tests for booking serialisation to and from Firestore documents.
void main() {
  group('toMap', () {
    test('writes every persisted field, dates as ISO-8601', () {
      final map = buildBooking(
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 9, 1),
        status: BookingStatus.checkin,
      ).toMap();

      expect(map['propertyId'], 'ayana');
      expect(map['propertyName'], 'Ayana');
      expect(map['propertyAddress'], '5 Vision Heights, Kimihurura');
      expect(map['propertyImage'], 'https://example.com/a.jpg');
      expect(map['startDate'], DateTime(2026, 8, 1).toIso8601String());
      expect(map['endDate'], DateTime(2026, 9, 1).toIso8601String());
      expect(map['monthlyPrice'], 120);
      expect(map['tax'], 10);
      expect(map['status'], 'checkin');
    });

    test('does not persist the document id inside the body', () {
      expect(buildBooking().toMap().containsKey('id'), isFalse);
    });
  });

  group('fromMap', () {
    test('round-trips a booking through toMap', () {
      final original = buildBooking(status: BookingStatus.completed);

      final restored = BookingModel.fromMap(original.id, original.toMap());

      expect(restored, original);
    });

    test('parses ISO-8601 date strings', () {
      final restored = BookingModel.fromMap('x', {
        'startDate': '2026-08-01T00:00:00.000',
        'endDate': '2026-09-01T00:00:00.000',
      });

      expect(restored.startDate, DateTime(2026, 8, 1));
      expect(restored.endDate, DateTime(2026, 9, 1));
    });

    test('falls back to safe defaults for a missing body', () {
      final restored = BookingModel.fromMap('x', <String, dynamic>{});

      expect(restored.id, 'x');
      expect(restored.propertyId, '');
      expect(restored.propertyName, '');
      expect(restored.monthlyPrice, 0);
      expect(restored.tax, 0);
      expect(restored.status, BookingStatus.waitingPayment);
    });

    test('an unrecognised status falls back to waitingPayment', () {
      final restored = BookingModel.fromMap('x', {'status': 'refunded'});

      expect(restored.status, BookingStatus.waitingPayment);
    });

    test('every status name decodes back to its enum value', () {
      for (final status in BookingStatus.values) {
        final restored = BookingModel.fromMap('x', {'status': status.name});
        expect(restored.status, status);
      }
    });
  });

  group('copy helpers', () {
    test('withId replaces only the id', () {
      final original = buildBooking(id: 'old');

      final updated = original.withId('new');

      expect(updated.id, 'new');
      expect(updated.propertyId, original.propertyId);
      expect(updated.monthlyPrice, original.monthlyPrice);
      expect(updated.status, original.status);
    });

    test('withStatus replaces only the status', () {
      final original = buildBooking(status: BookingStatus.waitingPayment);

      final updated = original.withStatus(BookingStatus.cancelled);

      expect(updated.status, BookingStatus.cancelled);
      expect(updated.id, original.id);
      expect(updated.startDate, original.startDate);
    });
  });

  group('fromEntity', () {
    test('carries every field across', () {
      final entity = buildBooking(status: BookingStatus.checkin);

      final model = BookingModel.fromEntity(entity);

      expect(model, entity);
    });
  });
}
