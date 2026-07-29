import 'package:equatable/equatable.dart';

enum NotificationKind { alert, account, message }

/// An in-app notification (listing updates, messages, account nudges).
class AppNotification extends Equatable {
  final String id;
  final String? boldText;
  final String body;
  final NotificationKind kind;
  final String? avatarUrl;
  final bool unread;

  /// 0 = today, 1 = yesterday, ...
  final int daysAgo;

  const AppNotification({
    required this.id,
    this.boldText,
    required this.body,
    required this.kind,
    this.avatarUrl,
    this.unread = false,
    required this.daysAgo,
  });

  @override
  List<Object?> get props => [
    id,
    boldText,
    body,
    kind,
    avatarUrl,
    unread,
    daysAgo,
  ];
}
