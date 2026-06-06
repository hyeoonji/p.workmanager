import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/application/auth_controller.dart';
import '../application/profile_providers.dart';
import 'profile_edit_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final stats = ref.watch(profileStatsProvider);
    final pushEnabled = ref.watch(pushEnabledProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final initials = user.name.characters.take(2).toString();

    return Scaffold(
      appBar: AppBar(title: const Text('프로필')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 프로필 카드
          _card(
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFFEBF3FB),
                      child: Text(initials,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(
                            [user.dept, user.position]
                                .where((e) => e != null && e.isNotEmpty)
                                .join(' · '),
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await showProfileEditSheet(context, user);
                      },
                      icon: const Icon(Icons.edit, size: 14),
                      label: const Text('편집'),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _infoRow(Icons.badge_outlined, '사번', user.employeeNo),
                _infoRow(Icons.mail_outline, '이메일', user.email ?? '-'),
                _infoRow(Icons.phone_outlined, '전화번호', user.phone ?? '-'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 활동 통계
          const _SectionLabel('활동 통계'),
          _card(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: stats.when(
              loading: () => const SizedBox(
                  height: 60, child: Center(child: CircularProgressIndicator())),
              error: (_, _) => const SizedBox(
                  height: 60, child: Center(child: Text('통계를 불러오지 못했습니다.'))),
              data: (s) => Row(
                children: [
                  _stat('내 메모', s.memos, AppColors.primary,
                      const Color(0xFFEBF3FB), Icons.description_outlined),
                  _divider(),
                  _stat('댓글', s.comments, AppColors.catMeeting,
                      const Color(0xFFEEEAF6), Icons.chat_bubble_outline),
                  _divider(),
                  _stat('북마크', s.bookmarks, AppColors.catDecision,
                      const Color(0xFFE6F4EA), Icons.bookmark_border),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 설정
          const _SectionLabel('설정'),
          _card(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('푸시 알림'),
                  secondary: const Icon(Icons.notifications_outlined),
                  value: pushEnabled,
                  onChanged: (v) =>
                      ref.read(pushEnabledProvider.notifier).set(v),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('버전 정보'),
                  trailing: Text('v1.0.0',
                      style: TextStyle(color: AppColors.textMuted)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton.icon(
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).logout(),
              icon: const Icon(Icons.logout, color: AppColors.danger),
              label: const Text('로그아웃',
                  style: TextStyle(color: AppColors.danger)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child, EdgeInsets? padding}) => Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
        ),
        child: child,
      );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textMuted)),
            const Spacer(),
            Text(value,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textBody)),
          ],
        ),
      );

  Widget _stat(String label, int count, Color color, Color bg, IconData icon) =>
      Expanded(
        child: Column(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: bg,
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 6),
            Text('$count',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style:
                    const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
      );

  Widget _divider() =>
      Container(width: 1, height: 36, color: const Color(0xFFEEF1F5));
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted)),
      );
}
