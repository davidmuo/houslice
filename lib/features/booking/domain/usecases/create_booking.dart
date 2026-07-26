import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class CreateBooking extends UseCase<Booking, Booking> {
  final BookingRepository repository;

  CreateBooking(this.repository);

  @override
  Future<Result<Booking>> call(Booking params) =>
      repository.createBooking(params);
}
