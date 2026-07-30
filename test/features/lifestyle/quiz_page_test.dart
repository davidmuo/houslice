import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:houslice/features/lifestyle/presentation/pages/quiz_page.dart';
import 'package:houslice/features/lifestyle/presentation/quiz_questions.dart';
import 'package:houslice/features/property/presentation/pages/create_listing_page.dart';

import '../../helpers/app_harness.dart';

/// Widget tests for the questionnaire, the listing composer, and the
/// password-reset entry screen.
void main() {
  registerHarnessTeardown();

  group('QuizPage', () {
    testWidgets('opens on the first question with its options', (tester) async {
      await pumpPage(tester, const QuizPage(), signedIn: true);

      final first = kQuizQuestions.first;
      expect(find.text(first.prompt), findsOneWidget);
      for (final option in first.options) {
        expect(find.text(option), findsOneWidget);
      }
      expect(find.text('1/${kQuizQuestions.length + 1}'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('selecting an option and advancing shows the next question', (
      tester,
    ) async {
      await pumpPage(tester, const QuizPage(), signedIn: true);

      await tester.tap(find.text(kQuizQuestions.first.options.first));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text(kQuizQuestions[1].prompt), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Skip jumps to the free-text step', (tester) async {
      await pumpPage(tester, const QuizPage(), signedIn: true);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text(kQuizBioPrompt), findsOneWidget);
      expect(find.text('Finish'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fits a small phone', (tester) async {
      await pumpPage(
        tester,
        const QuizPage(),
        signedIn: true,
        surfaceSize: const Size(360, 640),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('CreateListingPage', () {
    testWidgets('renders the host and listing-kind choices', (tester) async {
      await pumpPage(tester, const CreateListingPage(), signedIn: true);

      expect(find.text('List your place'), findsWidgets);
      expect(find.text('Student'), findsWidgets);
      expect(find.text('Realtor'), findsWidgets);
      expect(find.text('Room in a shared home'), findsWidgets);
      expect(find.text('Entire place'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('choosing Realtor forces the listing to an entire place', (
      tester,
    ) async {
      await pumpPage(tester, const CreateListingPage(), signedIn: true);

      await tester.tap(find.text('Realtor'));
      await tester.pumpAndSettle();

      // The housemate option is disabled for agents, so the lifestyle callout
      // must not be offered.
      expect(
        find.textContaining('lifestyle answers will be attached'),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('publishing an empty form surfaces validation errors', (
      tester,
    ) async {
      await pumpPage(tester, const CreateListingPage(), signedIn: true);

      await tester.dragUntilVisible(
        find.text('Publish listing'),
        find.byType(Scrollable).first,
        const Offset(0, -250),
      );
      await tester.tap(find.text('Publish listing'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.textContaining('is required'), findsWidgets);
    });

    testWidgets('fits a small phone', (tester) async {
      await pumpPage(
        tester,
        const CreateListingPage(),
        signedIn: true,
        surfaceSize: const Size(360, 640),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('ForgotPasswordPage', () {
    testWidgets('renders the email field', (tester) async {
      await pumpPage(tester, const ForgotPasswordPage());

      expect(find.text('Forgot Password'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('rejects a non-university email', (tester) async {
      await pumpPage(tester, const ForgotPasswordPage());

      await tester.enterText(find.byType(TextFormField), 'someone@gmail.com');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.textContaining('university email'), findsWidgets);
    });

    testWidgets('fits a small phone', (tester) async {
      await pumpPage(
        tester,
        const ForgotPasswordPage(),
        surfaceSize: const Size(360, 640),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
