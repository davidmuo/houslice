import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/core/error/exceptions.dart';
import 'package:houslice/core/error/failures.dart';
import 'package:houslice/core/error/result.dart';
import 'package:houslice/features/settings/data/datasources/preferences_local_data_source.dart';
import 'package:houslice/features/settings/data/repositories/preferences_repository_impl.dart';
import 'package:houslice/features/settings/domain/entities/app_preferences.dart';
import 'package:mocktail/mocktail.dart';

class _MockLocalDataSource extends Mock implements PreferencesLocalDataSource {}

/// Unit tests proving the repository converts data-layer exceptions into
/// domain failures, so blocs never see a raw exception.
void main() {
  late _MockLocalDataSource dataSource;
  late PreferencesRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(AppPreferences.defaults);
  });

  setUp(() {
    dataSource = _MockLocalDataSource();
    repository = PreferencesRepositoryImpl(dataSource);
  });

  group('load', () {
    test('returns Success with the stored preferences', () async {
      const stored = AppPreferences(themeMode: AppThemeMode.dark);
      when(() => dataSource.load()).thenAnswer((_) async => stored);

      final result = await repository.load();

      expect(result, isA<Success<AppPreferences>>());
      expect((result as Success<AppPreferences>).value, stored);
      verify(() => dataSource.load()).called(1);
    });

    test('converts a CacheException into a CacheFailure', () async {
      when(
        () => dataSource.load(),
      ).thenThrow(const CacheException('Disk unreadable'));

      final result = await repository.load();

      expect(result, isA<Err<AppPreferences>>());
      expect(
        (result as Err<AppPreferences>).failure,
        const CacheFailure('Disk unreadable'),
      );
    });

    test('converts an unexpected error into a default CacheFailure', () async {
      when(() => dataSource.load()).thenThrow(StateError('boom'));

      final result = await repository.load();

      expect((result as Err<AppPreferences>).failure, isA<CacheFailure>());
    });
  });

  group('save', () {
    test('passes the preferences through and returns them', () async {
      const preferences = AppPreferences(preferredCity: 'Kicukiro');
      when(() => dataSource.save(any())).thenAnswer(
        (invocation) async =>
            invocation.positionalArguments.first as AppPreferences,
      );

      final result = await repository.save(preferences);

      expect(result, isA<Success<AppPreferences>>());
      expect((result as Success<AppPreferences>).value, preferences);
      verify(() => dataSource.save(any())).called(1);
    });

    test('surfaces a write failure as a CacheFailure', () async {
      when(() => dataSource.save(any())).thenThrow(const CacheException());

      final result = await repository.save(AppPreferences.defaults);

      expect(result, isA<Err<AppPreferences>>());
      expect((result as Err<AppPreferences>).failure, isA<CacheFailure>());
    });
  });
}
