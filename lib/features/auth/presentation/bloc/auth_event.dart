part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Fired from the splash screen to restore an existing session.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String username;
  final String password;

  const AuthSignUpRequested({
    required this.email,
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [email, username, password];
}

/// Houseslice's second sign-in method.
class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthProfileUpdateRequested extends AuthEvent {
  final String username;
  final String? photoUrl;
  final String? dateOfBirth;

  const AuthProfileUpdateRequested({
    required this.username,
    this.photoUrl,
    this.dateOfBirth,
  });

  @override
  List<Object?> get props => [username, photoUrl, dateOfBirth];
}

/// Re-sends the verification link from the profile banner.
class AuthEmailVerificationRequested extends AuthEvent {
  const AuthEmailVerificationRequested();
}

class AuthPasswordChangeRequested extends AuthEvent {
  final String newPassword;

  const AuthPasswordChangeRequested(this.newPassword);

  @override
  List<Object?> get props => [newPassword];
}
