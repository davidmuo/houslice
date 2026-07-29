import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/lifestyle_profile.dart';
import '../../domain/repositories/lifestyle_repository.dart';
import '../datasources/lifestyle_local_data_source.dart';

class LifestyleRepositoryImpl implements LifestyleRepository {
  final LifestyleLocalDataSource dataSource;

  LifestyleRepositoryImpl(this.dataSource);

  Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Success(await run());
    } on CacheException catch (e) {
      return Err(CacheFailure(e.message));
    } catch (_) {
      return const Err(CacheFailure());
    }
  }

  @override
  Future<Result<LifestyleProfile?>> load() => _guard(() => dataSource.load());

  @override
  Future<Result<LifestyleProfile>> save(LifestyleProfile profile) =>
      _guard(() => dataSource.save(profile));

  @override
  Future<Result<void>> clear() => _guard(() => dataSource.clear());
}
