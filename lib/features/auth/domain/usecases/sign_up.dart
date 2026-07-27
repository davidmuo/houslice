import 'package:equatable/equatable.dart';

import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignUp extends UseCase<AppUser, SignUpParams> {
  final AuthRepository repository;

  SignUp(this.repository);

  @override
  Future<Result<AppUser>> call(SignUpParams params) => repository.signUp(
        email: params.email,
        username: params.username,
        password: params.password,
      );
}

class SignUpParams extends Equatable {
  final String email;
  final String username;
  final String password;

  const SignUpParams({
    required this.email,
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [email, username, password];
}
