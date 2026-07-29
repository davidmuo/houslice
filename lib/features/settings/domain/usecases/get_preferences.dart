import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_preferences.dart';
import '../repositories/preferences_repository.dart';

/// Reads the preferences saved on the device. Called once at startup so the
/// correct theme is applied before the first frame.
class GetPreferences extends UseCase<AppPreferences, NoParams> {
  final PreferencesRepository repository;

  GetPreferences(this.repository);

  @override
  Future<Result<AppPreferences>> call(NoParams params) => repository.load();
}
