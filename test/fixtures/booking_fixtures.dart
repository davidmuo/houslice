import 'package:houslice/features/booking/data/models/booking_model.dart';
import 'package:houslice/features/booking/domain/entities/booking.dart';

/// Builds a booking with sensible defaults so tests only state what matters.
BookingModel buildBooking({
  String id = 'b1',
  String propertyId = 'ayana',
  String propertyName = 'Ayana',
  String propertyAddress = '5 Vision Heights, Kimihurura',
  String propertyImage = 'https://example.com/a.jpg',
  DateTime? startDate,
  DateTime? endDate,
  num monthlyPrice = 120,
  num tax = 10,
  BookingStatus status = BookingStatus.waitingPayment,
}) {
  return BookingModel(
    id: id,
    propertyId: propertyId,
    propertyName: propertyName,
    propertyAddress: propertyAddress,
    propertyImage: propertyImage,
    startDate: startDate ?? DateTime(2026, 8, 1),
    endDate: endDate ?? DateTime(2026, 9, 1),
    monthlyPrice: monthlyPrice,
    tax: tax,
    status: status,
  );
}
