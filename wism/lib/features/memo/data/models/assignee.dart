import 'package:freezed_annotation/freezed_annotation.dart';

part 'assignee.freezed.dart';
part 'assignee.g.dart';

/// 담당자 태그 (userData에서 선택).
@freezed
abstract class Assignee with _$Assignee {
  const factory Assignee({
    required int userId,
    required String name,
  }) = _Assignee;

  factory Assignee.fromJson(Map<String, dynamic> json) =>
      _$AssigneeFromJson(json);
}
