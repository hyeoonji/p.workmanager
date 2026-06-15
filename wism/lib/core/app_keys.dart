import 'package:flutter/material.dart';

/// 전역 키 — BuildContext 없이 화면을 다뤄야 하는 경우(푸시 딥링크, 인앱 알림 배너)에 사용.
/// - [rootNavigatorKey]: GoRouter 루트 네비게이터. 푸시 탭 시 메모 상세로 이동할 때 사용.
/// - [scaffoldMessengerKey]: 포그라운드 수신 시 인앱 스낵바를 어느 화면에서든 띄울 때 사용.
final rootNavigatorKey = GlobalKey<NavigatorState>();
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
