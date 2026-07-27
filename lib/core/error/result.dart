import 'failures.dart';

/// Lightweight functional result type used across the domain layer, so
/// use cases return either a [Success] value or a domain [Failure]
/// without throwing.
sealed class Result<T> {
  const Result();

  R fold<R>(R Function(Failure failure) onFailure,
      R Function(T value) onSuccess) {
    final self = this;
    return switch (self) {
      Success<T>(:final value) => onSuccess(value),
      Err<T>(:final failure) => onFailure(failure),
    };
  }
}

class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);
}

class Err<T> extends Result<T> {
  final Failure failure;

  const Err(this.failure);
}
