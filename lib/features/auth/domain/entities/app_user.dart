import 'package:equatable/equatable.dart';

/// A verified student account on the Houseslice platform.
class AppUser extends Equatable {
  final String uid;
  final String email;
  final String username;
  final String? photoUrl;

  /// ISO-8601 date only (yyyy-MM-dd). Optional — collected on Edit Profile,
  /// never required to use the app.
  final String? dateOfBirth;

  /// Mirrors Firebase Auth's `emailVerified`. Email/password accounts start
  /// unverified; Google accounts arrive already verified.
  final bool emailVerified;

  const AppUser({
    required this.uid,
    required this.email,
    required this.username,
    this.photoUrl,
    this.dateOfBirth,
    this.emailVerified = false,
  });

  AppUser copyWith({
    String? username,
    String? photoUrl,
    String? dateOfBirth,
    bool? emailVerified,
  }) => AppUser(
    uid: uid,
    email: email,
    username: username ?? this.username,
    photoUrl: photoUrl ?? this.photoUrl,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    emailVerified: emailVerified ?? this.emailVerified,
  );

  String get initials {
    final parts = username.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  List<Object?> get props => [
    uid,
    email,
    username,
    photoUrl,
    dateOfBirth,
    emailVerified,
  ];
}
