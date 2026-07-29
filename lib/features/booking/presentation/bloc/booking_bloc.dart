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
      (_) => add(const BookingsRequested()),
    );
  }
}
