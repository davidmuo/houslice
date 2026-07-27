import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/new_password_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/booking/presentation/pages/booking_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/onboarding/presentation/pages/location_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/onboarding/presentation/pages/splash_page.dart';
import '../../features/property/domain/entities/property.dart';
import '../../features/property/presentation/pages/property_details_page.dart';
import '../../features/property/presentation/pages/search_page.dart';
import '../../features/shell/presentation/pages/main_shell.dart';
import 'app_routes.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _page(const SplashPage(), settings);
      case AppRoutes.onboarding:
        return _page(const OnboardingPage(), settings);
      case AppRoutes.location:
        return _page(const LocationPage(), settings);
      case AppRoutes.register:
        return _page(const RegisterPage(), settings);
      case AppRoutes.signIn:
        return _page(const SignInPage(), settings);
      case AppRoutes.newPassword:
        return _page(const NewPasswordPage(), settings);
      case AppRoutes.main:
        return _page(const MainShell(), settings);
      case AppRoutes.search:
        return _page(const SearchPage(), settings);
      case AppRoutes.notifications:
        return _page(const NotificationsPage(), settings);
      case AppRoutes.details:
        final property = settings.arguments as Property;
        return _page(PropertyDetailsPage(property: property), settings);
      case AppRoutes.booking:
        final property = settings.arguments as Property;
        return _page(BookingPage(property: property), settings);
      default:
        return _page(
          Scaffold(
            body: Center(child: Text('No route for ${settings.name}')),
          ),
          settings,
        );
    }
  }

  static MaterialPageRoute<dynamic> _page(
    Widget child,
    RouteSettings settings,
  ) =>
      MaterialPageRoute(builder: (_) => child, settings: settings);
}
