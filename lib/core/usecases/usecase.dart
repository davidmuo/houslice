import 'package:equatable/equatable.dart';

import '../error/result.dart';

/// Base contract for every use case in the domain layer.
abstract class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

/// Passed to use cases that need no input.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
