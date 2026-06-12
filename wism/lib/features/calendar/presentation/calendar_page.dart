import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/formats.dart';
import '../../memo/application/memo_providers.dart';
import '../../memo/data/models/memo.dart';
import '../../memo/presentation/memo_detail_page.dart';

/// 캘린더 (디자인 CalendarModal): 커스텀 월그리드 + 선택일 일정 리스트.
class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime _month = _firstOfMonth(DateTime.now());
  late DateTime _selected = _dateOnly(DateTime.now());

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  static DateTime _firstOfMonth(DateTime d) => DateTime(d.year, d.month);

  void _prev() => setState(() => _month = DateTime(_month.year, _month.month - 1));
  void _next() => setState(() => _month = DateTime(_month.year, _month.month + 1));

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(allMemosProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('캘린더'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('불러오지 못했습니다.')),
        data: (memos) {
          final byDate = <DateTime, List<Memo>>{};
          for (final m in memos) {
            if (m.scheduledDate == null) continue;
            (byDate[_dateOnly(m.scheduledDate!)] ??= []).add(m);
          }
          final selectedMemos = byDate[_selected] ?? [];
          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              _monthNav(),
              _calendarCard(byDate),
              _listSection(selectedMemos),
            ],
          );
        },
      ),
    );
  }

  Widget _monthNav() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navBtn(LucideIcons.chevronLeft, _prev),
          Text('${_month.year}년 ${_month.month}월',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
          _navBtn(LucideIcons.chevronRight, _next),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
      );

  Widget _calendarCard(Map<DateTime, List<Memo>> byDate) {
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final firstDow = DateTime(_month.year, _month.month, 1).weekday % 7; // 일=0
    final rows = ((firstDow + daysInMonth) / 7).ceil();
    final today = _dateOnly(DateTime.now());
    const dayNames = ['일', '월', '화', '수', '목', '금', '토'];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
            child: Row(
              children: List.generate(7, (i) {
                final c = i == 0
                    ? AppColors.danger
                    : i == 6
                        ? AppColors.skyBlue
                        : AppColors.textMuted;
                return Expanded(
                  child: Center(
                    child: Text(dayNames[i],
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500, color: c)),
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: Column(
              children: List.generate(rows, (row) {
                return Row(
                  children: List.generate(7, (col) {
                    final day = row * 7 + col - firstDow + 1;
                    if (day < 1 || day > daysInMonth) {
                      return const Expanded(child: SizedBox(height: 48));
                    }
                    final date = DateTime(_month.year, _month.month, day);
                    final selected = date == _selected;
                    final isToday = date == today;
                    final dayMemos = byDate[date] ?? [];
                    final dots = dayMemos
                        .take(3)
                        .map((m) =>
                            AppColors.category(m.isUrgent ? '이슈' : m.category))
                        .toList();
                    final numColor = selected
                        ? Colors.white
                        : isToday
                            ? AppColors.primary
                            : col == 0
                                ? AppColors.danger
                                : col == 6
                                    ? AppColors.skyBlue
                                    : AppColors.textTitle;
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _selected = date),
                        child: SizedBox(
                          height: 48,
                          child: Column(
                            children: [
                              const SizedBox(height: 4),
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: selected
                                      ? AppColors.primary
                                      : isToday
                                          ? const Color(0xFFE8F1FB)
                                          : Colors.transparent,
                                ),
                                alignment: Alignment.center,
                                child: Text('$day',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: numColor)),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: dots
                                    .map((c) => Container(
                                          width: 4,
                                          height: 4,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 1),
                                          decoration: BoxDecoration(
                                              color: c, shape: BoxShape.circle),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _listSection(List<Memo> memos) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${fmtDate(_selected)} 일정',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTitle)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1FB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('${memos.length}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.catSchedule)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (memos.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text('이 날짜에 등록된 일정이 없습니다',
                    style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
              ),
            )
          else
            ...memos.map(_memoCard),
        ],
      ),
    );
  }

  Widget _miniChip(String text, Color fg, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: TextStyle(fontSize: 11, color: fg)),
      );

  Widget _memoCard(Memo m) {
    final barColor =
        m.isUrgent ? AppColors.danger : AppColors.category(m.category);
    final meta = [
      fmtTime(m.scheduledDate ?? m.createdAt), // 일정 시각 표시
      m.author.name,
      if (m.project != null) m.project!.name,
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (_) => MemoDetailPage(memoId: m.id)),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
          ),
          padding: const EdgeInsets.fromLTRB(10, 12, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 36,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(m.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textTitle,
                                  height: 1.4)),
                        ),
                        const SizedBox(width: 8),
                        // 긴급 + 카테고리 배지를 한 줄로 (의도적 가로 나열 — 세로면 좌측 바가 길어짐)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (m.isUrgent) ...[
                              _miniChip('긴급', AppColors.urgentFg, AppColors.urgentBg),
                              const SizedBox(width: 4),
                            ],
                            _miniChip(
                                m.category,
                                AppColors.categoryBadgeFg(m.category),
                                AppColors.categoryBadgeBg(m.category)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(meta,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
