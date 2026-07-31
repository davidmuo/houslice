// Every argument-free screen is pumped at three viewports and asserted to lay
// out without a RenderFlex overflow:
//
//   932x430  landscape rotation of a large phone
//   320x568  the smallest phone we support (iPhone SE class)
//   430x932  the design's reference size
//
// Screens that need route arguments (details, booking, add-card) get the same
// treatment inside their own feature tests.
//
// This suite is what caught LocationPage overflowing by 134px in landscape and
// NewPasswordPage by 34px, both of which were invisible in portrait.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/features/auth/presentation/pages/new_password_page.dart';
import 'package:houslice/features/auth/presentation/pages/register_page.dart';
import 'package:houslice/features/auth/presentation/pages/reset_success_page.dart';
import 'package:houslice/features/auth/presentation/pages/sign_in_page.dart';
import 'package:houslice/features/lifestyle/presentation/pages/quiz_page.dart';
import 'package:houslice/features/notifications/presentation/pages/notifications_page.dart';
import 'package:houslice/features/onboarding/presentation/pages/location_page.dart';
import 'package:houslice/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:houslice/features/profile/presentation/pages/profile_page.dart';
import 'package:houslice/features/settings/presentation/pages/settings_page.dart';

import '../helpers/app_harness.dart';

void main() {
  registerHarnessTeardown();

  /// The viewports every screen has to survive.
  const viewports = <String, Size>{
    'landscape 932x430': Size(932, 430),
    'small phone 320x568': Size(320, 568),
    'reference 430x932': Size(430, 932),
  };

  /// Screens that can be constructed without route arguments.
  Map<String, Widget> pagesUnderTest() => {
    'LocationPage': const LocationPage(),
    'OnboardingPage': const OnboardingPage(),
    'SignInPage': const SignInPage(),
    'RegisterPage': const RegisterPage(),
    'NewPasswordPage': const NewPasswordPage(),
    'ResetSuccessPage': const ResetSuccessPage(),
    'QuizPage': const QuizPage(),
    'ProfilePage': const ProfilePage(),
    'SettingsPage': const SettingsPage(),
    'NotificationsPage': const NotificationsPage(),
  };

  for (final page in pagesUnderTest().entries) {
    group(page.key, () {
      for (final viewport in viewports.entries) {
        testWidgets('lays out without overflow at ${viewport.key}', (
          tester,
        ) async {
          await pumpPage(
            tester,
            pagesUnderTest()[page.key]!,
            signedIn: true,
            surfaceSize: viewport.value,
          );

          // A RenderFlex overflow is reported as a FlutterError rather than a
          // thrown exception, so it surfaces here via takeException().
          expect(
            tester.takeException(),
            isNull,
            reason: '${page.key} overflowed at ${viewport.key}',
          );
        });
      }
    });
  }
}
