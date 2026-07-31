import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/features/settings/data/models/app_preferences_model.dart';
import 'package:houslice/features/settings/domain/entities/app_preferences.dart';

/// Unit tests for preference serialisation, including the fallback behaviour
/// that keeps a partially-written store usable.
void main() {
  group('theme mode encoding', () {
    test('round-trips every enum value', () {
      for (final mode in AppThemeMode.values) {
        final encoded = AppPreferencesModel.encodeThemeMode(mode);
        expect(AppPreferencesModel.decodeThemeMode(encoded), mode);
      }
    });

    test('encodes as the readable enum name', () {
      expect(AppPreferencesModel.encodeThemeMode(AppThemeMode.dark), 'dark');
    });

    test('falls back to the default for null or unknown values', () {
      expect(
        AppPreferencesModel.decodeThemeMode(null),
        AppPreferences.defaults.themeMode,
      );
      expect(
        AppPreferencesModel.decodeThemeMode('chartreuse'),
        AppPreferences.defaults.themeMode,
      );
    });
  });

  group('AppPreferencesModel.fromStorage', () {
    test('reads a fully-populated store', () {
      final model = AppPreferencesModel.fromStorage(
        themeMode: 'light',
        notificationsEnabled: false,
        preferredCity: 'Kicukiro',
        onboardingComplete: true,
      );

      expect(model.themeMode, AppThemeMode.light);
      expect(model.notificationsEnabled, isFalse);
      expect(model.preferredCity, 'Kicukiro');
      expect(model.onboardingComplete, isTrue);
    });

    test('an empty store yields the defaults', () {
      final model = AppPreferencesModel.fromStorage();

      expect(model, AppPreferences.defaults);
    });

    test('rejects a city that is not selectable', () {
      final model = AppPreferencesModel.fromStorage(preferredCity: 'Atlantis');

      expect(model.preferredCity, AppPreferences.defaultCity);
    });

    test('a partially-written store keeps the values it does have', () {
      final model = AppPreferencesModel.fromStorage(themeMode: 'dark');

      expect(model.themeMode, AppThemeMode.dark);
      expect(
        model.notificationsEnabled,
        AppPreferences.defaults.notificationsEnabled,
      );
    });

    test('decoded preferences compare equal to a plain entity', () {
      // Guards the serializer against being turned back into a subclass of
      // AppPreferences: Equatable includes runtimeType, so that would silently
      // break equality everywhere.
      final model = AppPreferencesModel.fromStorage(
        themeMode: 'dark',
        notificationsEnabled: false,
        preferredCity: 'Nyarugenge',
        onboardingComplete: true,
      );

      expect(
        model,
        const AppPreferences(
          themeMode: AppThemeMode.dark,
          notificationsEnabled: false,
          preferredCity: 'Nyarugenge',
          onboardingComplete: true,
        ),
      );
    });
  });
}
