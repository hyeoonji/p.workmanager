import 'package:flutter/material.dart';

/// WISM 디자인 토큰 (a.Design/03Main · globals.css 기준, 스펙 docs/WISM_디자인_스펙_03Main.md)
///
/// 색상은 두 축으로 구분된다:
///  1) **도트/바 색** (`catSchedule`/`catIssue`/… + [category]) — 대시보드·캘린더의 점·좌측 바.
///     하늘/빨강/초록/보라/회색 축. (이슈 = 빨강 `#D92D20`)
///  2) **배지 색** (`categoryBadgeFg`/`categoryBadgeBg`) — 카드/상세의 칩 배지.
///     일정=네이비, 이슈=주황 `#D9822B`. **빨강은 '긴급' 배지에만.**
abstract class AppColors {
  // ── 브랜드 ──
  static const primary = Color(0xFF14387F); // 네이비
  static const primaryDark = Color(0xFF0F2A5E); // 그라데이션 끝(스플래시/로그인)

  // ── 배경 / 표면 ──
  static const background = Color(0xFFF5F7FA);
  static const surface = Color(0xFFFFFFFF);

  // ── 텍스트 ──
  static const textTitle = Color(0xFF1A2332);
  static const textBody = Color(0xFF2D3A4D);
  static const textSub = Color(0xFF5A6B82);
  static const textMuted = Color(0xFF8A97A8);
  static const iconInactive = Color(0xFFAAB4C8); // 비활성 탭·북마크 빈상태

  // ── 보더 / 구분선 ──
  static const border = Color(0x1F14387F); // 입력 기본 = 디자인 border(navy 12%)
  static const borderFocus = primary; // 입력 포커스
  static const cardBorder = Color(0x1414387F); // rgba(20,56,127,0.08) = borderSoft
  static const divider = Color(0xFFEEF1F5); // 카드 내부 구분선

  // ── 포인트 / 상태 ──
  static const skyBlue = Color(0xFF2B9CD8); // 포커스 링·하늘색 포인트
  static const buttonDisabled = Color(0xFFA0AEC0);
  static const checkboxBorder = Color(0xFFD1D9E6);
  static const toggleOff = Color(0xFFD1D8E0);

  // ── 도트/바 카테고리 색 (축 1) ──
  static const catSchedule = Color(0xFF2B9CD8); // 일정
  static const catIssue = Color(0xFFD92D20); // 이슈
  static const catDecision = Color(0xFF2E7D52); // 결정사항
  static const catMeeting = Color(0xFF6B5B95); // 회의록
  static const catEtc = Color(0xFF8A97A8); // 기타

  // ── 긴급 / 위험 (빨강) ──
  static const danger = Color(0xFFD92D20);
  static const dangerBg = Color(0xFFFEE4E2);

  /// 카테고리명 → 도트/바 색 (축 1).
  static Color category(String name) => switch (name) {
        '일정' => catSchedule,
        '이슈' => catIssue,
        '결정사항' => catDecision,
        '회의록' => catMeeting,
        _ => catEtc,
      };

  // ── 배지 색 (축 2) ──
  /// 카테고리 배지 글자색.
  static Color categoryBadgeFg(String name) => switch (name) {
        '일정' => const Color(0xFF14387F),
        '이슈' => const Color(0xFFD9822B),
        '결정사항' => const Color(0xFF2E7D52),
        '회의록' => const Color(0xFF6B5B95),
        _ => const Color(0xFF5A6B82), // 기타
      };

  /// 카테고리 배지 배경색.
  static Color categoryBadgeBg(String name) => switch (name) {
        '일정' => const Color(0xFFE8F1FB),
        '이슈' => const Color(0xFFFEF3E2),
        '결정사항' => const Color(0xFFE6F4EA),
        '회의록' => const Color(0xFFEEEAF6),
        _ => const Color(0xFFEEF1F5), // 기타
      };

  // 긴급 배지
  static const urgentFg = Color(0xFFD92D20);
  static const urgentBg = Color(0xFFFEE4E2);

  // 프로젝트 배지
  static const projectBadgeFg = Color(0xFF5A6B82);
  static const projectBadgeBg = Color(0xFFF5F7FA);
  static const projectBadgeBorder = Color(0xFFD1D9E6);
}
