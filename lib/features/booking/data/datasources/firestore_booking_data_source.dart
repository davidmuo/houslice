import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/booking.dart';
import '../models/booking_model.dart';
import 'booking_data_source.dart';

/// Bookings stored per student at `users/{uid}/bookings`.
class FirestoreBookingDataSource implements BookingDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  FirestoreBookingDataSource({required this.firestore, required this.auth});

  CollectionReference<Map<String, dynamic>> get _bookings {
    final uid = auth.currentUser?.uid;
    if (uid == null) {
      throw const ServerException('Sign in to manage bookings.');
    }
    return firestore.collection('users').doc(uid).collection('bookings');
  }

  @override
  Future<List<BookingModel>> fetchBookings() async {
    try {
      final snapshot = await _bookings.get();
      final bookings =
          snapshot.docs
              .map((doc) => BookingModel.fromMap(doc.id, doc.data()))
              .toList()
            ..sort((a, b) => b.startDate.compareTo(a.startDate));
      return bookings;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Could not load bookings.');
    }
  }

  @override
  Future<BookingModel> createBooking(BookingModel booking) async {
    try {
      final doc = await _bookings.add({
        ...booking.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return booking.withId(doc.id);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Could not create the booking.');
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _bookings.doc(bookingId).update({
        'status': BookingStatus.cancelled.name,
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Could not cancel the booking.');
    }
  }
}
