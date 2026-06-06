import 'package:freezed_annotation/freezed_annotation.dart';

import 'assignee.dart';
import 'comment.dart';
import 'memo_project.dart';
import 'user_ref.dart';

part 'memo.freezed.dart';
part 'memo.g.dart';

/// 메모 — 앱의 핵심 단위.
@freezed
abstract class Memo with _$Memo {
  const factory Memo({
    required int id,
    required String title,
    String? content,
    @Default('일반') String priority, // 긴급 | 일반
    @Default('기타') String category, // 일정 | 이슈 | 결정사항 | 회의록 | 기타
    MemoProject? project,
    DateTime? scheduledDate,
    required UserRef author,
    @Default(<Assignee>[]) List<Assignee> assignees,
    required DateTime createdAt,
    @Default(0) int readBy,
    @Default(0) int totalReaders,
    @Default(0) int viewCount,
    @Default(0) int commentCount,
    @Default(false) bool bookmarked,
    @Default(false) bool isRead,
    @Default(<Comment>[]) List<Comment> comments,
  }) = _Memo;

  factory Memo.fromJson(Map<String, dynamic> json) => _$MemoFromJson(json);
}

extension MemoX on Memo {
  bool get isUrgent => priority == '긴급';
}
