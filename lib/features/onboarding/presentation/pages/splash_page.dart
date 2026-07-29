import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../lifestyle/presentation/cubit/lifestyle_cubit.dart';
import '../../../settings/presentation/cubit/preferences_cubit.dart';

/// HOUSLICE branded splash. After a short delay it asks the AuthBloc to
/// restore the session and routes to onboarding or the main shell.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) {
        context.read<AuthBloc>().add(const AuthCheckRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        switch (state.status) {
          case AuthStatus.authenticated:
            Navigator.of(context).pushNamedAndRemoveUntil(
              context.read<LifestyleCubit>().state.hasProfile
                  ? AppRoutes.main
                  : AppRoutes.quiz,
              (route) => false,
            );
          case AuthStatus.unauthenticated:
            // Returning users who already saw the intro slides go straight
            // to sign-in; the flag is restored from device storage.
            final seenIntro = context
                .read<PreferencesCubit>()
                .state
                .preferences
                .onboardingComplete;
            Navigator.of(context).pushNamedAndRemoveUntil(
              seenIntro ? AppRoutes.signIn : AppRoutes.onboarding,
              (route) => false,
            );
          case AuthStatus.unknown:
            break;
        }
      },
      child: Scaffold(
        body: Center(
          child: Text(
            'HOUSLICE',
            // Pulled from the theme rather than hardcoded, so the wordmark
            // stays legible in dark mode.
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: 8,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
