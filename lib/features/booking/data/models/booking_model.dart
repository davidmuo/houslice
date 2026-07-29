import '../../domain/entities/booking.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.propertyId,
    required super.propertyName,
    required super.propertyAddress,
    required super.propertyImage,
    required super.startDate,
    required super.endDate,
    required super.monthlyPrice,
    required super.tax,
    required super.status,
  });

  factory BookingModel.fromEntity(Booking booking) => BookingModel(
    id: booking.id,
    propertyId: booking.propertyId,
    propertyName: booking.propertyName,
    propertyAddress: booking.propertyAddress,
    propertyImage: booking.propertyImage,
    startDate: booking.startDate,
    endDate: booking.endDate,
    monthlyPrice: booking.monthlyPrice,
    tax: booking.tax,
    status: booking.status,
  );

  factory BookingModel.fromMap(String id, Map<String, dynamic> map) =>
      BookingModel(
        id: id,
        propertyId: (map['propertyId'] ?? '') as String,
        propertyName: (map['propertyName'] ?? '') as String,
        propertyAddress: (map['propertyAddress'] ?? '') as String,
        propertyImage: (map['propertyImage'] ?? '') as String,
        startDate: _parseDate(map['startDate']),
        endDate: _parseDate(map['endDate']),
        monthlyPrice: (map['monthlyPrice'] ?? 0) as num,
        tax: (map['tax'] ?? 0) as num,
        status: _parseStatus(map['status']),
      );

  Map<String, dynamic> toMap() => {
    'propertyId': propertyId,
    'propertyName': propertyName,
    'propertyAddress': propertyAddress,
    'propertyImage': propertyImage,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'monthlyPrice': monthlyPrice,
    'tax': tax,
    'status': status.name,
  };

  BookingModel withId(String newId) => BookingModel(
    id: newId,
    propertyId: propertyId,
    propertyName: propertyName,
    propertyAddress: propertyAddress,
    propertyImage: propertyImage,
    startDate: startDate,
    endDate: endDate,
    monthlyPrice: monthlyPrice,
    tax: tax,
    status: status,
  );

  BookingModel withStatus(BookingStatus newStatus) => BookingModel(
    id: id,
    propertyId: propertyId,
    propertyName: propertyName,
    propertyAddress: propertyAddress,
    propertyImage: propertyImage,
    startDate: startDate,
    endDate: endDate,
    monthlyPrice: monthlyPrice,
    tax: tax,
    status: newStatus,
  );

  /// Accepts ISO-8601 strings and Firestore Timestamps.
  static DateTime _parseDate(dynamic value) {
    if (value is String) return DateTime.parse(value);
    if (value == null) return DateTime.now();
    return (value as dynamic).toDate() as DateTime;
  }

  static BookingStatus _parseStatus(dynamic value) {
    if (value is String) {
      for (final status in BookingStatus.values) {
        if (status.name == value) return status;
      }
    }
    return BookingStatus.waitingPayment;
  }
}
