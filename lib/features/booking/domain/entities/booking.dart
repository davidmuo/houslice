import 'dart:math' as math;

import 'package:equatable/equatable.dart';

enum BookingStatus { waitingPayment, checkin, completed, cancelled }

extension BookingStatusX on BookingStatus {
  String get label => switch (this) {
        BookingStatus.waitingPayment => 'Waiting payment',
        BookingStatus.checkin => 'Checkin',
        BookingStatus.completed => 'Completed',
        BookingStatus.cancelled => 'Cancelled',
      };

  bool get isUpcoming =>
      this == BookingStatus.waitingPayment || this == BookingStatus.checkin;
}

/// A stay (long-term or sublet) booked through Houseslice.
class Booking extends Equatable {
  final String id;
  final String propertyId;
  final String propertyName;
  final String propertyAddress;
  final String propertyImage;
  final DateTime startDate;
  final DateTime endDate;
  final num monthlyPrice;
  final num tax;
  final BookingStatus status;

  const Booking({
    required this.id,
    required this.propertyId,
    required this.propertyName,
    required this.propertyAddress,
    required this.propertyImage,
    required this.startDate,
    required this.endDate,
    required this.monthlyPrice,
    required this.tax,
    required this.status,
  });

  /// Monthly billing periods covered by the stay (minimum one).
  int get periodMonths =>
      math.max(1, (endDate.difference(startDate).inDays / 30).ceil());

  num get total => monthlyPrice * periodMonths + tax;

  @override
  List<Object?> get props => [
        id,
        propertyId,
        propertyName,
        propertyAddress,
        propertyImage,
        startDate,
        endDate,
        monthlyPrice,
        tax,
        status,
      ];
}
