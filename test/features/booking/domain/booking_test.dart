import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/features/booking/domain/entities/booking.dart';

import '../../../fixtures/booking_fixtures.dart';

/// Unit tests for the Booking entity's pricing maths and status helpers.
void main() {
  group('periodMonths', () {
    test('a stay under 30 days still bills one period', () {
      final booking = buildBooking(
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 8, 10),
      );

      expect(booking.periodMonths, 1);
    });

    test('a same-day range bills one period', () {
      final booking = buildBooking(
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 8, 1),
      );

      expect(booking.periodMonths, 1);
    });

    test('31 days rounds up to two periods', () {
      final booking = buildBooking(
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 9, 1),
      );

      expect(booking.periodMonths, 2);
    });
  });

  group('total', () {
    test('is price times periods plus tax', () {
      final booking = buildBooking(
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 8, 10),
        monthlyPrice: 120,
        tax: 10,
      );

      // 1 period * 120 + 10
      expect(booking.total, 130);
    });

    test('multiplies across a longer stay', () {
      final booking = buildBooking(
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 10, 1),
        monthlyPrice: 100,
        tax: 25,
      );

      // 61 days -> ceil(61/30) == 3 periods
      expect(booking.periodMonths, 3);
      expect(booking.total, 325);
    });
  });

  group('BookingStatusX', () {
    test('every status has a human label', () {
      for (final status in BookingStatus.values) {
        expect(status.label, isNotEmpty);
      }
      expect(BookingStatus.waitingPayment.label, 'Waiting payment');
      expect(BookingStatus.checkin.label, 'Checkin');
      expect(BookingStatus.completed.label, 'Completed');
      expect(BookingStatus.cancelled.label, 'Cancelled');
    });

    test('only waitingPayment and checkin count as upcoming', () {
      expect(BookingStatus.waitingPayment.isUpcoming, isTrue);
      expect(BookingStatus.checkin.isUpcoming, isTrue);
      expect(BookingStatus.completed.isUpcoming, isFalse);
      expect(BookingStatus.cancelled.isUpcoming, isFalse);
    });
  });

  group('equality', () {
    test('identical bookings are equal', () {
      expect(buildBooking(), buildBooking());
    });

    test('a different status breaks equality', () {
      expect(
        buildBooking(status: BookingStatus.completed),
        isNot(buildBooking(status: BookingStatus.cancelled)),
      );
    });
  });
}
