import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class GetBookings extends UseCase<List<Booking>, NoParams> {
  final BookingRepository repository;

  GetBookings(this.repository);

  @override
  Future<Result<List<Booking>>> call(NoParams params) =>
      repository.getBookings();
}
