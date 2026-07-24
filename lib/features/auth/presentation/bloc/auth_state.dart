part of 'auth_bloc.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final AppUser? user;

  /// True while a sign-in/up/out or password change is in flight.
  final bool busy;

  /// One-shot error message; cleared on the next emission.
  final String? error;

  /// One-shot success message (e.g. password changed).
  final String? notice;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.busy = false,
    this.error,
    this.notice,
  });

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    bool? busy,
    String? error,
    String? notice,
    bool clearUser = false,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: clearUser ? null : (user ?? this.user),
        busy: busy ?? this.busy,
        error: error,
        notice: notice,
      );

  @override
  List<Object?> get props => [status, user, busy, error, notice];
}
