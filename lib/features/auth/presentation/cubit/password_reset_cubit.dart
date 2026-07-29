import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/send_password_reset.dart';

enum PasswordResetStatus { idle, sending, sent, failure }

class PasswordResetState extends Equatable {
  final PasswordResetStatus status;
  final String email;
  final String? message;

  const PasswordResetState({
    this.status = PasswordResetStatus.idle,
    this.email = '',
    this.message,
  });

  bool get busy => status == PasswordResetStatus.sending;

  PasswordResetState copyWith({
    PasswordResetStatus? status,
    String? email,
    String? message,
  }) => PasswordResetState(
    status: status ?? this.status,
    email: email ?? this.email,
    message: message,
  );

  @override
  List<Object?> get props => [status, email, message];
}

/// Drives the Forgot Password → Verify → Reset flow.
///
/// Kept separate from [AuthBloc] because resetting a password is not a session
/// transition: the user stays signed out throughout, and the bloc's status
/// must not move to authenticated as a side effect.
class PasswordResetCubit extends Cubit<PasswordResetState> {
  final SendPasswordReset sendPasswordReset;

  PasswordResetCubit({
    required this.sendPasswordReset,
    String initialEmail = '',
  }) : super(PasswordResetState(email: initialEmail));

  Future<void> requestReset(String email) async {
    emit(state.copyWith(status: PasswordResetStatus.sending, email: email));

    final result = await sendPasswordReset(SendPasswordResetParams(email));
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PasswordResetStatus.failure,
          message: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(status: PasswordResetStatus.sent)),
    );
  }

  /// Lets the user request a fresh link from the verification screen.
  Future<void> resend() => requestReset(state.email);
}
