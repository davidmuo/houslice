import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/features/auth/presentation/pages/reset_success_page.dart';
import 'package:houslice/features/booking/presentation/pages/add_card_page.dart';
import 'package:houslice/features/onboarding/presentation/pages/location_picker_page.dart';
import 'package:houslice/features/profile/presentation/pages/edit_profile_page.dart';

import '../helpers/app_harness.dart';

/// Widget tests for the screens added to close the gap against the Figma:
/// Edit Profile, Add New Card, the location picker, and reset success.
void main() {
  registerHarnessTeardown();

  group('EditProfilePage', () {
    testWidgets('renders the editable fields', (tester) async {
      await pumpPage(tester, const EditProfilePage(), signedIn: true);

      expect(find.text('Edit Profile'), findsWidgets);
      expect(find.text('Full name'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Date of birth'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('email is shown but not editable', (tester) async {
      await pumpPage(tester, const EditProfilePage(), signedIn: true);

      expect(find.textContaining('cannot be changed here'), findsOneWidget);
    });

    testWidgets('an empty name is rejected', (tester) async {
      await pumpPage(tester, const EditProfilePage(), signedIn: true);

      await tester.enterText(find.byType(TextFormField).first, '');
      await tester.tap(find.text('Save Change'));
      await tester.pumpAndSettle();

      expect(find.textContaining('is required'), findsWidgets);
    });

    testWidgets('fits a small phone', (tester) async {
      await pumpPage(
        tester,
        const EditProfilePage(),
        signedIn: true,
        surfaceSize: const Size(360, 640),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('AddCardPage', () {
    testWidgets('renders the preview and the form', (tester) async {
      await pumpPage(tester, const AddCardPage(), signedIn: true);

      expect(find.text('Add Card'), findsWidgets);
      expect(find.text('Name on card'), findsOneWidget);
      expect(find.text('Card number'), findsOneWidget);
      expect(find.text('CVV'), findsOneWidget);
      // The preview starts as bullets.
      expect(find.textContaining('••••'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('says plainly that nothing is stored', (tester) async {
      await pumpPage(tester, const AddCardPage(), signedIn: true);

      expect(find.textContaining('not saved or sent anywhere'), findsOneWidget);
    });

    testWidgets('groups the number into fours as it is typed', (tester) async {
      await pumpPage(tester, const AddCardPage(), signedIn: true);

      await tester.enterText(
        find.byType(TextFormField).at(1),
        '4242424242424242',
      );
      await tester.pump();

      expect(find.text('4242 4242 4242 4242'), findsWidgets);
    });

    testWidgets('rejects a number that fails the Luhn check', (tester) async {
      await pumpPage(tester, const AddCardPage(), signedIn: true);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'John Simmons');
      await tester.enterText(fields.at(1), '4242424242424241'); // bad checksum
      await tester.enterText(fields.at(2), '1230');
      await tester.enterText(fields.at(3), '123');
      await tester.tap(find.text('Add card'));
      await tester.pumpAndSettle();

      expect(find.textContaining('not valid'), findsWidgets);
    });

    testWidgets('rejects an expired card', (tester) async {
      await pumpPage(tester, const AddCardPage(), signedIn: true);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'John Simmons');
      await tester.enterText(fields.at(1), '4242424242424242');
      await tester.enterText(fields.at(2), '0120'); // Jan 2020
      await tester.enterText(fields.at(3), '123');
      await tester.tap(find.text('Add card'));
      await tester.pumpAndSettle();

      expect(find.textContaining('expired'), findsWidgets);
    });

    testWidgets('rejects a short CVV', (tester) async {
      await pumpPage(tester, const AddCardPage(), signedIn: true);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'John Simmons');
      await tester.enterText(fields.at(1), '4242424242424242');
      await tester.enterText(fields.at(2), '1230');
      await tester.enterText(fields.at(3), '1');
      await tester.tap(find.text('Add card'));
      await tester.pumpAndSettle();

      expect(find.textContaining('3 or 4 digits'), findsWidgets);
    });

    testWidgets('fits a small phone', (tester) async {
      await pumpPage(
        tester,
        const AddCardPage(),
        signedIn: true,
        surfaceSize: const Size(360, 640),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('LocationPickerPage', () {
    testWidgets('lists Kigali neighbourhoods across all three districts', (
      tester,
    ) async {
      await pumpPage(tester, const LocationPickerPage(), signedIn: true);

      expect(find.text('Kimihurura'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Nyarugenge sits below the fold in a 17-item list.
      await tester.dragUntilVisible(
        find.text('Nyamirambo'),
        find.byType(Scrollable).last,
        const Offset(0, -200),
      );
      expect(find.text('Nyamirambo'), findsOneWidget);
    });

    testWidgets('search narrows the list', (tester) async {
      await pumpPage(tester, const LocationPickerPage(), signedIn: true);

      await tester.enterText(find.byType(TextField).first, 'Kicukiro');
      await tester.pumpAndSettle();

      expect(find.text('Kimihurura'), findsNothing);
      expect(find.text('Kanombe'), findsOneWidget);
    });

    testWidgets('a query matching nothing shows the empty state', (
      tester,
    ) async {
      await pumpPage(tester, const LocationPickerPage(), signedIn: true);

      await tester.enterText(find.byType(TextField).first, 'zzzzz');
      await tester.pumpAndSettle();

      expect(find.text('No matching area'), findsOneWidget);
    });

    testWidgets('fits a small phone', (tester) async {
      await pumpPage(
        tester,
        const LocationPickerPage(),
        signedIn: true,
        surfaceSize: const Size(360, 640),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('ResetSuccessPage', () {
    testWidgets('confirms the password change', (tester) async {
      await pumpPage(tester, const ResetSuccessPage());

      expect(find.text('Success!'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fits a small phone', (tester) async {
      await pumpPage(
        tester,
        const ResetSuccessPage(),
        surfaceSize: const Size(360, 640),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
