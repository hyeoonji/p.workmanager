import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/network/dio_client.dart';
import '../data/mock_notification_repository.dart';
import '../data/models/app_notification.dart';
import '../data/notification_repository_impl.dart';
import '../domain/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  if (Env.useMockAuth) return MockNotificationRepository();
  return NotificationRepositoryImpl(ref.read(dioProvider));
});

final notificationsProvider =
    FutureProvider.autoDispose<List<AppNotification>>((ref) async {
  return ref.watch(notificationRepositoryProvider).list();
});

final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  return ref.watch(notificationRepositoryProvider).unreadCount();
});
