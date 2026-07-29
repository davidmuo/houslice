import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/app_preferences.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../datasources/preferences_local_data_source.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  final PreferencesLocalDataSource dataSource;

  PreferencesRepositoryImpl(this.dataSource);

  /// Converts data-layer exceptions into domain failures, mirroring the
  /// pattern used by the auth and property repositories.
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
  Future<Result<AppPreferences>> load() => _guard(() => dataSource.load());

  @override
  Future<Result<AppPreferences>> save(AppPreferences preferences) =>
      _guard(() => dataSource.save(preferences));
}
