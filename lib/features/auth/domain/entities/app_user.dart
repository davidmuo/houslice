import 'package:equatable/equatable.dart';

/// A verified student account on the Houseslice platform.
class AppUser extends Equatable {
  final String uid;
  final String email;
  final String username;
  final String? photoUrl;

  const AppUser({
    required this.uid,
    required this.email,
    required this.username,
    this.photoUrl,
  });

  String get initials {
    final parts = username.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  List<Object?> get props => [uid, email, username, photoUrl];
}
