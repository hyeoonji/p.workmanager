package com.wintek.wism.ui.theme

import androidx.compose.ui.graphics.Color

// ============================================
// WISM Color Chart
// 모든 색상은 여기서 정의, 화면에서는 import해서 사용
// 새 색상이 필요하면 여기에 추가, 하드코딩 금지
// 출처: Figma Proto (a.Design/Proto/src/styles/globals.css)
// ============================================

// ── 배경색 (Background) ──
val Background = Color(0xFFFFFFFF)           // 앱 전체 배경, 카드 배경
val Surface = Color(0xFFF3F4F6)              // 아이템 배경, 호버 상태
val InputBackground = Color(0xFFF3F3F5)      // 입력 필드 배경
val Muted = Color(0xFFECECF0)               // 비활성 영역 배경

// ── 글자색 (Text) ──
val TextPrimary = Color(0xFF030213)          // 메인 텍스트 (제목, 본문)
val TextSecondary = Color(0xFF717182)        // 보조 텍스트 (날짜, 메타 정보)
val TextOnPrimary = Color(0xFFFFFFFF)        // 포인트색 위 텍스트 (버튼 글자 등)

// ── 포인트색 (Brand) ──
val Primary = Color(0xFF7C3AED)              // 브랜드 보라 (버튼, 활성 탭, 링크)
val PrimaryLight = Color(0xFFEDE9FE)         // 보라 연한 배경 (선택 상태, 배지 배경)

// ── 긴급 (Urgent) ──
val Urgent = Color(0xFFF97316)               // 긴급 주황 (배지, 아이콘)
val UrgentLight = Color(0xFFFFF7ED)          // 긴급 연한 배경
val UrgentBorder = Color(0x4DF97316)         // 긴급 카드 테두리 (30%)

// ── 상태색 (Semantic) ──
val Destructive = Color(0xFFD4183D)          // 삭제, 위험 액션
val Success = Color(0xFF22C55E)              // 확인 완료, 성공

// ── 테두리 / 구분선 ──
val Border = Color(0x1A000000)               // 기본 테두리 (rgba 0,0,0,0.1)
val SwitchBackground = Color(0xFFCBCED4)     // 스위치 비활성 배경

// ── 카테고리 컬러 ──
val CategorySchedule = Color(0xFF3B82F6)     // 파랑 - 일정
val CategoryIssue = Color(0xFFEF4444)        // 빨강 - 이슈
val CategoryDecision = Color(0xFF8B5CF6)     // 보라 - 결정사항
val CategoryMeeting = Color(0xFF22C55E)      // 초록 - 회의록
val CategoryOther = Color(0xFF6B7280)        // 회색 - 기타

// ── 알림 타입 컬러 (카테고리와 겹치면 재사용) ──
val NotificationComment = Color(0xFF3B82F6)  // 파랑 - 댓글 (= CategorySchedule)
val NotificationStatus = Color(0xFF22C55E)   // 초록 - 확인완료 (= Success)
// 멘션 = Primary, 긴급 = Urgent 그대로 사용
