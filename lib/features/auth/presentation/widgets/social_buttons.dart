import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';

/// "Or continue with" divider plus the social sign-in circles from the Figma
/// auth screens.
///
/// Google is Houseslice's second authentication method and is fully wired.
/// Facebook stays decorative — it is not one of the two methods the project
/// implements, and pretending otherwise would be worse than saying so.
class SocialButtons extends StatelessWidget {
  const SocialButtons({super.key});

  void _facebookUnavailable(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Facebook sign-in is not available. Use Google or your student '
            'email.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) => previous.busy != current.busy,
      builder: (context, state) => Column(
        children: [
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Or',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.grey),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialCircle(
                onTap: () => _facebookUnavailable(context),
                child: const Icon(
                  Icons.facebook,
                  color: Color(0xFF1877F2),
                  size: 30,
                ),
              ),
              const SizedBox(width: 20),
              _SocialCircle(
                // Disabled while any auth request is in flight, so a double
                // tap cannot open two Google sheets.
                onTap: state.busy
                    ? null
                    : () => context.read<AuthBloc>().add(
                        const AuthGoogleSignInRequested(),
                      ),
                child: const Text(
                  'G',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFDB4437),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Google sign-in needs a university account',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}

class _SocialCircle extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _SocialCircle({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
