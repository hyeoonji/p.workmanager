/// 메모 카테고리 (계획서 1.3 / DB ENUM)
abstract class MemoCategory {
  static const schedule = '일정';
  static const issue = '이슈';
  static const decision = '결정사항';
  static const meeting = '회의록';
  static const etc = '기타';

  static const all = [schedule, issue, decision, meeting, etc];
}

/// 메모 중요도
abstract class MemoPriority {
  static const urgent = '긴급';
  static const normal = '일반';

  static const all = [normal, urgent];
}

/// 첨부 제약 (9-5 확정)
abstract class AttachmentLimit {
  static const maxBytes = 10 * 1024 * 1024; // 10MB
  static const maxPerMemo = 3;
  static const allowedExtensions = [
    'jpg', 'jpeg', 'png', 'gif',
    'pdf',
    'hwp', 'hwpx',
    'doc', 'docx',
    'ppt', 'pptx',
    'xls', 'xlsx',
  ];
}
