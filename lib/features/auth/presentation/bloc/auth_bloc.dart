import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/change_password.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignIn signIn;
  final SignUp signUp;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;
  final ChangePassword changePassword;

  AuthBloc({
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.getCurrentUser,
    required this.changePassword,
  }) : super(const AuthState()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthPasswordChangeRequested>(_onPasswordChangeRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await getCurrentUser(const NoParams());
    result.fold(
      (failure) =>
          emit(state.copyWith(status: AuthStatus.unauthenticated)),
      (user) => emit(state.copyWith(
        status: user == null
            ? AuthStatus.unauthenticated
            : AuthStatus.authenticated,
        user: user,
        clearUser: user == null,
      )),
    );
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(busy: true));
    final result = await signIn(
      SignInParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        busy: false,
        status: AuthStatus.unauthenticated,
        error: failure.message,
      )),
      (user) => emit(state.copyWith(
        busy: false,
        status: AuthStatus.authenticated,
        user: user,
      )),
    );
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(busy: true));
    final result = await signUp(SignUpParams(
      email: event.email,
      username: event.username,
      password: event.password,
    ));
    result.fold(
      (failure) => emit(state.copyWith(
        busy: false,
        status: AuthStatus.unauthenticated,
        error: failure.message,
      )),
      (user) => emit(state.copyWith(
        busy: false,
        status: AuthStatus.authenticated,
        user: user,
      )),
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(busy: true));
    await signOut(const NoParams());
    emit(state.copyWith(
      busy: false,
      status: AuthStatus.unauthenticated,
      clearUser: true,
    ));
  }

  Future<void> _onPasswordChangeRequested(
    AuthPasswordChangeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(busy: true));
    final result = await changePassword(event.newPassword);
    result.fold(
      (failure) => emit(state.copyWith(busy: false, error: failure.message)),
      (_) => emit(state.copyWith(
        busy: false,
        notice: 'Password changed successfully',
      )),
    );
  }
}
