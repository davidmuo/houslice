import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/core/routes/app_router.dart';
import 'package:houslice/core/theme/app_theme.dart';
import 'package:houslice/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:houslice/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:houslice/features/lifestyle/presentation/cubit/lifestyle_cubit.dart';
import 'package:houslice/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:houslice/features/property/presentation/bloc/property_bloc.dart';
import 'package:houslice/features/property/presentation/cubit/search_cubit.dart';
import 'package:houslice/features/settings/presentation/cubit/preferences_cubit.dart';
import 'package:houslice/injection_container.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';

/// Boots the real dependency graph in demo mode (in-memory data sources) and
/// pumps [page] inside the same providers the app uses.
///
/// Using the real container rather than mocks means these widget tests
/// exercise the blocs and mock data sources too, which is what makes them
/// worth writing: one pump covers presentation, domain and data.
Future<void> pumpPage(
  WidgetTester tester,
  Widget page, {
  Map<String, Object> storedPreferences = const {},
  bool signedIn = false,
  Size surfaceSize = const Size(430, 932),
}) async {
  await tester.binding.setSurfaceSize(surfaceSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  SharedPreferences.setMockInitialValues(storedPreferences);
  await di.sl.reset();
  await di.init(useFirebase: false);
  await di.sl<PreferencesCubit>().load();
  await di.sl<LifestyleCubit>().load();

  final authBloc = di.sl<AuthBloc>();
  if (signedIn) {
    authBloc.add(
      const AuthSignInRequested(
        email: 'j.simmons@alustudent.com',
        password: 'password123',
      ),
    );
  }

  // MainShell loads listings and bookings once and the tabs share the result,
  // so a page pumped on its own needs the same priming to be realistic.
  final propertyBloc = di.sl<PropertyBloc>()..add(const PropertiesRequested());
  final bookingBloc = di.sl<BookingBloc>()..add(const BookingsRequested());
  final notificationsCubit = di.sl<NotificationsCubit>()..load();

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<PropertyBloc>.value(value: propertyBloc),
        BlocProvider<BookingBloc>.value(value: bookingBloc),
        BlocProvider<SearchCubit>(create: (_) => di.sl<SearchCubit>()),
        BlocProvider<NotificationsCubit>.value(value: notificationsCubit),
        BlocProvider<PreferencesCubit>.value(value: di.sl<PreferencesCubit>()),
        BlocProvider<LifestyleCubit>.value(value: di.sl<LifestyleCubit>()),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: page,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    ),
  );

  // Let the mock data sources' artificial latency resolve (sign-in alone
  // takes 600ms in MockAuthDataSource).
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pump(const Duration(milliseconds: 300));
}

/// Resets the container between tests.
void registerHarnessTeardown() {
  tearDown(() => di.sl.reset());
}
