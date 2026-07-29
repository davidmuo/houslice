part of 'booking_bloc.dart';

enum BookingViewStatus { initial, loading, loaded, creating, created, failure }

class BookingState extends Equatable {
  final BookingViewStatus status;
  final List<Booking> bookings;
  final String? message;

  const BookingState({
    this.status = BookingViewStatus.initial,
    this.bookings = const [],
    this.message,
  });

  List<Booking> get upcoming =>
      bookings.where((b) => b.status.isUpcoming).toList();

  List<Booking> get completed =>
      bookings.where((b) => b.status == BookingStatus.completed).toList();

  List<Booking> get cancelled =>
      bookings.where((b) => b.status == BookingStatus.cancelled).toList();

  BookingState copyWith({
    BookingViewStatus? status,
    List<Booking>? bookings,
    String? message,
  }) =>
      BookingState(
        status: status ?? this.status,
        bookings: bookings ?? this.bookings,
        message: message,
      );

  @override
  List<Object?> get props => [status, bookings, message];
}
