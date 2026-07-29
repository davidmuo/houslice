import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../injection_container.dart';
import '../cubit/password_reset_cubit.dart';

/// "Verify your Email" — confirms the reset link was sent and offers a resend.
///
/// Firebase Authentication verifies the reset link itself via the emailed
/// URL, so this screen confirms delivery and lets the student request another
/// one rather than re-implementing code checking on the client.
class VerifyCodePage extends StatelessWidget {
  final String email;

  const VerifyCodePage({super.key, required this.email});

  String get _maskedEmail {
    final at = email.indexOf('@');
    if (at <= 1) return email;
    final name = email.substring(0, at);
    final domain = email.substring(at);
    final visible = name.length <= 2 ? name : name.substring(0, 2);
    return '$visible${'*' * (name.length - visible.length)}$domain';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          PasswordResetCubit(sendPasswordReset: sl(), initialEmail: email),
      child: Builder(
        builder: (context) {
          final textTheme = Theme.of(context).textTheme;

          return BlocConsumer<PasswordResetCubit, PasswordResetState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              final message = switch (state.status) {
                PasswordResetStatus.sent => 'Reset link sent again.',
                PasswordResetStatus.failure => state.message,
                _ => null,
              };
              if (message == null) return;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(message)));
            },
            builder: (context, state) => Scaffold(
              appBar: AppBar(),
              body: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    Center(
                      child: Container(
                        width: 92,
                        height: 92,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryFaint,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mark_email_read_outlined,
                          size: 44,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Verify your email',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'We sent a password reset link to',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _maskedEmail,
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Open it on this device to choose a new password. '
                      'Check your spam folder if it has not arrived.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: 'Back to sign in',
                      onPressed: () =>
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.signIn,
                            (route) => false,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: state.busy
                            ? null
                            : context.read<PasswordResetCubit>().resend,
                        child: Text(
                          state.busy ? 'Sending…' : "Didn't receive it? Resend",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
