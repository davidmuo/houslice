import '../../domain/entities/app_preferences.dart';

/// Maps [AppPreferences] to and from the primitive values SharedPreferences
/// can store, and owns the storage keys.
///
/// Deliberately *not* a subclass of [AppPreferences]: Equatable folds
/// `runtimeType` into equality, so a subclass would never compare equal to the
/// entity it represents. That would make the preferences cubit emit a
/// duplicate state on every save and break value comparisons in tests.
abstract final class AppPreferencesModel {
  // Storage keys — prefixed to avoid collisions with plugin-owned keys.
  static const keyThemeMode = 'houslice.theme_mode';
  static const keyNotifications = 'houslice.notifications_enabled';
  static const keyPreferredCity = 'houslice.preferred_city';
  static const keyOnboardingComplete = 'houslice.onboarding_complete';

  /// Rebuilds preferences from raw stored values. Any missing or unrecognised
  /// value falls back to the matching default rather than throwing, so a
  /// partially-written store still yields a usable app.
  static AppPreferences fromStorage({
    String? themeMode,
    bool? notificationsEnabled,
    String? preferredCity,
    bool? onboardingComplete,
  }) {
    return AppPreferences(
      themeMode: decodeThemeMode(themeMode),
      notificationsEnabled:
          notificationsEnabled ?? AppPreferences.defaults.notificationsEnabled,
      preferredCity: AppPreferences.cities.contains(preferredCity)
          ? preferredCity!
          : AppPreferences.defaultCity,
      onboardingComplete:
          onboardingComplete ?? AppPreferences.defaults.onboardingComplete,
    );
  }

  /// Stored as the enum name so the value stays readable on disk and survives
  /// reordering of the enum.
  static String encodeThemeMode(AppThemeMode mode) => mode.name;

  static AppThemeMode decodeThemeMode(String? name) {
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => AppPreferences.defaults.themeMode,
    );
  }
}
