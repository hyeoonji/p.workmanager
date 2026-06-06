import 'package:dio/dio.dart';

import '../domain/notification_repository.dart';
import 'models/app_notification.dart';

/// 실서버 알림 리포지토리 (Dio). 실제 푸시 송수신은 FCM(추후) 연동.
class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<AppNotification>> list() async {
    final res = await _dio.get<Map<String, dynamic>>('/notifications');
    return (res.data!['items'] as List)
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<int> unreadCount() async {
    final res = await _dio.get<Map<String, dynamic>>('/notifications/unread-count');
    return res.data!['count'] as int;
  }

  @override
  Future<void> markRead(int id) async {
    await _dio.put('/notifications/$id/read');
  }

  @override
  Future<void> markAllRead() async {
    await _dio.put('/notifications/read-all');
  }
}
