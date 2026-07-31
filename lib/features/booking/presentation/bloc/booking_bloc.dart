import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/booking.dart';
import '../../domain/usecases/cancel_booking.dart';
import '../../domain/usecases/create_booking.dart';
import '../../domain/usecases/get_bookings.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final GetBookings getBookings;
  final CreateBooking createBooking;
  final CancelBooking cancelBooking;

  BookingBloc({
    required this.getBookings,
    required this.createBooking,
    required this.cancelBooking,
  }) : super(const BookingState()) {
    on<BookingsRequested>(_onBookingsRequested);
    on<BookingSubmitted>(_onBookingSubmitted);
    on<BookingCancelled>(_onBookingCancelled);
  }

  Future<void> _onBookingsRequested(
    BookingsRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(status: BookingViewStatus.loading));
    final result = await getBookings(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BookingViewStatus.failure,
          message: failure.message,
        ),
      ),
      (bookings) => emit(
        state.copyWith(status: BookingViewStatus.loaded, bookings: bookings),
      ),
    );
  }

  Future<void> _onBookingSubmitted(
    BookingSubmitted event,
    Emitter<BookingState> emit,
  ) async {
    // One active booking per property. Without this a student can book the
    // same room repeatedly and end up with several live bookings for a place
    // they can only actually take once. Completed and cancelled stays are not
    // counted, so re-booking somewhere you stayed before is still allowed.
    final alreadyBooked = state.upcoming.any(
      (b) => b.propertyId == event.booking.propertyId,
    );
    if (alreadyBooked) {
      emit(
        state.copyWith(
          status: BookingViewStatus.failure,
          message: 'You already have an active booking for this place.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: BookingViewStatus.creating));
    final result = await createBooking(event.booking);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BookingViewStatus.failure,
          message: failure.message,
        ),
      ),
      (booking) => emit(
        state.copyWith(
          status: BookingViewStatus.created,
          bookings: [booking, ...state.bookings],
        ),
      ),
    );
  }

  Future<void> _onBookingCancelled(
    BookingCancelled event,
    Emitter<BookingState> emit,
  ) async {
    final result = await cancelBooking(event.bookingId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BookingViewStatus.loaded,
          message: failure.message,
        ),
      ),
      (_) {
        // Confirm before refetching: BookingsRequested clears the message, so
        // emitting afterwards would leave the cancellation silent.
        emit(
          state.copyWith(
            status: BookingViewStatus.loaded,
            message: 'Booking cancelled.',
          ),
        );
        add(const BookingsRequested());
      },
    );
  }
}
