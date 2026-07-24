import '../../domain/entities/app_user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.uid,
    required super.email,
    required super.username,
    super.photoUrl,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) => UserModel(
        uid: uid,
        email: (map['email'] ?? '') as String,
        username: (map['username'] ?? '') as String,
        photoUrl: map['photoUrl'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'email': email,
        'username': username,
        'photoUrl': photoUrl,
      };
}
