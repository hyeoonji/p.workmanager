import 'package:dio/dio.dart';

import '../storage/token_storage.dart';

/// 요청에 Access 토큰 첨부 + 401 시 Refresh 토큰으로 1회 재발급/재시도.
/// (Mock 인증 모드에서는 네트워크를 타지 않으므로 호출되지 않음)
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._storage, this._baseUrl);
  final TokenStorage _storage;
  final String _baseUrl;

  bool _isAuthPath(String path) =>
      path.contains('/auth/login') || path.contains('/auth/refresh');

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isAuthPath(options.path)) {
      final token = await _storage.readAccess();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final path = err.requestOptions.path;

    if (status != 401 || _isAuthPath(path) || err.requestOptions.extra['retried'] == true) {
      return handler.next(err);
    }

    final refresh = await _storage.readRefresh();
    if (refresh == null) {
      await _storage.clear();
      return handler.next(err);
    }

    try {
      // 재발급은 인터셉터가 없는 별도 Dio로 (무한루프 방지)
      final raw = Dio(BaseOptions(baseUrl: _baseUrl));
      final res = await raw.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refresh},
      );
      final newAccess = res.data!['accessToken'] as String;
      await _storage.save(access: newAccess);

      // 원 요청 재시도
      final req = err.requestOptions;
      req.headers['Authorization'] = 'Bearer $newAccess';
      req.extra['retried'] = true;
      final retry = await Dio(BaseOptions(baseUrl: _baseUrl)).fetch(req);
      return handler.resolve(retry);
    } catch (_) {
      await _storage.clear();
      return handler.next(err);
    }
  }
}
