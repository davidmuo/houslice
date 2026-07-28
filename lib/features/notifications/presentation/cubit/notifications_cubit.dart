import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_notification.dart';

/// Serves the notification feed. Backed by seeded data in this milestone;
/// swaps to a Firestore stream when push messaging lands.
class NotificationsCubit extends Cubit<List<AppNotification>> {
  NotificationsCubit() : super(const []);

  void load() {
    emit(const [
      AppNotification(
        id: 'n1',
        boldText: 'click here to see your listing',
        body: 'Congratulations, your listing is now active. ',
        kind: NotificationKind.alert,
        unread: true,
        daysAgo: 0,
      ),
      AppNotification(
        id: 'n2',
        body: "Welcome, Don't forget to complete your personal info",
        kind: NotificationKind.alert,
        unread: true,
        daysAgo: 0,
      ),
      AppNotification(
        id: 'n3',
        boldText: 'Anggela and joni',
        body: ' sent you a message, check it now',
        kind: NotificationKind.message,
        avatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=60',
        daysAgo: 1,
      ),
      AppNotification(
        id: 'n4',
        body: "Welcome, Don't forget to complete your personal info",
        kind: NotificationKind.alert,
        unread: true,
        daysAgo: 1,
      ),
      AppNotification(
        id: 'n5',
        body: "Welcome, Don't forget to complete your personal info",
        kind: NotificationKind.account,
        daysAgo: 1,
      ),
      AppNotification(
        id: 'n6',
        boldText: 'Jhon, ani & 2 others',
        body: ' sent you a message, check it now',
        kind: NotificationKind.message,
        avatarUrl:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&q=60',
        daysAgo: 1,
      ),
      AppNotification(
        id: 'n7',
        body: "Welcome, Don't forget to complete your personal info",
        kind: NotificationKind.account,
        daysAgo: 1,
      ),
    ]);
  }
}
