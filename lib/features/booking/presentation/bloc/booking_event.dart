part of 'booking_bloc.dart';

sealed class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class BookingsRequested extends BookingEvent {
  const BookingsRequested();
}

class BookingSubmitted extends BookingEvent {
  final Booking booking;

  const BookingSubmitted(this.booking);

  @override
  List<Object?> get props => [booking];
}

class BookingCancelled extends BookingEvent {
  final String bookingId;

  const BookingCancelled(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}
