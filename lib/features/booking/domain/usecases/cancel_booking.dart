import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/booking_repository.dart';

class CancelBooking extends UseCase<void, String> {
  final BookingRepository repository;

  CancelBooking(this.repository);

  @override
  Future<Result<void>> call(String params) => repository.cancelBooking(params);
}
