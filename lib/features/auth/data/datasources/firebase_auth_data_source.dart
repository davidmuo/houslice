import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/utils/validators.dart';

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

      // Send the verification link straight away. A failure here must not
      // fail the registration — the account exists and the student can
      // request another link from their profile.
      try {
        await user.sendEmailVerification();
      } on FirebaseAuthException {
        // Ignored deliberately; see above.
      }

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

  /// Web OAuth client from google-services.json. Android needs it as the
  /// `serverClientId` for Google to return an ID token Firebase can accept.
  /// This is a public identifier, not a secret.
  static const _webClientId =
      '485249765763-gk4roc7eogd7ia2f3u81t9ok9oqof6qn.apps.googleusercontent.com';

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize(serverClientId: _webClientId);
      final account = await GoogleSignIn.instance.authenticate();

      // Houseslice is student-only, and a Google account proves nothing about
      // enrolment — so the domain is checked before the Firebase session is
      // created, and the Google session is dropped if it fails.
      if (Validators.studentEmail(account.email) != null) {
        await GoogleSignIn.instance.signOut();
        throw const AuthException(
          'Use your university Google account (e.g. name@alustudent.com).',
        );
      }

      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const AuthException('Google did not return a sign-in token.');
      }

      final credential = await auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
      final user = credential.user!;

      final model = UserModel(
        uid: user.uid,
        email: account.email,
        username: account.displayName ?? account.email.split('@').first,
        photoUrl: account.photoUrl,
      );

      // First Google sign-in creates the profile; later ones leave it alone.
      await _users.doc(user.uid).set({
        ...model.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return model;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthException('Google sign-in was cancelled.');
      }
      throw AuthException(e.description ?? 'Google sign-in failed.');
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyMessage(e.code));
    }
  }

  @override
  Future<void> signOut() async {
    // Clear the Google session too, otherwise the next sign-in silently
    // reuses the previous account without showing the picker.
    try {
      await GoogleSignIn.instance.signOut();
    } on GoogleSignInException {
      // Never signed in with Google — nothing to clear.
    }
    await auth.signOut();
  }

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

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      // Do not leak whether the address exists.
      if (e.code == 'user-not-found') return;
      throw AuthException(_friendlyMessage(e.code));
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String username,
    String? photoUrl,
    String? dateOfBirth,
  }) async {
    final user = auth.currentUser;
    if (user == null) {
      throw const AuthException('You need to be signed in to do that.');
    }
    try {
      await user.updateDisplayName(username);
      if (photoUrl != null) await user.updatePhotoURL(photoUrl);

      final model = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        username: username,
        photoUrl: photoUrl ?? user.photoURL,
        dateOfBirth: dateOfBirth,
        emailVerified: user.emailVerified,
      );
      await _users.doc(user.uid).set(model.toMap(), SetOptions(merge: true));
      return model;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Could not save your profile.');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = auth.currentUser;
    if (user == null) {
      throw const AuthException('You need to be signed in to do that.');
    }
    if (user.emailVerified) return;
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyMessage(e.code));
    }
  }

  Future<UserModel> _profileFor(User user) async {
    final doc = await _users.doc(user.uid).get();
    if (doc.exists) {
      final model = UserModel.fromMap(user.uid, doc.data()!);
      // emailVerified always comes from Firebase Auth, never from the stored
      // document, so it cannot be spoofed by writing to Firestore.
      if (model.username.isNotEmpty) {
        return UserModel(
          uid: model.uid,
          email: model.email,
          username: model.username,
          photoUrl: model.photoUrl,
          dateOfBirth: model.dateOfBirth,
          emailVerified: user.emailVerified,
        );
      }
    }
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      username: user.displayName ?? (user.email?.split('@').first ?? 'Student'),
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
    );
  }

  String _friendlyMessage(String code) => switch (code) {
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' => 'Incorrect email or password.',
    'email-already-in-use' =>
      'An account already exists with this email. Sign in instead.',
    'invalid-email' => 'That email address is not valid.',
    'weak-password' => 'Password is too weak. Use at least 6 characters.',
    'network-request-failed' => 'No internet connection. Check your network.',
    'requires-recent-login' =>
      'Please sign in again before changing your password.',
    'too-many-requests' => 'Too many attempts. Try again in a moment.',
    _ => 'Authentication failed. Please try again.',
  };
}
