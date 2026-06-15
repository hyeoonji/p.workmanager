import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';

/// 디자인(DatePickerCalendar) 기반 인라인 날짜+시간 선택 필드.
/// 탭하면 필드 아래로 캘린더+시간 선택이 펼쳐진다.
/// value(DateTime)에 시간 성분까지 담는다(모델 변경 없음).
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
  late String _ampm; // 오전 | 오후
  late int _hour12; // 1~12
  late int _minute; // 0,5,...,55

  @override
  void initState() {
    super.initState();
    final base = widget.value ?? DateTime.now();
    _month = DateTime(base.year, base.month);
    _syncTimeFrom(widget.value);
  }

  void _syncTimeFrom(DateTime? v) {
    final h24 = v?.hour ?? 9;
    final m = v?.minute ?? 0;
    _ampm = h24 < 12 ? '오전' : '오후';
    _hour12 = h24 == 0 ? 12 : (h24 > 12 ? h24 - 12 : h24);
    _minute = (m ~/ 5) * 5;
  }

  int get _hour24 {
    if (_ampm == '오전') return _hour12 == 12 ? 0 : _hour12;
    return _hour12 == 12 ? 12 : _hour12 + 12;
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _prev() => setState(() => _month = DateTime(_month.year, _month.month - 1));
  void _next() => setState(() => _month = DateTime(_month.year, _month.month + 1));

  void _pickDate(DateTime date) {
    widget.onChanged(
        DateTime(date.year, date.month, date.day, _hour24, _minute));
    setState(() {});
  }

  void _emitTime() {
    final v = widget.value;
    if (v == null) return;
    widget.onChanged(DateTime(v.year, v.month, v.day, _hour24, _minute));
    setState(() {});
  }

  String _display(DateTime v) {
    final ampm = v.hour < 12 ? '오전' : '오후';
    final h12 = v.hour == 0 ? 12 : (v.hour > 12 ? v.hour - 12 : v.hour);
    final mm = v.minute.toString().padLeft(2, '0');
    return '${v.year}년 ${v.month}월 ${v.day}일 $ampm $h12:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.value;
    final hasDate = v != null;
    return TapRegion(
      // 캘린더가 열린 상태에서 바깥(다른 필드/빈 영역)을 누르면 닫는다.
      onTapOutside: (_) {
        if (_open) setState(() => _open = false);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 트리거 필드
          InkWell(
            onTap: () => setState(() => _open = !_open),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                    hasDate ? _display(v) : '날짜와 시간을 선택하세요',
                    style: TextStyle(
                      fontSize: 14,
                      color: hasDate
                          ? AppColors.textTitle
                          : const Color(0xFFA0ADB8),
                    ),
                  ),
                ),
                const Icon(LucideIcons.calendarDays,
                    size: 16, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
        if (_open) ...[
          const SizedBox(height: 6),
          _popup(hasDate),
        ],
        ],
      ),
    );
  }

  Widget _popup(bool hasDate) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x1A14387F)), // rgba(20,56,127,0.10)
        boxShadow: const [
          BoxShadow(
            color: Color(0x2414387F), // rgba(20,56,127,0.14)
            blurRadius: 24,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _calendar(),
          Container(
            height: 1,
            margin: const EdgeInsets.fromLTRB(-10, 0, -10, 12),
            color: AppColors.divider,
          ),
          _timeRow(hasDate),
          if (!hasDate)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('날짜를 먼저 선택하면 시간을 지정할 수 있어요',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFFA0ADB8))),
            ),
        ],
      ),
    );
  }

  Widget _calendar() {
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final firstDow = DateTime(_month.year, _month.month, 1).weekday % 7; // 일=0
    final rows = ((firstDow + daysInMonth) / 7).ceil();
    final today = DateTime.now();
    const dayNames = ['일', '월', '화', '수', '목', '금', '토'];

    return Column(
      children: [
        // 월 네비게이션
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navButton(LucideIcons.chevronLeft, _prev),
              Text('${_month.year}년 ${_month.month}월',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
              _navButton(LucideIcons.chevronRight, _next),
            ],
          ),
        ),
        // 요일 헤더
        Row(
          children: List.generate(7, (i) {
            final color = i == 0
                ? AppColors.danger
                : i == 6
                    ? AppColors.skyBlue
                    : AppColors.textMuted;
            return Expanded(
              child: Center(
                child: Text(dayNames[i],
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500, color: color)),
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
                return const Expanded(child: SizedBox(height: 34));
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
                              ? AppColors.skyBlue
                              : AppColors.textTitle;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _pickDate(date),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    height: 34,
                    child: Center(
                      child: Container(
                        width: 28,
                        height: 28,
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
    );
  }

  Widget _timeRow(bool hasDate) {
    return Opacity(
      opacity: hasDate ? 1 : 0.4,
      child: IgnorePointer(
        ignoring: !hasDate,
        child: Row(
          children: [
            const Text('시간',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSub)),
            const SizedBox(width: 6),
            // 오전/오후 토글
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: ['오전', '오후'].map((v) {
                    final sel = _ampm == v;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _ampm = v);
                        _emitTime();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        color: sel ? AppColors.primary : AppColors.surface,
                        child: Text(v,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                                color: sel ? Colors.white : AppColors.textSub)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 6),
            _timeDropdown<int>(
              width: 58,
              value: _hour12,
              items: List.generate(12, (i) => i + 1),
              label: (h) => '$h',
              onChanged: (h) {
                setState(() => _hour12 = h);
                _emitTime();
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(':',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSub)),
            ),
            _timeDropdown<int>(
              width: 62,
              value: _minute,
              items: List.generate(12, (i) => i * 5),
              label: (m) => m.toString().padLeft(2, '0'),
              onChanged: (m) {
                setState(() => _minute = m);
                _emitTime();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeDropdown<T>({
    required double width,
    required T value,
    required List<T> items,
    required String Function(T) label,
    required ValueChanged<T> onChanged,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.only(left: 10, right: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          isExpanded: true,
          icon: const Icon(LucideIcons.chevronDown,
              size: 13, color: AppColors.textMuted),
          style: const TextStyle(fontSize: 14, color: AppColors.textTitle),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(label(e))))
              .toList(),
          onChanged: (v) => v == null ? null : onChanged(v),
        ),
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
            border: Border.all(color: const Color(0x2614387F)),
          ),
          child: Icon(icon, size: 14, color: AppColors.primary),
        ),
      );
}
