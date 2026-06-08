import 'package:intl/intl.dart';

String fmtDateTime(DateTime d) => DateFormat('yyyy.MM.dd HH:mm').format(d);
String fmtDate(DateTime d) => DateFormat('yyyy.MM.dd').format(d);
String fmtShort(DateTime d) => DateFormat('MM-dd HH:mm').format(d);
String fmtTime(DateTime d) => DateFormat('HH:mm').format(d);

const _weekdayKo = ['일', '월', '화', '수', '목', '금', '토'];

/// 일정 일시: "2026년 6월 8일(월) 오후 2:30"
String fmtScheduled(DateTime d) {
  final dow = _weekdayKo[d.weekday % 7];
  final ampm = d.hour < 12 ? '오전' : '오후';
  final h12 = d.hour == 0 ? 12 : (d.hour > 12 ? d.hour - 12 : d.hour);
  final mm = d.minute.toString().padLeft(2, '0');
  return '${d.year}년 ${d.month}월 ${d.day}일($dow) $ampm $h12:$mm';
}
