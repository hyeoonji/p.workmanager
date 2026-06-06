import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 환경 변수 접근 (.env). main()에서 dotenv.load() 후 사용.
abstract class Env {
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api/v1';

  /// 서버 미구축 단계에서 Mock 인증 사용 여부.
  static bool get useMockAuth =>
      (dotenv.env['USE_MOCK_AUTH'] ?? 'true').toLowerCase() == 'true';
}
