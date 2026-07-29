import 'package:equatable/equatable.dart';

import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Emails a password-reset link. Used by the "Forgot Password" flow.
class SendPasswordReset extends UseCase<void, SendPasswordResetParams> {
  final AuthRepository repository;

  SendPasswordReset(this.repository);

  @override
  Future<Result<void>> call(SendPasswordResetParams params) =>
      repository.sendPasswordReset(params.email);
}

class SendPasswordResetParams extends Equatable {
  final String email;

  const SendPasswordResetParams(this.email);

  @override
  List<Object?> get props => [email];
}
