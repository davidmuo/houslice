/// Data-layer exceptions thrown by data sources and converted to
/// [Failure]s inside repository implementations.
class ServerException implements Exception {
  final String message;

  const ServerException([this.message = 'Something went wrong. Try again.']);

  @override
  String toString() => message;
}

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}
