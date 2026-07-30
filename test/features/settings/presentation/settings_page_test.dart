import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/core/error/result.dart';
import 'package:houslice/core/usecases/usecase.dart';
import 'package:houslice/features/settings/domain/entities/app_preferences.dart';
import 'package:houslice/features/settings/domain/usecases/get_preferences.dart';
import 'package:houslice/features/settings/domain/usecases/save_preferences.dart';
import 'package:houslice/features/settings/presentation/cubit/preferences_cubit.dart';
import 'package:houslice/features/settings/presentation/pages/settings_page.dart';
import 'package:houslice/features/lifestyle/domain/usecases/get_lifestyle_profile.dart';
import 'package:houslice/features/lifestyle/domain/usecases/save_lifestyle_profile.dart';
import 'package:houslice/features/lifestyle/presentation/cubit/lifestyle_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetPreferences extends Mock implements GetPreferences {}

class _MockSavePreferences extends Mock implements SavePreferences {}

/// Widget tests for the settings screen: every control renders, and changing
/// one writes through the cubit.

class _MockGetLifestyleProfile extends Mock implements GetLifestyleProfile {}

class _MockSaveLifestyleProfile extends Mock implements SaveLifestyleProfile {}

void main() {
  late _MockGetPreferences getPreferences;
  late _MockSavePreferences savePreferences;
  late PreferencesCubit cubit;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const SavePreferencesParams(AppPreferences.defaults));
  });

  setUp(() {
    getPreferences = _MockGetPreferences();
    savePreferences = _MockSavePreferences();
    when(() => savePreferences(any())).thenAnswer(
      (invocation) async => Success(
        (invocation.positionalArguments.first as SavePreferencesParams)
            .preferences,
      ),
    );
    cubit = PreferencesCubit(
      getPreferences: getPreferences,
      savePreferences: savePreferences,
    );
  });

  tearDown(() => cubit.close());

  Future<void> pumpPage(WidgetTester tester) async {
    // Settings also links to the lifestyle questionnaire, so the page needs
    // both cubits in scope.
    final lifestyle = LifestyleCubit(
      getLifestyleProfile: _MockGetLifestyleProfile(),
      saveLifestyleProfile: _MockSaveLifestyleProfile(),
    );
    addTearDown(lifestyle.close);

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<PreferencesCubit>.value(value: cubit),
            BlocProvider<LifestyleCubit>.value(value: lifestyle),
          ],
          child: const SettingsPage(),
        ),
      ),
    );
  }

  testWidgets('renders all four preference controls', (tester) async {
    await pumpPage(tester);

    expect(find.text('Settings'), findsOneWidget);
    // Theme selector.
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    // Notifications.
    expect(find.text('Booking and message alerts'), findsOneWidget);
    // Lifestyle questionnaire entry.
    expect(find.text('Your lifestyle answers'), findsOneWidget);
    // Preferred district — one chip per selectable city.
    for (final city in AppPreferences.cities) {
      expect(find.text(city), findsOneWidget);
    }

    // Onboarding replay sits below the fold now the list has grown.
    await tester.dragUntilVisible(
      find.text('Replay the intro slides'),
      find.byType(Scrollable).first,
      const Offset(0, -200),
    );
    expect(find.text('Replay the intro slides'), findsOneWidget);
  });

  testWidgets('choosing Dark writes the theme through the cubit', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(cubit.state.preferences.themeMode, AppThemeMode.dark);
    verify(() => savePreferences(any())).called(1);
  });

  testWidgets('toggling the notifications switch persists the new value', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(cubit.state.preferences.notificationsEnabled, isTrue);

    await tester.tap(find.byType(SwitchListTile).first);
    await tester.pumpAndSettle();

    expect(cubit.state.preferences.notificationsEnabled, isFalse);
  });

  testWidgets('picking a district updates the preference', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Kicukiro'));
    await tester.pumpAndSettle();

    expect(cubit.state.preferences.preferredCity, 'Kicukiro');
  });

  testWidgets('the settings screen fits a small phone without overflowing', (
    tester,
  ) async {
    // 5.0" class device — the rubric asks for no overflow on <= 5.5" screens.
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await pumpPage(tester);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
