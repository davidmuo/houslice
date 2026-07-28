import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';
import 'auth_data_source.dart';

/// Firebase-backed auth: FirebaseAuth for credentials plus a `users`
/// Firestore collection for profile data (username, photo).
class FirebaseAuthDataSource implements AuthDataSource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  FirebaseAuthDataSource({required this.auth, required this.firestore});

  CollectionReference<Map<String, dynamic>> get _users =>
      firestore.collection('users');

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _profileFor(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyMessage(e.code));
    }
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      await user.updateDisplayName(username);
      final model = UserModel(uid: user.uid, email: email, username: username);
      await _users.doc(user.uid).set({
        ...model.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return model;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyMessage(e.code));
    }
  }

  @override
  Future<void> signOut() => auth.signOut();

  @override
  Future<UserModel?> currentUser() async {
    final user = auth.currentUser;
    if (user == null) return null;
    return _profileFor(user);
  }

  @override
  Future<void> changePassword(String newPassword) async {
    final user = auth.currentUser;
    if (user == null) {
      throw const AuthException('You need to be signed in to do that.');
    }
    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyMessage(e.code));
    }
  }

  Future<UserModel> _profileFor(User user) async {
    final doc = await _users.doc(user.uid).get();
    if (doc.exists) {
      final model = UserModel.fromMap(user.uid, doc.data()!);
      if (model.username.isNotEmpty) return model;
    }
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      username: user.displayName ?? (user.email?.split('@').first ?? 'Student'),
      photoUrl: user.photoURL,
    );
  }

  String _friendlyMessage(String code) => switch (code) {
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' =>
          'Incorrect email or password.',
        'email-already-in-use' =>
          'An account already exists with this email. Sign in instead.',
        'invalid-email' => 'That email address is not valid.',
        'weak-password' => 'Password is too weak. Use at least 6 characters.',
        'network-request-failed' =>
          'No internet connection. Check your network.',
        'requires-recent-login' =>
          'Please sign in again before changing your password.',
        'too-many-requests' => 'Too many attempts. Try again in a moment.',
        _ => 'Authentication failed. Please try again.',
      };
}
