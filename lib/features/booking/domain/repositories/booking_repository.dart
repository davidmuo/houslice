import '../../../../core/error/result.dart';
import '../entities/booking.dart';

abstract class BookingRepository {
  Future<Result<List<Booking>>> getBookings();

  Future<Result<Booking>> createBooking(Booking booking);

  Future<Result<void>> cancelBooking(String bookingId);
}
