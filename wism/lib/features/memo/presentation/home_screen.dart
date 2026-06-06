import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/formats.dart';
import '../../../shared/widgets/memo_badges.dart';
import '../../auth/application/auth_controller.dart';
import '../../calendar/presentation/calendar_page.dart';
import '../../notification/presentation/widgets/notification_bell.dart';
import '../application/memo_providers.dart';
import '../data/models/memo.dart';
import 'memo_detail_page.dart';
import 'write_memo_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late DateTime _selectedDay = _dateOnly(DateTime.now());

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  bool _sameDay(DateTime? a, DateTime b) =>
      a != null && _dateOnly(a) == _dateOnly(b);

  void _openCalendar() => Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (_) => const CalendarPage()),
      );

  void _openMemo(int id) => Navigator.of(context, rootNavigator: true)
      .push(MaterialPageRoute(builder: (_) => MemoDetailPage(memoId: id)))
      .then((_) => ref.invalidate(allMemosProvider));

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(allMemosProvider);
    final myId = ref.watch(authControllerProvider).user?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('홈'),
        actions: const [NotificationBell()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ok = await showWriteMemoSheet(context);
          if (ok == true) {
            ref.invalidate(allMemosProvider);
            ref.invalidate(memoListProvider);
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 26),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('불러오지 못했습니다.')),
        data: (memos) {
          final today = _dateOnly(DateTime.now());
          final unreadUrgent = memos
              .where((m) => m.isUrgent && m.readBy < m.totalReaders)
              .toList();
          final todayCount =
              memos.where((m) => _sameDay(m.scheduledDate, today)).length;
          final myCount = memos.where((m) => m.author.id == myId).length;
          final recent = [...memos]
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(allMemosProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _statRow(unreadUrgent.length, todayCount, myCount),
                const SizedBox(height: 16),
                if (unreadUrgent.isNotEmpty) ...[
                  _UrgentSection(memos: unreadUrgent.take(3).toList(), onTap: _openMemo),
                  const SizedBox(height: 16),
                ],
                _weekSection(memos),
                const SizedBox(height: 16),
                _recentSection(recent.take(3).toList()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statRow(int urgent, int today, int mine) {
    return Row(
      children: [
        _statCard('긴급', urgent,
            iconColor: const Color(0xFFD92D20),
            countColor: const Color(0xFFD92D20),
            bg: const Color(0xFFFEE2E2),
            icon: Icons.notifications_active,
            onTap: () => context.go('/all')),
        const SizedBox(width: 12),
        _statCard('오늘', today,
            iconColor: const Color(0xFF2B9CD8),
            countColor: AppColors.primary,
            bg: const Color(0xFFEBF3FB),
            icon: Icons.calendar_today,
            onTap: _openCalendar),
        const SizedBox(width: 12),
        _statCard('내 메모', mine,
            iconColor: const Color(0xFF22A85A),
            countColor: AppColors.primary,
            bg: const Color(0xFFEBF5EE),
            icon: Icons.description,
            onTap: () => context.go('/my')),
      ],
    );
  }

  Widget _statCard(String label, int count,
      {required Color iconColor,
      required Color countColor,
      required Color bg,
      required IconData icon,
      required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: bg,
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: 6),
              Text('$count',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: countColor,
                      height: 1)),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSub)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _weekSection(List<Memo> memos) {
    final today = _dateOnly(DateTime.now());
    final weekStart = today.subtract(Duration(days: today.weekday % 7));
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));
    const labels = ['일', '월', '화', '수', '목', '금', '토'];
    final selectedMemos =
        memos.where((m) => _sameDay(m.scheduledDate, _selectedDay)).toList();

    return _sectionCard(
      icon: Icons.calendar_today,
      iconColor: AppColors.catSchedule,
      title: '이번 주 일정',
      trailing: TextButton(
        onPressed: _openCalendar,
        child: const Text('캘린더 전체보기'),
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(7, (i) {
              final d = days[i];
              final isSel = _dateOnly(d) == _selectedDay;
              final isToday = _dateOnly(d) == today;
              final hasEvent =
                  memos.any((m) => _sameDay(m.scheduledDate, d));
              final dow = i == 0
                  ? AppColors.danger
                  : i == 6
                      ? AppColors.catSchedule
                      : AppColors.textMuted;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDay = _dateOnly(d)),
                  child: Column(
                    children: [
                      Text(labels[i],
                          style: TextStyle(fontSize: 12, color: dow)),
                      const SizedBox(height: 4),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isToday
                              ? AppColors.primary
                              : isSel
                                  ? AppColors.primary.withValues(alpha: 0.12)
                                  : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${d.day}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isToday ? Colors.white : AppColors.textTitle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hasEvent
                              ? AppColors.catSchedule
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const Divider(height: 20),
          if (selectedMemos.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('이 날짜에 등록된 일정이 없습니다',
                  style: TextStyle(color: AppColors.textMuted)),
            )
          else
            ...selectedMemos.map((m) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: Container(
                    width: 4,
                    height: 32,
                    color: m.isUrgent
                        ? AppColors.danger
                        : AppColors.category(m.category),
                  ),
                  title: Text(m.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(m.author.name),
                  onTap: () => _openMemo(m.id),
                )),
        ],
      ),
    );
  }

  Widget _recentSection(List<Memo> recent) {
    return _sectionCard(
      icon: Icons.description,
      iconColor: AppColors.primary,
      title: '최근 업데이트',
      child: Column(
        children: recent
            .map((m) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: Icon(Icons.circle,
                      size: 8,
                      color: m.isUrgent ? AppColors.danger : AppColors.primary),
                  title: Text(m.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${m.author.name} · ${fmtShort(m.createdAt)}'),
                  trailing: m.isUrgent ? const UrgentBadge() : null,
                  onTap: () => _openMemo(m.id),
                ))
            .toList(),
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
              const Spacer(),
              ?trailing,
            ],
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

class _UrgentSection extends StatelessWidget {
  const _UrgentSection({required this.memos, required this.onTap});
  final List<Memo> memos;
  final void Function(int id) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active,
                  size: 16, color: AppColors.danger),
              const SizedBox(width: 6),
              const Text('미확인 긴급 이슈',
                  style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.dangerBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${memos.length}',
                    style: const TextStyle(
                        color: AppColors.danger, fontSize: 12)),
              ),
            ],
          ),
          ...memos.map((m) => ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: const Icon(Icons.circle, size: 8, color: AppColors.danger),
                title: Text(m.title,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(m.author.name),
                onTap: () => onTap(m.id),
              )),
        ],
      ),
    );
  }
}
