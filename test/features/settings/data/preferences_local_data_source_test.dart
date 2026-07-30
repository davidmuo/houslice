import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/features/settings/data/datasources/preferences_local_data_source.dart';
import 'package:houslice/features/settings/data/models/app_preferences_model.dart';
import 'package:houslice/features/settings/domain/entities/app_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Round-trip tests against a real SharedPreferences store (backed by the
/// in-memory mock), proving preferences survive a simulated app relaunch.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPrefsPreferencesDataSource> newDataSource() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPrefsPreferencesDataSource(prefs);
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('an untouched install loads the defaults', () async {
    final dataSource = await newDataSource();

    expect(await dataSource.load(), AppPreferences.defaults);
  });

  test('saved preferences are restored on the next launch', () async {
    const chosen = AppPreferences(
      themeMode: AppThemeMode.dark,
      notificationsEnabled: false,
      preferredCity: 'Nyarugenge',
      onboardingComplete: true,
    );

    await (await newDataSource()).save(chosen);

    // A brand-new data source over the same store stands in for a relaunch.
    final restored = await (await newDataSource()).load();

    expect(restored, chosen);
    expect(restored.themeMode, AppThemeMode.dark);
    expect(restored.preferredCity, 'Nyarugenge');
  });

  test('each preference is written under its own namespaced key', () async {
    await (await newDataSource()).save(
      const AppPreferences(themeMode: AppThemeMode.light),
    );

    final prefs = await SharedPreferences.getInstance();

    expect(prefs.getString(AppPreferencesModel.keyThemeMode), 'light');
    expect(prefs.getBool(AppPreferencesModel.keyNotifications), isTrue);
    expect(
      prefs.getString(AppPreferencesModel.keyPreferredCity),
      AppPreferences.defaultCity,
    );
    expect(prefs.getBool(AppPreferencesModel.keyOnboardingComplete), isFalse);
  });

  test('a later save overwrites the earlier one', () async {
    final dataSource = await newDataSource();

    await dataSource.save(const AppPreferences(themeMode: AppThemeMode.dark));
    await dataSource.save(const AppPreferences(themeMode: AppThemeMode.light));

    expect((await dataSource.load()).themeMode, AppThemeMode.light);
  });
}
