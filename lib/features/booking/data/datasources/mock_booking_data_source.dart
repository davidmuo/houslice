import '../../../../core/error/exceptions.dart';
import '../../domain/entities/booking.dart';
import '../models/booking_model.dart';
import 'booking_data_source.dart';

/// In-memory bookings used in demo mode, pre-seeded to match the Figma
/// "My Booking" screens (waiting payment, check-in, completed).
class MockBookingDataSource implements BookingDataSource {
  static DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  final List<BookingModel> _bookings = [
    BookingModel(
      id: 'bk-mavoona',
      propertyId: 'mavoona',
      propertyName: 'Mavoona Apartments',
      propertyAddress: '88 Inyange Street, Remera, Kigali, Rwanda',
      propertyImage:
          'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800&q=60',
      startDate: _today.add(const Duration(days: 24)),
      endDate: _today.add(const Duration(days: 55)),
      monthlyPrice: 320,
      tax: 10,
      status: BookingStatus.waitingPayment,
    ),
    BookingModel(
      id: 'bk-takitea-up',
      propertyId: 'takitea',
      propertyName: 'Takitea Homestay',
      propertyAddress: '88 Inyange Street, Remera, Kigali, Rwanda',
      propertyImage:
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&q=60',
      startDate: _today.add(const Duration(days: 3)),
      endDate: _today.add(const Duration(days: 7)),
      monthlyPrice: 150,
      tax: 10,
      status: BookingStatus.checkin,
    ),
    BookingModel(
      id: 'bk-takitea-done',
      propertyId: 'takitea',
      propertyName: 'Takitea Homestay',
      propertyAddress: '5 Vision Heights, Kimihurura, Kigali, Rwanda',
      propertyImage:
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&q=60',
      startDate: _today.subtract(const Duration(days: 30)),
      endDate: _today.subtract(const Duration(days: 26)),
      monthlyPrice: 150,
      tax: 10,
      status: BookingStatus.completed,
    ),
  ];

  @override
  Future<List<BookingModel>> fetchBookings() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final bookings = List.of(_bookings)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    return bookings;
  }

  @override
  Future<BookingModel> createBooking(BookingModel booking) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final created =
        booking.withId('bk-${DateTime.now().millisecondsSinceEpoch}');
    _bookings.add(created);
    return created;
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) {
      throw const ServerException('Booking not found.');
    }
    _bookings[index] = _bookings[index].withStatus(BookingStatus.cancelled);
  }
}
