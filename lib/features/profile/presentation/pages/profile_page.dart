import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$feature is coming in the next release')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.signIn, (route) => false);
        }
      },
      builder: (context, state) {
        final user = state.user;
        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 12),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: AppColors.primaryFaint,
                      foregroundImage: user?.photoUrl == null
                          ? null
                          : NetworkImage(user!.photoUrl!),
                      onForegroundImageError: user?.photoUrl == null
                          ? null
                          : (_, _) {},
                      child: Text(
                        user?.initials ?? '?',
                        style: textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: InkWell(
                        onTap: () =>
                            _comingSoon(context, 'Changing your photo'),
                        customBorder: const CircleBorder(),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.photo_camera,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  user?.username ?? 'Student',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  user?.email ?? '',
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.grey),
                ),
              ),
              const SizedBox(height: 16),
              // Unverified accounts get a persistent prompt. Google accounts
              // arrive already verified, so this only shows for email sign-ups.
              if (user != null && !user.emailVerified)
                _VerifyEmailBanner(
                  busy: state.busy,
                  onResend: () => context.read<AuthBloc>().add(
                    const AuthEmailVerificationRequested(),
                  ),
                ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              _MenuTile(
                icon: Icons.person_outline,
                label: 'Edit Profile',
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.editProfile),
              ),
              _MenuTile(
                icon: Icons.add_home_work_outlined,
                label: 'List your place',
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.createListing),
              ),
              _MenuTile(
                icon: Icons.tune,
                label: 'Lifestyle questionnaire',
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.quiz),
              ),
              _MenuTile(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.settings),
              ),
              _MenuTile(
                icon: Icons.lock_outline,
                label: 'Change Password',
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.newPassword),
              ),
              _MenuTile(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Payment',
                onTap: () => _comingSoon(context, 'Payment management'),
              ),
              _MenuTile(
                icon: Icons.notifications_none_rounded,
                label: 'Notification',
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.notifications),
              ),
              _MenuTile(
                icon: Icons.history,
                label: 'Recent Viewed',
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.search),
              ),
              _MenuTile(
                icon: Icons.info_outline,
                label: 'About',
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'Houseslice',
                  applicationVersion: '1.0.0',
                  applicationLegalese:
                      'A verified student-only housing marketplace for '
                      'Kigali.\nBuilt by Group 22 — African Leadership '
                      'University.',
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: state.busy
                      ? null
                      : () => showDialog<void>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Sign out?'),
                            content: const Text(
                              'You will need your student email to sign back in.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                  context.read<AuthBloc>().add(
                                    const AuthSignOutRequested(),
                                  );
                                },
                                child: const Text(
                                  'Sign Out',
                                  style: TextStyle(color: AppColors.danger),
                                ),
                              ),
                            ],
                          ),
                        ),
                  child: Text(
                    'Sign Out',
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

/// Prompts an unverified student to confirm their university address.
class _VerifyEmailBanner extends StatelessWidget {
  final bool busy;
  final VoidCallback onResend;

  const _VerifyEmailBanner({required this.busy, required this.onResend});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryFaint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.mark_email_unread_outlined,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Verify your student email to build trust with hosts.',
              style: textTheme.bodySmall,
            ),
          ),
          TextButton(
            onPressed: busy ? null : onResend,
            child: Text(busy ? 'Sending…' : 'Resend'),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.grey,
        size: 22,
      ),
    );
  }
}
