import 'package:flutter_test/flutter_test.dart';
import 'package:wism/core/constants/app_constants.dart';

void main() {
  test('메모 카테고리 5종 정의', () {
    expect(MemoCategory.all, ['일정', '이슈', '결정사항', '회의록', '기타']);
  });

  test('첨부 제약 — 10MB / 메모당 3개', () {
    expect(AttachmentLimit.maxBytes, 10 * 1024 * 1024);
    expect(AttachmentLimit.maxPerMemo, 3);
  });
}
