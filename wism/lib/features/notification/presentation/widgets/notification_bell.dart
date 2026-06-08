import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
        backgroundColor: const Color(0xFFEF4444),
        textColor: Colors.white,
        label: Text(count > 9 ? '9+' : '$count',
            style: const TextStyle(fontSize: 10)),
        child: const Icon(LucideIcons.bell, size: 20, color: Colors.white),
      ),
      onPressed: () => showNotificationPanel(context),
    );
  }
}
