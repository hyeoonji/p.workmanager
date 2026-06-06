import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/formats.dart';
import '../../memo/presentation/memo_detail_page.dart';
import '../application/notification_providers.dart';
import '../data/models/app_notification.dart';

/// 오른쪽에서 슬라이드인하는 알림 드로어 (디자인 NotificationPanel).
Future<void> showNotificationPanel(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '알림',
    barrierColor: Colors.black.withValues(alpha: 0.40),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, _, _) => Align(
      alignment: Alignment.centerRight,
      child: _NotificationPanel(rootContext: context),
    ),
    transitionBuilder: (_, anim, _, child) => SlideTransition(
      position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(
        CurvedAnimation(parent: anim, curve: const Cubic(0.32, 0, 0.2, 1)),
      ),
      child: child,
    ),
  );
}

class _IconCfg {
  const _IconCfg(this.bg, this.color, this.icon);
  final Color bg;
  final Color color;
  final IconData icon;
}

const _iconConfig = {
  'comment': _IconCfg(Color(0xFFE8F1FB), Color(0xFF2B9CD8), Icons.chat_bubble_outline),
  'mention': _IconCfg(Color(0xFFEEEAF6), Color(0xFF6B5B95), Icons.notifications_none),
  'status': _IconCfg(Color(0xFFE6F4EA), Color(0xFF2E7D52), Icons.check_circle_outline),
  'urgent': _IconCfg(Color(0xFFFEE4E2), Color(0xFFD92D20), Icons.error_outline),
};

class _NotificationPanel extends ConsumerWidget {
  const _NotificationPanel({required this.rootContext});
  final BuildContext rootContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationsProvider);
    final width = (MediaQuery.sizeOf(context).width * 0.88).clamp(0.0, 420.0);

    return Material(
      color: AppColors.surface,
      child: SizedBox(
        width: width,
        height: double.infinity,
        child: SafeArea(
          bottom: false,
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const Center(child: Text('알림을 불러오지 못했습니다.')),
            data: (items) {
              final unread = items.where((n) => !n.isRead).length;
              return Column(
                children: [
                  _header(context, ref, unread),
                  const Divider(height: 1, color: Color(0xFFEEF1F5)),
                  Expanded(
                    child: items.isEmpty
                        ? _empty()
                        : ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, _) => const Padding(
                              padding: EdgeInsets.only(left: 64),
                              child: Divider(height: 1, color: Color(0xFFEEF1F5)),
                            ),
                            itemBuilder: (_, i) => _tile(context, ref, items[i]),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, WidgetRef ref, int unread) {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Text('알림',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textTitle)),
            if (unread > 0) ...[
              const SizedBox(width: 6),
              Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: AppColors.danger, shape: BoxShape.circle),
                child: Text('$unread',
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
            const Spacer(),
            if (unread > 0)
              TextButton(
                onPressed: () async {
                  await ref.read(notificationRepositoryProvider).markAllRead();
                  ref.invalidate(notificationsProvider);
                  ref.invalidate(unreadCountProvider);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: Size.zero,
                  foregroundColor: AppColors.catSchedule,
                ),
                child: const Text('모두 읽음', style: TextStyle(fontSize: 13)),
              ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close, size: 20, color: AppColors.textSub),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty() => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none,
                size: 40, color: Color(0x808A97A8)),
            SizedBox(height: 8),
            Text('알림이 없습니다',
                style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
          ],
        ),
      );

  Widget _tile(BuildContext context, WidgetRef ref, AppNotification n) {
    final cfg = _iconConfig[n.type] ?? _iconConfig['comment']!;
    return InkWell(
      onTap: () async {
        await ref.read(notificationRepositoryProvider).markRead(n.id);
        ref.invalidate(notificationsProvider);
        ref.invalidate(unreadCountProvider);
        if (context.mounted) Navigator.pop(context);
        if (n.memoId != null && rootContext.mounted) {
          Navigator.push(
            rootContext,
            MaterialPageRoute(builder: (_) => MemoDetailPage(memoId: n.memoId!)),
          );
        }
      },
      child: Container(
        color: n.isRead ? AppColors.surface : const Color(0xFFF5F9FE),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: cfg.bg, shape: BoxShape.circle),
              child: Icon(cfg.icon, size: 16, color: cfg.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n.title,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textTitle)),
                  if (n.content != null) ...[
                    const SizedBox(height: 2),
                    Text(n.content!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textBody,
                            height: 1.4)),
                  ],
                  const SizedBox(height: 4),
                  Text(fmtShort(n.createdAt),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: n.isRead
                  ? const SizedBox(width: 7)
                  : Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                          color: AppColors.catSchedule, shape: BoxShape.circle),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
