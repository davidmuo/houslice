import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/features/settings/domain/entities/app_preferences.dart';

/// Unit tests for the preferences entity: defaults, immutability via
/// copyWith, and value equality.
void main() {
  group('AppPreferences defaults', () {
    test('a fresh install opens in the light theme with alerts on', () {
      const preferences = AppPreferences.defaults;

      // Light, not system: the Figma design is a light theme, so following the
      // device would render the app dark for anyone with a dark-mode phone.
      expect(preferences.themeMode, AppThemeMode.light);
      expect(preferences.notificationsEnabled, isTrue);
      expect(preferences.preferredCity, AppPreferences.defaultCity);
      expect(preferences.onboardingComplete, isFalse);
    });

    test('the default city is one of the selectable districts', () {
      expect(AppPreferences.cities, contains(AppPreferences.defaultCity));
    });
  });

  group('AppPreferences.copyWith', () {
    test('changes only the named field', () {
      const original = AppPreferences.defaults;
      final updated = original.copyWith(themeMode: AppThemeMode.dark);

      expect(updated.themeMode, AppThemeMode.dark);
      expect(updated.notificationsEnabled, original.notificationsEnabled);
      expect(updated.preferredCity, original.preferredCity);
      expect(updated.onboardingComplete, original.onboardingComplete);
    });

    test('leaves the original untouched', () {
      const original = AppPreferences.defaults;
      original.copyWith(preferredCity: 'Kicukiro');

      expect(original.preferredCity, AppPreferences.defaultCity);
    });

    test('can turn a boolean off', () {
      final updated = AppPreferences.defaults.copyWith(
        notificationsEnabled: false,
      );

      expect(updated.notificationsEnabled, isFalse);
    });
  });

  group('AppPreferences equality', () {
    test('two instances with the same values are equal', () {
      expect(
        const AppPreferences(themeMode: AppThemeMode.dark),
        const AppPreferences(themeMode: AppThemeMode.dark),
      );
    });

    test('differing values are not equal', () {
      expect(
        const AppPreferences(themeMode: AppThemeMode.dark),
        isNot(const AppPreferences(themeMode: AppThemeMode.light)),
      );
    });
  });
}
