import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_data_source.dart';
import '../models/booking_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingDataSource dataSource;

  BookingRepositoryImpl(this.dataSource);

  Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Success(await run());
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } catch (_) {
      return const Err(ServerFailure());
    }
  }

  @override
  Future<Result<List<Booking>>> getBookings() =>
      _guard(() => dataSource.fetchBookings());

  @override
  Future<Result<Booking>> createBooking(Booking booking) =>
      _guard(() => dataSource.createBooking(BookingModel.fromEntity(booking)));

  @override
  Future<Result<void>> cancelBooking(String bookingId) =>
      _guard(() => dataSource.cancelBooking(bookingId));
}
