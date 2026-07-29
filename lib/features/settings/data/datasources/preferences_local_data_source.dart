import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/app_preferences.dart';
import '../models/app_preferences_model.dart';

/// Contract for on-device preference storage, so the repository can be tested
/// against a fake without touching platform channels.
abstract class PreferencesLocalDataSource {
  Future<AppPreferences> load();

  Future<AppPreferences> save(AppPreferences preferences);
}

/// SharedPreferences-backed implementation. Each preference is written to its
/// own key, which keeps the stored data inspectable and lets new preferences
/// be added later without migrating a serialised blob.
class SharedPrefsPreferencesDataSource implements PreferencesLocalDataSource {
  final SharedPreferences prefs;

  SharedPrefsPreferencesDataSource(this.prefs);

  @override
  Future<AppPreferences> load() async {
    try {
      return AppPreferencesModel.fromStorage(
        themeMode: prefs.getString(AppPreferencesModel.keyThemeMode),
        notificationsEnabled: prefs.getBool(
          AppPreferencesModel.keyNotifications,
        ),
        preferredCity: prefs.getString(AppPreferencesModel.keyPreferredCity),
        onboardingComplete: prefs.getBool(
          AppPreferencesModel.keyOnboardingComplete,
        ),
      );
    } catch (_) {
      throw const CacheException('Could not read your saved settings.');
    }
  }

  @override
  Future<AppPreferences> save(AppPreferences preferences) async {
    try {
      await prefs.setString(
        AppPreferencesModel.keyThemeMode,
        AppPreferencesModel.encodeThemeMode(preferences.themeMode),
      );
      await prefs.setBool(
        AppPreferencesModel.keyNotifications,
        preferences.notificationsEnabled,
      );
      await prefs.setString(
        AppPreferencesModel.keyPreferredCity,
        preferences.preferredCity,
      );
      await prefs.setBool(
        AppPreferencesModel.keyOnboardingComplete,
        preferences.onboardingComplete,
      );
      return preferences;
    } catch (_) {
      throw const CacheException();
    }
  }
}
