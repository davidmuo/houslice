import '../../../../core/error/result.dart';
import '../entities/app_preferences.dart';

/// Contract for reading and writing on-device user preferences.
abstract class PreferencesRepository {
  /// Returns the stored preferences, or [AppPreferences.defaults] on a first
  /// launch when nothing has been written yet.
  Future<Result<AppPreferences>> load();

  /// Persists [preferences] and echoes back what was saved.
  Future<Result<AppPreferences>> save(AppPreferences preferences);
}
