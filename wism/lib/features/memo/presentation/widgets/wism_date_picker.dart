import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/utils/formats.dart';

/// 디자인(DatePickerCalendar) 기반 인라인 날짜 선택 필드.
/// 탭하면 필드 아래로 캘린더가 펼쳐진다.
class WismDatePicker extends StatefulWidget {
  const WismDatePicker({super.key, required this.value, required this.onChanged});
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  @override
  State<WismDatePicker> createState() => _WismDatePickerState();
}

class _WismDatePickerState extends State<WismDatePicker> {
  bool _open = false;
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final base = widget.value ?? DateTime.now();
    _month = DateTime(base.year, base.month);
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _prev() => setState(() => _month = DateTime(_month.year, _month.month - 1));
  void _next() => setState(() => _month = DateTime(_month.year, _month.month + 1));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 트리거 필드
        InkWell(
          onTap: () => setState(() => _open = !_open),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _open ? AppColors.primary : AppColors.border,
                width: _open ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.value != null ? fmtDate(widget.value!) : '날짜를 선택하세요',
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.value != null
                          ? AppColors.textTitle
                          : AppColors.textMuted,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
        if (_open) ...[
          const SizedBox(height: 6),
          _calendar(),
        ],
      ],
    );
  }

  Widget _calendar() {
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final firstDow = DateTime(_month.year, _month.month, 1).weekday % 7; // 일=0
    final rows = ((firstDow + daysInMonth) / 7).ceil();
    final today = DateTime.now();
    const dayNames = ['일', '월', '화', '수', '목', '금', '토'];

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 월 네비게이션
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navButton(Icons.chevron_left, _prev),
              Text('${_month.year}년 ${_month.month}월',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
              _navButton(Icons.chevron_right, _next),
            ],
          ),
          const SizedBox(height: 10),
          // 요일 헤더
          Row(
            children: List.generate(7, (i) {
              final color = i == 0
                  ? AppColors.danger
                  : i == 6
                      ? AppColors.catSchedule
                      : AppColors.textMuted;
              return Expanded(
                child: Center(
                  child: Text(dayNames[i],
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: color)),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          // 날짜 그리드
          ...List.generate(rows, (row) {
            return Row(
              children: List.generate(7, (col) {
                final day = row * 7 + col - firstDow + 1;
                if (day < 1 || day > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 36));
                }
                final date = DateTime(_month.year, _month.month, day);
                final isSelected =
                    widget.value != null && _sameDay(date, widget.value!);
                final isToday = _sameDay(date, today);
                final numColor = isSelected
                    ? Colors.white
                    : isToday
                        ? AppColors.primary
                        : col == 0
                            ? AppColors.danger
                            : col == 6
                                ? AppColors.catSchedule
                                : AppColors.textTitle;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      widget.onChanged(date);
                      setState(() => _open = false);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      height: 36,
                      child: Center(
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppColors.primary
                                : isToday
                                    ? const Color(0xFFE8F1FB)
                                    : Colors.transparent,
                          ),
                          alignment: Alignment.center,
                          child: Text('$day',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: numColor)),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.background,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
      );
}
