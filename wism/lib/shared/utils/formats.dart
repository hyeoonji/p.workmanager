import 'package:intl/intl.dart';

String fmtDateTime(DateTime d) => DateFormat('yyyy.MM.dd HH:mm').format(d);
String fmtDate(DateTime d) => DateFormat('yyyy.MM.dd').format(d);
String fmtShort(DateTime d) => DateFormat('MM-dd HH:mm').format(d);
String fmtTime(DateTime d) => DateFormat('HH:mm').format(d);
