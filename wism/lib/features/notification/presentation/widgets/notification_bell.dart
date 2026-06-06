import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/notification_providers.dart';
import '../notification_panel.dart';

/// 헤더 알림 종 아이콘 + 미확인 배지.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(unreadCountProvider).maybeWhen(
          data: (c) => c,
          orElse: () => 0,
        );
    return IconButton(
      tooltip: '알림',
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        child: const Icon(Icons.notifications_outlined),
      ),
      onPressed: () => showNotificationPanel(context),
    );
  }
}
