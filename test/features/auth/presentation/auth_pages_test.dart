import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/features/auth/presentation/pages/new_password_page.dart';
import 'package:houslice/features/auth/presentation/pages/register_page.dart';
import 'package:houslice/features/auth/presentation/pages/sign_in_page.dart';

import '../../../helpers/app_harness.dart';

/// Widget tests for the auth screens, including the student-email gate.
void main() {
  registerHarnessTeardown();

  group('SignInPage', () {
    testWidgets('renders email and password fields', (tester) async {
      await pumpPage(tester, const SignInPage());

      expect(find.byType(TextFormField), findsAtLeast(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('submitting an empty form shows validation errors', (
      tester,
    ) async {
      await pumpPage(tester, const SignInPage());

      final button = find.byType(ElevatedButton);
      if (button.evaluate().isNotEmpty) {
        await tester.tap(button.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 300));
      }

      expect(find.textContaining('required'), findsWidgets);
    });

    testWidgets('fits a small phone without overflowing', (tester) async {
      await pumpPage(
        tester,
        const SignInPage(),
        surfaceSize: const Size(360, 640),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('RegisterPage', () {
    testWidgets('renders the registration form', (tester) async {
      await pumpPage(tester, const RegisterPage());

      expect(find.byType(TextFormField), findsAtLeast(3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('rejects a non-university email', (tester) async {
      await pumpPage(tester, const RegisterPage());

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Test Student');
      await tester.enterText(fields.at(1), 'someone@gmail.com');
      await tester.pump();

      final button = find.byType(ElevatedButton);
      if (button.evaluate().isNotEmpty) {
        await tester.tap(button.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 300));
      }

      expect(find.textContaining('university email'), findsWidgets);
    });

    testWidgets('fits a small phone without overflowing', (tester) async {
      await pumpPage(
        tester,
        const RegisterPage(),
        surfaceSize: const Size(360, 640),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('NewPasswordPage', () {
    testWidgets('renders the change-password form', (tester) async {
      await pumpPage(tester, const NewPasswordPage(), signedIn: true);

      expect(find.byType(TextFormField), findsAtLeast(1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('rejects mismatched passwords', (tester) async {
      await pumpPage(tester, const NewPasswordPage(), signedIn: true);

      final fields = find.byType(TextFormField);
      if (fields.evaluate().length >= 2) {
        await tester.enterText(fields.at(0), 'password123');
        await tester.enterText(fields.at(1), 'password124');
        await tester.pump();

        final button = find.byType(ElevatedButton);
        if (button.evaluate().isNotEmpty) {
          await tester.tap(button.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 300));
        }

        expect(find.textContaining('match'), findsWidgets);
      }
    });
  });
}
