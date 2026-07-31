import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/core/error/failures.dart';
import 'package:houslice/core/error/result.dart';
import 'package:houslice/core/usecases/usecase.dart';
import 'package:houslice/core/utils/validators.dart';
import 'package:houslice/features/auth/data/datasources/mock_auth_data_source.dart';
import 'package:houslice/features/auth/domain/entities/app_user.dart';
import 'package:houslice/features/auth/domain/usecases/change_password.dart';
import 'package:houslice/features/auth/domain/usecases/get_current_user.dart';
import 'package:houslice/features/auth/domain/usecases/send_email_verification.dart';
import 'package:houslice/features/auth/domain/usecases/sign_in.dart';
import 'package:houslice/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:houslice/features/auth/domain/usecases/sign_out.dart';
import 'package:houslice/features/auth/domain/usecases/sign_up.dart';
import 'package:houslice/features/auth/domain/usecases/update_profile.dart';
import 'package:houslice/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockSignIn extends Mock implements SignIn {}

class _MockSignUp extends Mock implements SignUp {}

class _MockSignInWithGoogle extends Mock implements SignInWithGoogle {}

class _MockSignOut extends Mock implements SignOut {}

class _MockGetCurrentUser extends Mock implements GetCurrentUser {}

class _MockChangePassword extends Mock implements ChangePassword {}

class _MockUpdateProfile extends Mock implements UpdateProfile {}

class _MockSendEmailVerification extends Mock
    implements SendEmailVerification {}

/// Tests for Houseslice's second authentication method.
void main() {
  late _MockSignInWithGoogle signInWithGoogle;

  const googleUser = AppUser(
    uid: 'g1',
    email: 'g.demo@alustudent.com',
    username: 'Google Demo Student',
  );

  setUpAll(() => registerFallbackValue(const NoParams()));

  setUp(() => signInWithGoogle = _MockSignInWithGoogle());

  AuthBloc build() => AuthBloc(
    signIn: _MockSignIn(),
    signUp: _MockSignUp(),
    signInWithGoogle: signInWithGoogle,
    signOut: _MockSignOut(),
    getCurrentUser: _MockGetCurrentUser(),
    changePassword: _MockChangePassword(),
    updateProfile: _MockUpdateProfile(),
    sendEmailVerification: _MockSendEmailVerification(),
  );

  group('AuthGoogleSignInRequested', () {
    blocTest<AuthBloc, AuthState>(
      'authenticates the student on success',
      setUp: () {
        when(
          () => signInWithGoogle(any()),
        ).thenAnswer((_) async => const Success(googleUser));
      },
      build: build,
      act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
      expect: () => [
        const AuthState(busy: true),
        const AuthState(status: AuthStatus.authenticated, user: googleUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'surfaces a rejected non-university account',
      setUp: () {
        when(() => signInWithGoogle(any())).thenAnswer(
          (_) async =>
              const Err(AuthFailure('Use your university Google account.')),
        );
      },
      build: build,
      act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
      expect: () => [
        const AuthState(busy: true),
        const AuthState(
          status: AuthStatus.unauthenticated,
          error: 'Use your university Google account.',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'a cancelled sign-in leaves the student signed out, not stuck busy',
      setUp: () {
        when(() => signInWithGoogle(any())).thenAnswer(
          (_) async => const Err(AuthFailure('Google sign-in was cancelled.')),
        );
      },
      build: build,
      act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
      verify: (bloc) {
        expect(bloc.state.busy, isFalse);
        expect(bloc.state.status, AuthStatus.unauthenticated);
      },
    );
  });

  group('MockAuthDataSource.signInWithGoogle', () {
    test('returns a university account and becomes the current user', () async {
      final source = MockAuthDataSource();

      final user = await source.signInWithGoogle();

      expect(user.email, 'g.demo@alustudent.com');
      expect(await source.currentUser(), user);
    });

    test('the demo Google account passes the student-email gate', () async {
      final user = await MockAuthDataSource().signInWithGoogle();

      // The production data source enforces this same rule before creating a
      // Firebase session, so the demo account must satisfy it too.
      expect(Validators.studentEmail(user.email), isNull);
    });

    test('signing out clears the session', () async {
      final source = MockAuthDataSource();
      await source.signInWithGoogle();

      await source.signOut();

      expect(await source.currentUser(), isNull);
    });
  });
}
