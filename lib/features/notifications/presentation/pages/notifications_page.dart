import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/app_notification.dart';
import '../cubit/notifications_cubit.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification')),
      body: BlocBuilder<NotificationsCubit, List<AppNotification>>(
        builder: (context, notifications) {
          if (notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No notifications yet',
              subtitle:
                  Text('Updates about listings and messages land here'),
            );
          }
          final today = notifications.where((n) => n.daysAgo == 0).toList();
          final yesterday =
              notifications.where((n) => n.daysAgo == 1).toList();
          final older = notifications.where((n) => n.daysAgo > 1).toList();
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: [
              if (today.isNotEmpty) ...[
                const _GroupHeader('Today'),
                for (final n in today) _NotificationTile(notification: n),
              ],
              if (yesterday.isNotEmpty) ...[
                const SizedBox(height: 16),
                const _GroupHeader('Yesterday'),
                for (final n in yesterday)
                  _NotificationTile(notification: n),
              ],
              if (older.isNotEmpty) ...[
                const SizedBox(height: 16),
                const _GroupHeader('Earlier'),
                for (final n in older) _NotificationTile(notification: n),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String title;

  const _GroupHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.w800, fontSize: 20),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(notification: notification),
              const SizedBox(width: 14),
              Expanded(
                child: notification.kind == NotificationKind.message
                    ? Text.rich(
                        TextSpan(
                          text: notification.boldText,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.dark,
                          ),
                          children: [
                            TextSpan(
                              text: notification.body,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w400,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Text.rich(
                        TextSpan(
                          text: notification.body,
                          style: textTheme.bodyMedium
                              ?.copyWith(color: AppColors.grey),
                          children: [
                            if (notification.boldText != null)
                              TextSpan(
                                text: notification.boldText,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.dark,
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final AppNotification notification;

  const _Avatar({required this.notification});

  @override
  Widget build(BuildContext context) {
    final icon = switch (notification.kind) {
      NotificationKind.alert => Icons.notifications_none_rounded,
      NotificationKind.account => Icons.person_outline_rounded,
      NotificationKind.message => Icons.person_outline_rounded,
    };
    return Stack(
      children: [
        if (notification.kind == NotificationKind.message &&
            notification.avatarUrl != null)
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryFaint,
            foregroundImage: NetworkImage(notification.avatarUrl!),
            onForegroundImageError: (_, _) {},
            child: Icon(icon, color: AppColors.primary),
          )
        else
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryFaint,
            child: Icon(icon, color: AppColors.primary),
          ),
        if (notification.unread)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}
