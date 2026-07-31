import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/core/error/failures.dart';
import 'package:houslice/core/error/result.dart';
import 'package:houslice/core/usecases/usecase.dart';
import 'package:houslice/features/booking/domain/entities/booking.dart';
import 'package:houslice/features/booking/domain/usecases/cancel_booking.dart';
import 'package:houslice/features/booking/domain/usecases/create_booking.dart';
import 'package:houslice/features/booking/domain/usecases/get_bookings.dart';
import 'package:houslice/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures/booking_fixtures.dart';

class _MockGetBookings extends Mock implements GetBookings {}

class _MockCreateBooking extends Mock implements CreateBooking {}

class _MockCancelBooking extends Mock implements CancelBooking {}

/// Bloc tests for creating, guarding against duplicates, and cancelling.
void main() {
  late _MockGetBookings getBookings;
  late _MockCreateBooking createBooking;
  late _MockCancelBooking cancelBooking;

  final existing = buildBooking(
    id: 'b1',
    propertyId: 'ayana',
    status: BookingStatus.checkin,
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(buildBooking());
    registerFallbackValue('b1');
  });

  setUp(() {
    getBookings = _MockGetBookings();
    createBooking = _MockCreateBooking();
    cancelBooking = _MockCancelBooking();
  });

  BookingBloc build() => BookingBloc(
    getBookings: getBookings,
    createBooking: createBooking,
    cancelBooking: cancelBooking,
  );

  group('BookingSubmitted', () {
    blocTest<BookingBloc, BookingState>(
      'creates a booking when the property has no active booking',
      setUp: () {
        when(() => createBooking(any())).thenAnswer(
          (_) async => Success(buildBooking(id: 'new', propertyId: 'simba')),
        );
      },
      build: build,
      seed: () =>
          BookingState(status: BookingViewStatus.loaded, bookings: [existing]),
      act: (bloc) =>
          bloc.add(BookingSubmitted(buildBooking(propertyId: 'simba'))),
      expect: () => [
        isA<BookingState>().having(
          (s) => s.status,
          'status',
          BookingViewStatus.creating,
        ),
        isA<BookingState>()
            .having((s) => s.status, 'status', BookingViewStatus.created)
            .having((s) => s.bookings.length, 'bookings', 2),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'refuses a second active booking for the same property',
      build: build,
      seed: () =>
          BookingState(status: BookingViewStatus.loaded, bookings: [existing]),
      act: (bloc) =>
          bloc.add(BookingSubmitted(buildBooking(propertyId: 'ayana'))),
      expect: () => [
        isA<BookingState>()
            .having((s) => s.status, 'status', BookingViewStatus.failure)
            .having(
              (s) => s.message,
              'message',
              'You already have an active booking for this place.',
            ),
      ],
      verify: (_) => verifyNever(() => createBooking(any())),
    );

    blocTest<BookingBloc, BookingState>(
      'allows re-booking a property whose previous stay was cancelled',
      setUp: () {
        when(() => createBooking(any())).thenAnswer(
          (_) async => Success(buildBooking(id: 'new', propertyId: 'ayana')),
        );
      },
      build: build,
      seed: () => BookingState(
        status: BookingViewStatus.loaded,
        bookings: [
          buildBooking(
            id: 'old',
            propertyId: 'ayana',
            status: BookingStatus.cancelled,
          ),
        ],
      ),
      act: (bloc) =>
          bloc.add(BookingSubmitted(buildBooking(propertyId: 'ayana'))),
      expect: () => [
        isA<BookingState>().having(
          (s) => s.status,
          'status',
          BookingViewStatus.creating,
        ),
        isA<BookingState>().having(
          (s) => s.status,
          'status',
          BookingViewStatus.created,
        ),
      ],
    );
  });

  group('BookingCancelled', () {
    blocTest<BookingBloc, BookingState>(
      'confirms the cancellation before refetching',
      setUp: () {
        when(
          () => cancelBooking(any()),
        ).thenAnswer((_) async => const Success(null));
        when(
          () => getBookings(any()),
        ).thenAnswer((_) async => const Success([]));
      },
      build: build,
      seed: () =>
          BookingState(status: BookingViewStatus.loaded, bookings: [existing]),
      act: (bloc) => bloc.add(const BookingCancelled('b1')),
      expect: () => [
        // The confirmation has to be emitted before the refetch, because
        // BookingsRequested clears the message.
        isA<BookingState>().having(
          (s) => s.message,
          'message',
          'Booking cancelled.',
        ),
        isA<BookingState>().having(
          (s) => s.status,
          'status',
          BookingViewStatus.loading,
        ),
        isA<BookingState>().having(
          (s) => s.status,
          'status',
          BookingViewStatus.loaded,
        ),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'surfaces the failure message when the cancel is rejected',
      setUp: () {
        when(() => cancelBooking(any())).thenAnswer(
          (_) async => const Err(ServerFailure('Could not cancel.')),
        );
      },
      build: build,
      seed: () =>
          BookingState(status: BookingViewStatus.loaded, bookings: [existing]),
      act: (bloc) => bloc.add(const BookingCancelled('b1')),
      expect: () => [
        isA<BookingState>()
            .having((s) => s.message, 'message', 'Could not cancel.')
            // The booking stays in the list: nothing was removed optimistically.
            .having((s) => s.bookings.length, 'bookings', 1),
      ],
      verify: (_) => verifyNever(() => getBookings(any())),
    );
  });
}
