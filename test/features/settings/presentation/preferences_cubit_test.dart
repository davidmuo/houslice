import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/core/error/failures.dart';
import 'package:houslice/core/error/result.dart';
import 'package:houslice/core/usecases/usecase.dart';
import 'package:houslice/features/settings/domain/entities/app_preferences.dart';
import 'package:houslice/features/settings/domain/usecases/get_preferences.dart';
import 'package:houslice/features/settings/domain/usecases/save_preferences.dart';
import 'package:houslice/features/settings/presentation/cubit/preferences_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetPreferences extends Mock implements GetPreferences {}

class _MockSavePreferences extends Mock implements SavePreferences {}

/// Bloc-level tests for the preferences cubit, covering the optimistic write
/// and the rollback that follows a failed save.
void main() {
  late _MockGetPreferences getPreferences;
  late _MockSavePreferences savePreferences;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const SavePreferencesParams(AppPreferences.defaults));
  });

  setUp(() {
    getPreferences = _MockGetPreferences();
    savePreferences = _MockSavePreferences();
  });

  PreferencesCubit build() => PreferencesCubit(
    getPreferences: getPreferences,
    savePreferences: savePreferences,
  );

  /// Makes any save succeed by echoing back what it was given.
  void stubSaveSucceeds() {
    when(() => savePreferences(any())).thenAnswer(
      (invocation) async => Success(
        (invocation.positionalArguments.first as SavePreferencesParams)
            .preferences,
      ),
    );
  }

  test('starts from the defaults before anything is loaded', () {
    expect(build().state.preferences, AppPreferences.defaults);
  });

  blocTest<PreferencesCubit, PreferencesState>(
    'load() emits the preferences read from storage',
    setUp: () {
      when(() => getPreferences(any())).thenAnswer(
        (_) async => const Success(
          AppPreferences(
            themeMode: AppThemeMode.dark,
            preferredCity: 'Kicukiro',
          ),
        ),
      );
    },
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => const [
      PreferencesState(
        preferences: AppPreferences(
          themeMode: AppThemeMode.dark,
          preferredCity: 'Kicukiro',
        ),
      ),
    ],
  );

  blocTest<PreferencesCubit, PreferencesState>(
    'load() surfaces a read failure as an error message',
    setUp: () {
      when(
        () => getPreferences(any()),
      ).thenAnswer((_) async => const Err(CacheFailure('Disk unreadable')));
    },
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => const [PreferencesState(errorMessage: 'Disk unreadable')],
  );

  blocTest<PreferencesCubit, PreferencesState>(
    'setThemeMode() persists the new theme',
    setUp: stubSaveSucceeds,
    build: build,
    act: (cubit) => cubit.setThemeMode(AppThemeMode.dark),
    // The optimistic emit and the confirmed emit carry the same value, so
    // the cubit deduplicates them into a single state change.
    expect: () => const [
      PreferencesState(
        preferences: AppPreferences(themeMode: AppThemeMode.dark),
      ),
    ],
    verify: (_) => verify(() => savePreferences(any())).called(1),
  );

  blocTest<PreferencesCubit, PreferencesState>(
    'a failed write rolls back to the previous value and reports the error',
    setUp: () {
      when(
        () => savePreferences(any()),
      ).thenAnswer((_) async => const Err(CacheFailure()));
    },
    build: build,
    act: (cubit) => cubit.setNotificationsEnabled(false),
    expect: () => const [
      // Optimistic: the switch flips immediately...
      PreferencesState(
        preferences: AppPreferences(notificationsEnabled: false),
      ),
      // ...then reverts once the write fails.
      PreferencesState(
        preferences: AppPreferences.defaults,
        errorMessage: 'Could not save your settings.',
      ),
    ],
  );

  blocTest<PreferencesCubit, PreferencesState>(
    'completeOnboarding() and replayOnboarding() toggle the intro flag',
    setUp: stubSaveSucceeds,
    build: build,
    act: (cubit) async {
      await cubit.completeOnboarding();
      await cubit.replayOnboarding();
    },
    expect: () => const [
      PreferencesState(preferences: AppPreferences(onboardingComplete: true)),
      PreferencesState(preferences: AppPreferences.defaults),
    ],
  );

  blocTest<PreferencesCubit, PreferencesState>(
    'setPreferredCity() stores the chosen district',
    setUp: stubSaveSucceeds,
    build: build,
    act: (cubit) => cubit.setPreferredCity('Nyarugenge'),
    expect: () => const [
      PreferencesState(
        preferences: AppPreferences(preferredCity: 'Nyarugenge'),
      ),
    ],
  );
}
