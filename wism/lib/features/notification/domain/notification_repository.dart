import '../data/models/app_notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> list();
  Future<int> unreadCount();
  Future<void> markRead(int id);
  Future<void> markAllRead();
}
