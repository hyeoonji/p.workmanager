import 'package:flutter_test/flutter_test.dart';
import 'package:wism/features/notification/data/mock_notification_repository.dart';

void main() {
  final repo = MockNotificationRepository();

  test('알림 목록은 최신순', () async {
    final list = await repo.list();
    expect(list, isNotEmpty);
    for (var i = 0; i < list.length - 1; i++) {
      expect(list[i].createdAt.isAfter(list[i + 1].createdAt) ||
          list[i].createdAt.isAtSameMomentAs(list[i + 1].createdAt), isTrue);
    }
  });

  test('markRead 후 미확인 개수 감소', () async {
    final before = await repo.unreadCount();
    final unread = (await repo.list()).firstWhere((n) => !n.isRead);
    await repo.markRead(unread.id);
    expect(await repo.unreadCount(), before - 1);
  });

  test('markAllRead 후 미확인 0', () async {
    await repo.markAllRead();
    expect(await repo.unreadCount(), 0);
  });
}
