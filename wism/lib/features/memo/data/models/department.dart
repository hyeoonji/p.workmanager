import 'user_ref.dart';

/// 부서 + 소속 멤버 (작성 시 '부서 단위 추가'용).
class Department {
  const Department({required this.name, required this.members});

  final String name;
  final List<UserRef> members;

  factory Department.fromJson(Map<String, dynamic> json) => Department(
        name: json['name'] as String,
        members: (json['members'] as List<dynamic>)
            .map((e) => UserRef.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
