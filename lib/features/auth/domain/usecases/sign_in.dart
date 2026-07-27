import 'package:equatable/equatable.dart';

import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignIn extends UseCase<AppUser, SignInParams> {
  final AuthRepository repository;

  SignIn(this.repository);

  @override
  Future<Result<AppUser>> call(SignInParams params) =>
      repository.signIn(email: params.email, password: params.password);
}

class SignInParams extends Equatable {
  final String email;
  final String password;

  const SignInParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
