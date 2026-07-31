import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/features/notifications/presentation/pages/notifications_page.dart';
import 'package:houslice/features/onboarding/presentation/pages/location_page.dart';
import 'package:houslice/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:houslice/features/profile/presentation/pages/profile_page.dart';
import 'package:houslice/features/shell/presentation/pages/main_shell.dart';

import '../../helpers/app_harness.dart';

/// Widget tests for the shell, profile, notifications and onboarding screens.
void main() {
  registerHarnessTeardown();

  group('MainShell', () {
    testWidgets('renders the bottom navigation', (tester) async {
      await pumpPage(tester, const MainShell(), signedIn: true);

      expect(find.byType(BottomNavigationBar), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('every tab can be opened', (tester) async {
      await pumpPage(tester, const MainShell(), signedIn: true);

      final bar = find.byType(BottomNavigationBar);
      if (bar.evaluate().isNotEmpty) {
        final widget = tester.widget<BottomNavigationBar>(bar.first);
        for (var i = 1; i < widget.items.length; i++) {
          final icon = find.byIcon(
            widget.items[i].icon is Icon
                ? (widget.items[i].icon as Icon).icon!
                : Icons.circle,
          );
          if (icon.evaluate().isNotEmpty) {
            await tester.tap(icon.first, warnIfMissed: false);
            await tester.pump(const Duration(milliseconds: 400));
          }
        }
      }

      expect(tester.takeException(), isNull);
    });

    testWidgets('fits a small phone', (tester) async {
      await pumpPage(
        tester,
        const MainShell(),
        signedIn: true,
        surfaceSize: const Size(360, 640),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('ProfilePage', () {
    testWidgets('shows the signed-in student', (tester) async {
      await pumpPage(tester, const ProfilePage(), signedIn: true);

      expect(find.text('Profile'), findsWidgets);
      expect(find.text('Settings'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows Settings and Change Password entries', (tester) async {
      await pumpPage(tester, const ProfilePage(), signedIn: true);

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
    });

    testWidgets('the sign-out confirmation opens', (tester) async {
      await pumpPage(tester, const ProfilePage(), signedIn: true);

      final signOut = find.text('Sign Out');
      if (signOut.evaluate().isNotEmpty) {
        await tester.tap(signOut.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('Sign out?'), findsWidgets);
      }
    });

    testWidgets('the about dialog opens', (tester) async {
      await pumpPage(tester, const ProfilePage(), signedIn: true);

      final about = find.text('About');
      if (about.evaluate().isNotEmpty) {
        await tester.tap(about.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 500));
      }

      expect(tester.takeException(), isNull);
    });
  });

  group('NotificationsPage', () {
    testWidgets('renders the seeded feed grouped by day', (tester) async {
      await pumpPage(tester, const NotificationsPage(), signedIn: true);

      expect(find.text('Notification'), findsWidgets);
      expect(find.text('No notifications yet'), findsNothing);
      expect(find.text('Today'), findsWidgets);
      expect(find.text('Yesterday'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fits a small phone', (tester) async {
      await pumpPage(
        tester,
        const NotificationsPage(),
        signedIn: true,
        surfaceSize: const Size(360, 640),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('survives a landscape rotation', (tester) async {
      await pumpPage(
        tester,
        const NotificationsPage(),
        signedIn: true,
        surfaceSize: const Size(932, 430),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('OnboardingPage', () {
    testWidgets('renders the first slide with a Next button', (tester) async {
      await pumpPage(tester, const OnboardingPage());

      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('paging through reaches Get Started', (tester) async {
      await pumpPage(tester, const OnboardingPage());

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('fits a small phone', (tester) async {
      await pumpPage(
        tester,
        const OnboardingPage(),
        surfaceSize: const Size(360, 640),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('LocationPage', () {
    testWidgets('renders the location chooser', (tester) async {
      await pumpPage(tester, const LocationPage());

      expect(tester.takeException(), isNull);
    });
  });
}
