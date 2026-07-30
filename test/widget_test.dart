import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/app.dart';
import 'package:houslice/features/settings/data/models/app_preferences_model.dart';
import 'package:houslice/features/settings/presentation/cubit/preferences_cubit.dart';
import 'package:houslice/injection_container.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';

/// End-to-end widget tests over the real dependency graph in demo mode.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Boots the container the same way `main()` does, seeding device storage
  /// with [storedPreferences] to stand in for a previous session.
  Future<void> bootApp(
    WidgetTester tester, {
    Map<String, Object> storedPreferences = const {},
  }) async {
    SharedPreferences.setMockInitialValues(storedPreferences);
    await di.sl.reset();
    await di.init(useFirebase: false);
    await di.sl<PreferencesCubit>().load();
    await tester.pumpWidget(const HousliceApp());
  }

  tearDown(() => di.sl.reset());

  testWidgets('boots to the splash screen', (tester) async {
    await bootApp(tester);

    expect(find.text('HOUSLICE'), findsOneWidget);

    // Drain the splash delay so the test does not end with a pending timer.
    await tester.pump(const Duration(milliseconds: 1700));
    await tester.pumpAndSettle();
  });

  testWidgets('a first-time user lands on onboarding', (tester) async {
    await bootApp(tester);

    // Let the splash timer fire and the session check resolve; with no
    // signed-in user the app should land on onboarding.
    await tester.pump(const Duration(milliseconds: 1700));
    await tester.pumpAndSettle();

    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('a returning user who already saw the intro skips to sign-in', (
    tester,
  ) async {
    await bootApp(
      tester,
      storedPreferences: {AppPreferencesModel.keyOnboardingComplete: true},
    );

    await tester.pump(const Duration(milliseconds: 1700));
    await tester.pumpAndSettle();

    // Onboarding is skipped because the saved preference was restored.
    expect(find.text('Next'), findsNothing);
  });
}
