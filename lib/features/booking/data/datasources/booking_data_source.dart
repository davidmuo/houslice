import '../models/booking_model.dart';

/// Contract for booking backends. Implemented by
/// [FirestoreBookingDataSource] (production) and
/// [MockBookingDataSource] (demo mode).
abstract class BookingDataSource {
  Future<List<BookingModel>> fetchBookings();

  Future<BookingModel> createBooking(BookingModel booking);

  Future<void> cancelBooking(String bookingId);
}
