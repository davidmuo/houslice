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
        // Best-effort bootstrap. The security rules only accept listings whose
        // ownerUid is the caller, so this is denied unless an administrator
        // has relaxed them for seeding — see docs/ERD.md. A denial must leave
        // the student with an empty catalogue, never a broken screen.
        try {
          await _seed();
          snapshot = await _properties.get();
        } on FirebaseException {
          return const [];
        }
      }
      final favoriteIds = await _favoriteIds();
      return snapshot.docs
          .map(
            (doc) => PropertyModel.fromMap(
              doc.id,
              doc.data(),
            ).withFavorite(favoriteIds.contains(doc.id)),
          )
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
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              p.address.toLowerCase().contains(q),
        )
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

  @override
  Future<PropertyModel> createListing(PropertyModel listing) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) {
      throw const ServerException('Sign in to publish a listing.');
    }
    try {
      // ownerUid must match the caller — the security rules reject anything
      // else, which is what stops a student publishing on someone's behalf.
      final owned = PropertyModel.fromEntity(listing).withOwner(uid);
      final doc = await _properties.add(owned.toMap());
      return owned.withId(doc.id);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Could not publish the listing.');
    }
  }

  @override
  Future<PropertyModel> updateListing(PropertyModel listing) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) {
      throw const ServerException('Sign in to edit a listing.');
    }
    if (listing.ownerUid != uid) {
      // The rules would reject this anyway; failing here gives the student a
      // sentence they can act on instead of a raw permission-denied.
      throw const ServerException('You can only edit your own listings.');
    }
    try {
      // A full document write rather than a partial update: the rules pin
      // ownerUid to its existing value, so the whole map is safe to send and
      // the stored document can never drift from the model.
      await _properties.doc(listing.id).set(listing.toMap());
      return listing;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Could not save the listing.');
    }
  }

  @override
  Future<void> deleteListing(String propertyId) async {
    if (auth.currentUser == null) {
      throw const ServerException('Sign in to delete a listing.');
    }
    try {
      await _properties.doc(propertyId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Could not delete the listing.');
    }

    // Tidying the caller's own favourite is best-effort and deliberately in
    // its own try: the listing is already gone, so letting a failure here
    // propagate would report a successful delete as failed and put the row
    // back in a UI that no longer matches the backend. An orphaned favourite
    // is harmless — it matches no listing on read and is filtered out.
    try {
      await _favorites?.doc(propertyId).delete();
    } on FirebaseException {
      // Ignored deliberately; see above.
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
