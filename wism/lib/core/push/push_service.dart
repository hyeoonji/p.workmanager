import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/notification/application/notification_providers.dart';
import '../app_keys.dart';
import '../config/env.dart';
import '../network/dio_client.dart';

/// 백그라운드/종료 상태 메시지 핸들러 — 반드시 최상위 함수.
/// notification 페이로드는 OS가 자동으로 알림(트레이)에 표시하므로 여기선 별도 처리 없음.
/// 탭 처리는 onMessageOpenedApp / getInitialMessage 에서 한다.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

final pushServiceProvider = Provider<PushService>((ref) {
  return PushService(ref);
});

/// FCM 토큰을 서버(`/devices`)에 등록/해제하고 수신·탭 리스너를 건다.
/// - 로그인 직후·자동로그인 시 [registerToken]
/// - 로그아웃 시 [unregister]
class PushService {
  PushService(this._ref);
  final Ref _ref;
  final FirebaseMessaging _fm = FirebaseMessaging.instance;

  Dio get _dio => _ref.read(dioProvider);

  String? _lastToken;
  bool _listenersReady = false;

  String get _platform =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

  /// 권한 요청 + 토큰 등록 + 갱신/수신/탭 리스너 설정. 실패해도 앱 흐름은 막지 않는다.
  Future<void> registerToken() async {
    if (Env.useMockAuth) return; // Mock 모드엔 서버가 없음
    try {
      // 1) 권한 요청 (iOS + Android 13+ POST_NOTIFICATIONS)
      await _fm.requestPermission();

      // 2) 토큰 획득 → 서버 등록
      final token = await _fm.getToken();
      if (token != null) {
        await _sendToken(token);
        _lastToken = token;
      }

      // 3) 리스너 (1회만 등록)
      if (!_listenersReady) {
        // 토큰 갱신 시 재등록
        _fm.onTokenRefresh.listen((t) async {
          _lastToken = t;
          await _sendToken(t);
        });

        // 포그라운드 수신: 알림 목록/뱃지만 조용히 갱신(스낵바 팝업은 띄우지 않음).
        FirebaseMessaging.onMessage.listen((m) {
          _refreshNotifications();
        });

        // 백그라운드 상태에서 트레이 알림을 탭해 앱으로 진입 → 메모로 이동.
        FirebaseMessaging.onMessageOpenedApp.listen(_openFromMessage);

        // 종료(terminated) 상태에서 알림 탭으로 앱이 시작된 경우.
        final initial = await _fm.getInitialMessage();
        if (initial != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _openFromMessage(initial);
          });
        }

        _listenersReady = true;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[push] registerToken 실패: $e');
    }
  }

  /// 알림 목록·미확인 뱃지를 새로고침(서버 재조회).
  void _refreshNotifications() {
    _ref.invalidate(notificationsProvider);
    _ref.invalidate(unreadCountProvider);
  }

  void _openFromMessage(RemoteMessage m) {
    final memoId = int.tryParse(m.data['memoId'] ?? '');
    if (memoId != null) _openMemo(memoId);
  }

  void _openMemo(int memoId) {
    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null) return;
    ctx.push('/memo/$memoId');
  }

  Future<void> _sendToken(String token) async {
    await _dio.post(
      '/devices',
      data: {'fcmToken': token, 'platform': _platform},
    );
  }

  /// 로그아웃 시: 서버에서 토큰 해제 + 로컬 토큰 삭제.
  Future<void> unregister() async {
    if (Env.useMockAuth) return;
    try {
      final token = _lastToken ?? await _fm.getToken();
      if (token != null) {
        await _dio.delete('/devices/${Uri.encodeComponent(token)}');
      }
      await _fm.deleteToken();
      _lastToken = null;
    } catch (e) {
      if (kDebugMode) debugPrint('[push] unregister 실패: $e');
    }
  }
}
