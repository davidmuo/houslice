import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

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
            Navigator.of(context)
                .pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
          case AuthStatus.unauthenticated:
            Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.onboarding, (route) => false);
          case AuthStatus.unknown:
            break;
        }
      },
      child: Scaffold(
        body: Center(
          child: Text(
            'HOUSLICE',
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: 8,
              color: AppColors.dark,
            ),
          ),
        ),
      ),
    );
  }
}
