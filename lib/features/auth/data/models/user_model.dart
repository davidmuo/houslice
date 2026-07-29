import '../../domain/entities/app_user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.uid,
    required super.email,
    required super.username,
    super.photoUrl,
    super.dateOfBirth,
    super.emailVerified,
  });

  factory UserModel.fromEntity(AppUser user) => UserModel(
    uid: user.uid,
    email: user.email,
    username: user.username,
    photoUrl: user.photoUrl,
    dateOfBirth: user.dateOfBirth,
    emailVerified: user.emailVerified,
  );

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) => UserModel(
    uid: uid,
    email: (map['email'] ?? '') as String,
    username: (map['username'] ?? '') as String,
    photoUrl: map['photoUrl'] as String?,
    dateOfBirth: map['dateOfBirth'] as String?,
  );

  /// `emailVerified` is deliberately not persisted here: Firebase Auth owns
  /// it, and a copy in Firestore would be a client-writable claim about
  /// verification status.
  Map<String, dynamic> toMap() => {
    'email': email,
    'username': username,
    'photoUrl': photoUrl,
    if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
  };
}
