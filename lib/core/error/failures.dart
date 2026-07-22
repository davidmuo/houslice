import 'package:equatable/equatable.dart';

/// Domain-level failures returned by repositories instead of thrown
/// exceptions, so the presentation layer never depends on data-layer errors.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong. Try again.']);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(
      [super.message = 'No internet connection. Check your network.']);
}
