import 'package:freezed_annotation/freezed_annotation.dart';

import 'app_user.dart';

part 'login_response.freezed.dart';
part 'login_response.g.dart';

/// POST /auth/login 응답.
@freezed
abstract class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    required AppUser user,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}
