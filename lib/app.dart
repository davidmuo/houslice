import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/booking/presentation/bloc/booking_bloc.dart';
import 'features/lifestyle/presentation/cubit/lifestyle_cubit.dart';
import 'features/notifications/presentation/cubit/notifications_cubit.dart';
import 'features/property/presentation/bloc/property_bloc.dart';
import 'features/property/presentation/cubit/search_cubit.dart';
import 'features/settings/domain/entities/app_preferences.dart';
import 'features/settings/presentation/cubit/preferences_cubit.dart';
import 'injection_container.dart';

class HousliceApp extends StatelessWidget {
  const HousliceApp({super.key});

  /// Maps our domain enum onto Flutter's [ThemeMode]. Keeping the domain free
  /// of Flutter types means the settings feature stays unit-testable.
  static ThemeMode _themeModeFor(AppThemeMode mode) => switch (mode) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<PropertyBloc>(create: (_) => sl<PropertyBloc>()),
        BlocProvider<BookingBloc>(create: (_) => sl<BookingBloc>()),
        BlocProvider<SearchCubit>(create: (_) => sl<SearchCubit>()),
        BlocProvider<NotificationsCubit>(
          create: (_) => sl<NotificationsCubit>(),
        ),
        BlocProvider<PreferencesCubit>(create: (_) => sl<PreferencesCubit>()),
        BlocProvider<LifestyleCubit>(create: (_) => sl<LifestyleCubit>()),
      ],
      // Only the theme preference should rebuild MaterialApp, so the whole
      // tree is not torn down when an unrelated setting changes.
      child: BlocBuilder<PreferencesCubit, PreferencesState>(
        buildWhen: (previous, current) =>
            previous.preferences.themeMode != current.preferences.themeMode,
        builder: (context, state) {
          return MaterialApp(
            title: 'Houseslice',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: _themeModeFor(state.preferences.themeMode),
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}
