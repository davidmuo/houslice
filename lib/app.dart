import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/booking/presentation/bloc/booking_bloc.dart';
import 'features/notifications/presentation/cubit/notifications_cubit.dart';
import 'features/property/presentation/bloc/property_bloc.dart';
import 'features/property/presentation/cubit/search_cubit.dart';
import 'injection_container.dart';

class HousliceApp extends StatelessWidget {
  const HousliceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<PropertyBloc>(create: (_) => sl<PropertyBloc>()),
        BlocProvider<BookingBloc>(create: (_) => sl<BookingBloc>()),
        BlocProvider<SearchCubit>(create: (_) => sl<SearchCubit>()),
        BlocProvider<NotificationsCubit>(
            create: (_) => sl<NotificationsCubit>()),
      ],
      child: MaterialApp(
        title: 'Houseslice',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
