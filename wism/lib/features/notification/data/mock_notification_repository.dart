import '../domain/notification_repository.dart';
import 'mock_notification_data.dart';
import 'models/app_notification.dart';

class _NotiStore {
  _NotiStore._() {
    items = buildSeedNotifications();
  }
  static final instance = _NotiStore._();
  late List<AppNotification> items;
}

class MockNotificationRepository implements NotificationRepository {
  final _store = _NotiStore.instance;

  @override
  Future<List<AppNotification>> list() async {
    await Future.delayed(const Duration(milliseconds: 120));
    final sorted = [..._store.items]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  @override
  Future<int> unreadCount() async {
    return _store.items.where((n) => !n.isRead).length;
  }

  @override
  Future<void> markRead(int id) async {
    final i = _store.items.indexWhere((n) => n.id == id);
    if (i >= 0) _store.items[i] = _store.items[i].copyWith(isRead: true);
  }

  @override
  Future<void> markAllRead() async {
    _store.items = _store.items.map((n) => n.copyWith(isRead: true)).toList();
  }
}
