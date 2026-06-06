import 'package:flutter/material.dart';

/// WISM 디자인 토큰 (a.Design/02Main 기준, 계획서 4.2)
abstract class AppColors {
  // 브랜드
  static const primary = Color(0xFF14387F); // 네이비

  // 배경 / 표면
  static const background = Color(0xFFF5F7FA);
  static const surface = Color(0xFFFFFFFF);

  // 텍스트
  static const textTitle = Color(0xFF1A2332);
  static const textBody = Color(0xFF2D3A4D);
  static const textSub = Color(0xFF5A6B82);
  static const textMuted = Color(0xFF8A97A8);

  // 입력 보더
  static const border = Color(0xFFE5E9EF);
  static const borderFocus = primary;

  // 카테고리
  static const catSchedule = Color(0xFF2B9CD8); // 일정
  static const catIssue = Color(0xFFD92D20); // 이슈
  static const catDecision = Color(0xFF2E7D52); // 결정사항
  static const catMeeting = Color(0xFF6B5B95); // 회의록
  static const catEtc = Color(0xFF8A97A8); // 기타

  // 긴급 / 위험
  static const danger = Color(0xFFD92D20);
  static const dangerBg = Color(0xFFFEE2E2);

  /// 카테고리명 → 색
  static Color category(String name) => switch (name) {
        '일정' => catSchedule,
        '이슈' => catIssue,
        '결정사항' => catDecision,
        '회의록' => catMeeting,
        _ => catEtc,
      };
}
