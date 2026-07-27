import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../models/property_model.dart';
import '../seed_properties.dart';
import 'property_data_source.dart';

/// Firestore-backed listings.
///
/// - `properties`               → the marketplace catalogue (auto-seeded on
///                                first launch so a fresh Firebase project
///                                is immediately demoable)
/// - `users/{uid}/favorites`    → per-student favorite listing ids
class FirestorePropertyDataSource implements PropertyDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  FirestorePropertyDataSource({required this.firestore, required this.auth});

  CollectionReference<Map<String, dynamic>> get _properties =>
      firestore.collection('properties');

  CollectionReference<Map<String, dynamic>>? get _favorites {
    final uid = auth.currentUser?.uid;
    if (uid == null) return null;
    return firestore.collection('users').doc(uid).collection('favorites');
  }

  @override
  Future<List<PropertyModel>> fetchProperties() async {
    try {
      var snapshot = await _properties.get();
      if (snapshot.docs.isEmpty) {
        await _seed();
        snapshot = await _properties.get();
      }
      final favoriteIds = await _favoriteIds();
      return snapshot.docs
          .map((doc) => PropertyModel.fromMap(doc.id, doc.data())
              .withFavorite(favoriteIds.contains(doc.id)))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Could not load properties.');
    }
  }

  @override
  Future<List<PropertyModel>> search(String query) async {
    final all = await fetchProperties();
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.address.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<bool> toggleFavorite(String propertyId) async {
    final favorites = _favorites;
    if (favorites == null) {
      throw const ServerException('Sign in to save favorites.');
    }
    try {
      final doc = favorites.doc(propertyId);
      final existing = await doc.get();
      if (existing.exists) {
        await doc.delete();
        return false;
      }
      await doc.set({'savedAt': FieldValue.serverTimestamp()});
      return true;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Could not update favorite.');
    }
  }

  Future<Set<String>> _favoriteIds() async {
    final favorites = _favorites;
    if (favorites == null) return {};
    final snapshot = await favorites.get();
    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  Future<void> _seed() async {
    final batch = firestore.batch();
    for (final property in kSeedProperties) {
      batch.set(_properties.doc(property.id), property.toMap());
    }
    await batch.commit();
  }
}
