import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/app_preferences.dart';
import '../../domain/usecases/get_preferences.dart';
import '../../domain/usecases/save_preferences.dart';

class PreferencesState extends Equatable {
  final AppPreferences preferences;

  /// Set when a write fails so the UI can surface a snackbar; cleared on the
  /// next successful update.
  final String? errorMessage;

  const PreferencesState({
    this.preferences = AppPreferences.defaults,
    this.errorMessage,
  });

  PreferencesState copyWith({
    AppPreferences? preferences,
    String? errorMessage,
  }) {
    return PreferencesState(
      preferences: preferences ?? this.preferences,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [preferences, errorMessage];
}

/// Owns the user's saved preferences for the lifetime of the app.
///
/// Updates are optimistic: the new value is emitted immediately so the UI
/// (and the app's theme) reacts without waiting on disk, then the write is
/// confirmed. If the write fails the previous value is restored.
class PreferencesCubit extends Cubit<PreferencesState> {
  final GetPreferences getPreferences;
  final SavePreferences savePreferences;

  PreferencesCubit({
    required this.getPreferences,
    required this.savePreferences,
  }) : super(const PreferencesState());

  /// Reads persisted values. Called at startup before the first frame.
  Future<void> load() async {
    final result = await getPreferences(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (preferences) => emit(PreferencesState(preferences: preferences)),
    );
  }

  Future<void> setThemeMode(AppThemeMode mode) =>
      _persist(state.preferences.copyWith(themeMode: mode));

  Future<void> setNotificationsEnabled(bool enabled) =>
      _persist(state.preferences.copyWith(notificationsEnabled: enabled));

  Future<void> setPreferredCity(String city) =>
      _persist(state.preferences.copyWith(preferredCity: city));

  /// Marks onboarding as seen so returning users skip the intro slides.
  Future<void> completeOnboarding() =>
      _persist(state.preferences.copyWith(onboardingComplete: true));

  /// Re-enables the intro slides on the next launch.
  Future<void> replayOnboarding() =>
      _persist(state.preferences.copyWith(onboardingComplete: false));

  Future<void> _persist(AppPreferences next) async {
    final previous = state.preferences;
    emit(PreferencesState(preferences: next));

    final result = await savePreferences(SavePreferencesParams(next));
    result.fold(
      (failure) => emit(
        PreferencesState(preferences: previous, errorMessage: failure.message),
      ),
      (saved) => emit(PreferencesState(preferences: saved)),
    );
  }
}
