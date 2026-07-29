import 'package:equatable/equatable.dart';

import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_preferences.dart';
import '../repositories/preferences_repository.dart';

/// Writes the full preference set back to device storage.
class SavePreferences extends UseCase<AppPreferences, SavePreferencesParams> {
  final PreferencesRepository repository;

  SavePreferences(this.repository);

  @override
  Future<Result<AppPreferences>> call(SavePreferencesParams params) =>
      repository.save(params.preferences);
}

class SavePreferencesParams extends Equatable {
  final AppPreferences preferences;

  const SavePreferencesParams(this.preferences);

  @override
  List<Object?> get props => [preferences];
}
