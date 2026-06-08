# WISM 디자인 스펙 — 03Main 기준 (Flutter 매칭용)

> 출처: `a.Design/03Main/src/app/components/*` (App.tsx가 실제 렌더하는 컴포넌트가 기준).
> `src/imports/*`(HomeV2·CreateATaskV3·TaskAlenderV2)는 Figma 원본 export이며, 정제본인 `components/`가 **단일 소스 오브 트루스**.
> 02Main 대비 핵심 변경: **일정에 시간(scheduledTime) 추가**, **이슈 색상 빨강→주황**, **빨강은 '긴급' 배지에만**.

---

## 0. 전체 페이지 · 팝업 인벤토리 (전부)

### 풀스크린 (앱 상태 3 + 탭 5)
| # | 화면 | 컴포넌트 | Flutter 현재 파일 |
| --- | --- | --- | --- |
| P-00 | 스플래시 | `SplashScreen.tsx` | `auth/presentation/splash_screen.dart` |
| P-01 | 로그인 | `LoginScreen.tsx` | `auth/presentation/login_screen.dart` |
| P-02 | 메인 셸(헤더+탭바+FAB) | `App.tsx`+`MobileHeader`+`MobileTabBar`+`FloatingActionButton` | `app/main_shell.dart` |
| P-02a | 홈(대시보드) | `screens/HomeScreen`→`Dashboard.tsx` | `memo/presentation/home_screen.dart` |
| P-02b | 전체 메모 | `screens/AllMemosScreen`→`MemoList.tsx` | `memo/presentation/all_memos_screen.dart` |
| P-02c | 내 메모 | `screens/MyMemosScreen`→`MemoList` | `memo/presentation/my_memos_screen.dart` |
| P-02d | 북마크 | `screens/BookmarksScreen`→`MemoList` | `memo/presentation/bookmarks_screen.dart` |
| P-02e | 프로필/설정 | `screens/ProfileScreen.tsx` | `profile/presentation/profile_screen.dart` |

### 오버레이 · 팝업 · 모달 (전부)
| # | 팝업 | 컴포넌트 | 유형 | Flutter 현재 파일 |
| --- | --- | --- | --- | --- |
| O-1 | 메모 작성/수정 | `MemoForm.tsx` | 중앙 모달 | `memo/presentation/write_memo_sheet.dart` |
| O-2 | 날짜·시간 피커 | `DatePickerCalendar.tsx` | O-1 내부 인라인 팝업 | `memo/presentation/widgets/wism_date_picker.dart` |
| O-3 | 메모 상세 | `MemoDetailPage.tsx` | 풀스크린 | `memo/presentation/memo_detail_page.dart` |
| O-3a | └ 더보기 메뉴(수정/삭제) | `MemoDetailPage` 내부 | 드롭다운 | (상세 내부) |
| O-3b | └ 삭제 확인 | `MemoDetailPage` 내부 | 중앙 모달 | `shared/widgets/app_dialog.dart` |
| O-4 | 알림 패널 | `NotificationPanel.tsx` | 우측 슬라이드 드로어 | `notification/presentation/notification_panel.dart` |
| O-5 | 프로필 편집 | `ProfileEditModal.tsx` | 바텀시트 | `profile/presentation/profile_edit_sheet.dart` |
| O-6 | 캘린더 | `CalendarModal.tsx` | 풀스크린 모달 | `calendar/presentation/calendar_page.dart` |
| O-7 | 정렬 메뉴 | `MemoList.tsx` 내부 | 드롭다운 | (목록 내부) |
| O-8 | 토스트 | `App.tsx` 내부 | 하단 알약 | (전역) |

### 재사용 컴포넌트
`MemoCard` · `BadgeTokens`(CategoryBadge/UrgentBadge/ProjectBadge) · `MobileHeader` · `MobileTabBar` · `FloatingActionButton`

---

## 1. 공통 디자인 토큰 (globals.css 기준 — 가장 먼저 정리)

### 색상
| 토큰 | 값 |
| --- | --- |
| primary(네이비) | `#14387F` / 진한 네이비(그라데이션 끝) `#0F2A5E` |
| 배경 | `#F5F7FA` |
| 카드/표면 | `#FFFFFF` |
| 제목(title) | `#1A2332` |
| 본문 | `#2D3A4D` |
| 보조 텍스트 | `#5A6B82` |
| 흐린 텍스트(muted) | `#8A97A8` (일부 `#8A94A6`) |
| 비활성 아이콘/탭 | `#aab4c8` |
| 입력 보더(기본) | `#E5E9EF` |
| 입력 보더(포커스) | `#14387F` |
| 카드 보더 | `rgba(20,56,127,0.08)` |
| 구분선 | `#EEF1F5` |
| 포커스 링/하늘색 | `#2B9CD8` |
| 비활성 버튼 배경 | `#A0AEC0` |
| 체크박스 미선택 보더 | `#D1D9E6` |
| 토글 OFF 배경 | `#D1D8E0` |

### 배지 (★ 변경점)
| 카테고리 | 배경(bg) | 글자(fg) |
| --- | --- | --- |
| 일정 | `#E8F1FB` | `#14387F` ★(하늘→네이비) |
| 이슈 | `#FEF3E2` | `#D9822B` ★(빨강→주황) |
| 결정사항 | `#E6F4EA` | `#2E7D52` |
| 회의록 | `#EEEAF6` | `#6B5B95` |
| 기타 | `#EEF1F5` | `#5A6B82` |
| **긴급** | `#FEE4E2` | `#D92D20` ★(빨강은 여기에만) |
| 프로젝트 태그 | `#F5F7FA` | `#5A6B82` / border `#D1D9E6` |

배지 공통: `padding 2px 8px(px-2 py-0.5)`, `radius 6px`, `fontSize 12px`, `fontWeight 500(medium)`, `line-height 18px`, `whitespace nowrap`.
프로젝트 배지는 `uppercase + tracking-wide`.

### 카테고리 "색상 점/바" 용 컬러 (대시보드·캘린더 도트, 좌측 바)
일정 `#2B9CD8` · 이슈 `#D92D20` · 결정사항 `#2E7D52` · 회의록 `#6B5B95` · 기타 `#8A97A8`
→ ※ 도트/바는 하늘·빨강 계열 사용(배지 글자색과 별개 축). 긴급 메모는 도트/바에서 "이슈" 색(`#D92D20`)으로 표기.

### 라운드 / 그림자
- radius: 카드 16px / 입력·버튼 8px / 칩·배지 6px / 작은팝업 10~12px / FAB·아바타 원형
- 카드 그림자: `0 1px 4px rgba(20,56,127,0.06)` (shadow-sm)
- FAB 그림자: `0 4px 16px rgba(20,56,127,0.35)`
- 탭바 그림자(상단): `0 -2px 8px rgba(20,56,127,0.08)`
- 모달 그림자: `0 8px 40px rgba(0,0,0,0.18)`
- 드로어 그림자: `-4px 0 24px rgba(0,0,0,0.14)`

### 아이콘 매핑 (lucide → `lucide_icons_flutter`)
> 패키지 `lucide_icons_flutter ^3.1.14`. import `package:lucide_icons_flutter/lucide_icons.dart`, 사용 `LucideIcons.xxx`. 기본 stroke-width 2(폰트패밀리 Lucide). 디자인이 strokeWidth 2.5인 곳(탭 활성 아이콘·FAB Plus)은 굵은 변형이 없으므로 동일 아이콘 사용(차이 미미).

| lucide | 용도 | LucideIcons |
| --- | --- | --- |
| Shield | 스플래시/로그인 로고 | `LucideIcons.shield` |
| Bell | 헤더 알림, 긴급, 푸시설정, mention | `LucideIcons.bell` |
| User | 로그인ID, 프로필탭, 빈 아바타 | `LucideIcons.user` |
| Lock | 로그인 PW | `LucideIcons.lock` |
| Eye / EyeOff | PW 표시토글, 카드 조회수 | `LucideIcons.eye` / `LucideIcons.eyeOff` |
| Home | 탭-홈 | `LucideIcons.house` |
| FileText | 탭-전체, 내메모카드, 최근, 통계 | `LucideIcons.fileText` |
| BookOpen | 탭-내메모 | `LucideIcons.bookOpen` |
| Bookmark / BookmarkCheck | 탭-북마크, 카드북마크 | `LucideIcons.bookmark` / `LucideIcons.bookmarkCheck` |
| Plus | FAB | `LucideIcons.plus` |
| Calendar / CalendarDays | 오늘통계, 주간일정, 일정칩, 피커 | `LucideIcons.calendar` / `LucideIcons.calendarDays` |
| ChevronRight/Left | 전체보기, 월이동 | `LucideIcons.chevronRight` / `LucideIcons.chevronLeft` |
| ChevronDown | 정렬, 셀렉트 | `LucideIcons.chevronDown` |
| Search | 검색바 | `LucideIcons.search` |
| MessageSquare | 카드 댓글수, 댓글빈상태, 통계 | `LucideIcons.messageSquare` |
| X | 닫기, 태그삭제 | `LucideIcons.x` |
| ArrowLeft | 상세/캘린더 뒤로 | `LucideIcons.arrowLeft` |
| MoreVertical | 상세 더보기 | `LucideIcons.moreVertical` |
| CheckCircle | 읽음확인, 확인완료 | `LucideIcons.checkCircle` |
| Send | 댓글 전송 | `LucideIcons.send` |
| Mail / Phone | 프로필 이메일/전화 | `LucideIcons.mail` / `LucideIcons.phone` |
| Pencil | 프로필 편집 | `LucideIcons.pencil` |
| MessageCircle | 알림-댓글 | `LucideIcons.messageCircle` |
| AlertCircle | 알림-긴급 | `LucideIcons.alertCircle` |
| LogOut | 로그아웃 | `LucideIcons.logOut` |
| Info | 버전정보 | `LucideIcons.info` |
| Camera | 프로필사진변경 | `LucideIcons.camera` |

---

## 2. P-00 스플래시 (`SplashScreen`)
- 배경: 세로 그라데이션 `#14387F → #0F2A5E` (180deg). 전체화면.
- 중앙 콘텐츠 col, gap 20px:
  - 아이콘 박스: 88×88, radius 20, bg `rgba(255,255,255,0.15)`, shadow `0 8px 32px rgba(0,0,0,0.25)`. 안에 Shield 44×44 흰색.
  - 브랜드 col gap 6px: "WISM" 40px / w700 / 흰색 / letterSpacing 0.06em / lineHeight 1. 아래 "Wintek Insight System Manager" 13px / w500 / `#A8B5C8` / letterSpacing 0.02em.
- 하단(절대배치, bottom safe-area 또는 40px) col gap 14px:
  - 스피너 24×24 (회전), 트랙 `rgba(255,255,255,0.25)`, 진행 `rgba(255,255,255,0.75)`, strokeWidth 2.5.
  - "© 2026 Wintek Corp." 12px `#8A97A8`.
- 자동 전환: 2200ms 후 로그인.

## 3. P-01 로그인 (`LoginScreen`)
- 상단 네이비 영역: height 35vh(min 220px), 그라데이션 `#14387F→#0F2A5E`, 가운데 정렬 col gap 14px, paddingTop safe-area(44).
  - 아이콘 박스 64×64 radius16 bg `rgba(255,255,255,0.15)` shadow `0 4px 16px rgba(0,0,0,0.2)`, Shield 32×32 흰색.
  - "WISM" 28px w700 흰색 letterSpacing0.06em / 보조 12px w500 `#A8B5C8`.
  - ⚠️ **Flutter 의도적 차이(유지)**: 로그인 로고는 방패 박스 대신 **앱 아이콘 이미지(`assets/icon/wism_icon.png`) 96×96 radius20**를 쓰고, 별도 WISM 워드마크 텍스트 없음(이미지가 브랜드 마크). 사번 라벨은 "사번"(제품 사양). 되돌리지 말 것. ※ 스플래시는 방패 아이콘 유지.
- 하단 흰색 시트: flex1, radius `20 20 0 0`, padding `32px 20px 0`.
  - "로그인" 18px w700 `#1A2332`. 폼 col gap 20px.
  - 라벨: 13px w500 `#1A2332`, 라벨-입력 gap 6px.
  - 입력박스: 흰배경, border 1px `#E5E9EF`(포커스 `#14387F`), radius10, padding `11px 12px`, 내부 row gap10. 아이콘 16×16(`#8A97A8`, 포커스 `#14387F`). 입력 텍스트 14px `#1A2332`.
  - PW 우측 Eye/EyeOff 16×16 `#8A97A8`.
  - 자동 로그인 체크박스: 18×18 radius5 border 2px(`#D1D9E6`, 체크시 `#14387F`+흰체크). 라벨 13px `#5A6B82` w500.
  - 로그인 버튼: width100%, padding13, radius10, bg `#14387F`(비활성 `#A0AEC0`), 흰글자 15px w700.
  - 푸터: "Wintek Corp. 임직원 전용 시스템입니다" 12px `#8A97A8` 가운데, padding `20px 20px safe-area(24)`.

## 4. P-02 메인 셸

### MobileHeader (상단, fixed)
- bg `#14387F`, z40, shadow-md.
- 상태바 여백 height 44(h-11). 본문 height 56(h-14), padding x16.
- 제목: 18px **bold** 흰색. 우측 알림버튼 패딩8 원형(hover white/10). Bell 20×20(h-5 w-5) 흰색.
- 배지: 우상단 -2/-2, min-w 18 h18, bg `#ef4444`, 흰글자 10px, 원형, 9 초과시 "9+".
- ※ App.tsx에서 main에 `pt-[100px] pb-[96px] px-4`, 내부 `max-w-2xl mx-auto py-4`.

### MobileTabBar (하단, fixed)
- bg 흰색, 상단 border `rgba(20,56,127,0.1)`, z50, shadow `0 -2px 8px rgba(20,56,127,0.08)`.
- row height 64(h-16) px2, 탭 5개 균등. 아이콘 20×20(h-5 w-5), 라벨 12px(text-xs).
- 활성 `#14387F`(아이콘 strokeWidth 2.5), 비활성 `#aab4c8`. 아이콘-라벨 gap 4(gap-1).
- 하단 제스처 여백 height 16(h-4) 흰배경.
- 탭: 홈(Home) · 전체(FileText) · 내 메모(BookOpen) · 북마크(Bookmark) · 프로필(User).

### FloatingActionButton
- fixed bottom 100, right 16. 56×56(h-14 w-14) 원형 bg `#14387F`(hover `#0f2a5e`, active scale0.95). shadow `0 4px 16px rgba(20,56,127,0.35)`. Plus 24×24 흰색 strokeWidth2.5.
- 표시 조건: dashboard/all/my 탭에서만.

## 5. P-02a 홈 대시보드 (`Dashboard`) — 카드 간 space-y-4(16px)
1. **통계 카드 3개** (grid 3, gap12):
   - 카드 공통: 흰배경, radius16, padding `16px 8px`, shadow `0 1px 4px rgba(20,56,127,0.06)`, border `1px rgba(20,56,127,0.08)`, col 가운데 gap6, active scale0.96.
   - 원형 아이콘박스 40×40(w-10 h-10): 긴급 bg`#FEE2E2`+Bell`#D92D20` / 오늘 bg`#EBF3FB`+Calendar`#2B9CD8` / 내메모 bg`#EBF5EE`+FileText`#22a85a`.
   - 숫자 26px w700 (긴급 `#D92D20`, 나머지 `#14387F`) lineHeight1. 라벨 13px w500 `#5A6B82`.
   - 동작: 긴급→전체메모(긴급필터) / 오늘→캘린더 / 내메모→내메모탭.
2. **미확인 긴급 이슈 카드** (unreadUrgent>0일 때만): 흰카드 radius16 border.
   - 헤더 row padding `px4 pt4 pb3`, 하단 border `rgba(20,56,127,0.06)`: Bell 16×16 `#ef4444` + "미확인 긴급 이슈" 14px w600 `#1A2332` + 우측 카운트 알약(bg`#FEE2E2` `#ef4444` 12px px2 py0.5 round-full).
   - 항목(최대 3, divide-y): row gap12 padding `px4 py3`, hover `#FFF5F5`. 좌측 점 6×6(w-1.5)`#ef4444` mt2. 배지행(UrgentBadge+CategoryBadge gap6). 제목 14px w600 `#1A2332` 1줄. 작성자 12px `#8A97A8`.
3. **이번 주 일정 카드**: 흰카드 radius16 border.
   - 헤더 row `px4 pt4 pb3`: Calendar 16×16 `#2B9CD8` + "이번 주 일정" 14px w600 `#1A2332` flex1 + "캘린더 전체보기" 13px `#2B9CD8` + ChevronRight 14×14 `#2B9CD8`.
   - 주간 스트립 grid7 `px3 pb3 gap0.5`: 각 셀 col gap2 padding `6px 2px` radius10.
     - 요일 라벨 12px (일`#D92D20`/토`#2B9CD8`/평일`#8A97A8`).
     - 숫자 원 32×32: 오늘 bg`#14387F`(숫자 흰), 선택(비오늘) border 2px`#14387F`(숫자`#14387F`), 평일`#1A2332`. 숫자 15px w500.
     - 도트(최대2) 원 하단 absolute bottom3: 4×4 원, 카테고리색(선택/오늘이면 흰색).
   - 구분선 height1 `#EEF1F5` margin x16.
   - 선택일 리스트: 항목 row, 좌측 바 width4 카테고리색(긴급이면`#D92D20`), 내용 padding `10px 14px`, 상단 border `rgba(20,56,127,0.04)`. 제목 14px w600 `#1A2332` 1줄, 우측 긴급칩(11px `#D92D20`/`#FEE4E2` radius6 px6 py2). meta(time·author) 12px `#8A97A8` mt2. 빈상태 "이 날짜에 등록된 일정이 없습니다" 14px `#8A97A8` py7 가운데.
4. **최근 업데이트 카드**: 헤더 FileText 16×16 `#14387F` + "최근 업데이트" 14px w600. 항목(최대3, divide-y) row gap12 `px4 py3`: 점 6×6(긴급`#ef4444`/일반`#14387F`) mt2, 제목 14px w600 `#1A2332` 1줄, 작성자·시간 12px `#8A97A8`, 우측 긴급이면 UrgentBadge.

## 6. P-02b/c/d 메모 목록 (`MemoList`) — space-y-3(12px)
- **검색바**: relative. Search 16×16(w-4) `#aab4c8` 좌측 absolute left14. input full, pl40 pr16 py2.5, 흰배경 border 1px`rgba(20,56,127,0.12)` radius12(xl), 텍스트 14px `#1A2332`, placeholder `#aab4c8`, 포커스 border`#2B9CD8`+ring.
- **카테고리 탭**(가로스크롤 gap8): 칩 `px4 py1.5` round-full 12px w500. 선택 bg`#14387F` 흰글자 shadow-sm / 미선택 흰배경 `#5A6B82` border `rgba(20,56,127,0.15)`. 목록: 전체/긴급/일정/이슈/결정사항/회의록/기타.
- **건수+정렬 행**: "총 N건" 13px `#5A6B82` / 우측 정렬버튼 13px `#5A6B82` + ChevronDown 14×14.
  - 정렬 드롭다운(O-7): absolute right0 top6(24px), 흰배경 border`rgba(20,56,127,0.12)` radius12 shadow-lg, minWidth90. 항목 `px4 py2.5` 13px, 선택시 bg`#EBF3FB` `#14387F`. 옵션: 최신순/오래된순/긴급순.
- **목록**(space-y-2.5): MemoCard. 빈상태 "항목이 없습니다" `#aab4c8` text-sm py16 가운데.

### MemoCard (재사용)
- 흰배경 radius12(xl) shadow-sm border `rgba(20,56,127,0.08)`, active scale0.98, overflow hidden. 내부 padding16.
- row(start, gap2): 좌측 flex1.
  - 배지행 mb2.5(10px) gap1.5 flex-wrap: [긴급] CategoryBadge [ProjectBadge].
  - 제목 16px w600 `#1A2332` lineHeight1.4, 2줄 클램프, mb2.
  - 본문 미리보기(있으면) 14px w400 `#5A6B82` lineHeight1.5, 2줄, mb3.
  - 메타행 12px `#8A97A8` gap2.5: 작성자(`#5A6B82`) · time · (Eye14 + readBy) · (MessageSquare14 + 댓글수, 있을때).
  - 우측 북마크버튼 padding1.5 radius-lg hover`#F5F7FA`: BookmarkCheck 16×16`#14387F`(채움) / Bookmark 16×16`#aab4c8`.

## 7. O-1 메모 작성/수정 (`MemoForm`) — 중앙 모달
- 딤 `rgba(0,0,0,0.45)` z60. 카드 z61 가운데, width `min(95vw,480px)`, maxHeight 88vh, 흰배경 radius16 shadow `0 8px 40px rgba(0,0,0,0.18)`.
- **헤더** padding `18px 20px 14px`, 하단 border`#EEF1F5`: 타이틀 17px w700 `#1A2332`("새 메모 작성"/"메모 수정") + 닫기버튼 28×28 원형 bg`#F5F7FA`, X 15×15 `#5A6B82`.
- **스크롤 본문** padding20 col gap16:
  - 공통 라벨: 13px w500 `#1A2332` mb6. 공통 필드: 흰배경 border1px`#E5E9EF`(포커스`#14387F`) radius8 padding `10px 12px` 14px `#1A2332`.
  - 제목 입력.
  - 중요도/카테고리 grid2 gap12 — Select(우측 ChevronDown 16×16 `#5A6B82` absolute right10). 중요도: 일반/긴급. 카테고리: 일정/이슈/결정사항/회의록/기타.
  - **(카테고리=일정일 때만) "일정 일시"** → `DatePickerCalendar`(O-2).
  - 프로젝트 입력.
  - 내용 textarea rows5 lineHeight1.5 resize none.
  - 담당자 태그: row gap8 [입력 flex1][추가버튼 padding`0 14px` radius8 border`#E5E9EF` bg`#F5F7FA` `#5A6B82` 13px w500]. 칩(mt8 gap6): bg`#E8F1FB` `#14387F` 12px w500 radius6 padding`3px 8px`, 우측 X 11×11.
- **하단 버튼** padding `14px 20px` 상단border`#EEF1F5` gap10: [취소 flex1 padding11 radius8 border`#E5E9EF` bg`#F5F7FA` `#5A6B82` 14px w500][저장 flex1 bg`#14387F`(비활성`#A0AEC0`) 흰글자 14px w600].
- 제출 가능: 제목 必 + (카테고리≠일정 또는 일정날짜 있음).

## 8. O-2 날짜·시간 피커 (`DatePickerCalendar`) ★신규 시간 기능
- **트리거 버튼**: full, row(between), 흰배경 border1px`#E5E9EF`(open시`#14387F`) radius8 padding`10px 12px` 14px. 텍스트(`#1A2332`, 미선택 `#A0ADB8`) "YYYY년 M월 D일 오전/오후 h:mm" 또는 "날짜와 시간을 선택하세요". 우측 CalendarDays 16×16 `#8A97A8`.
- **팝업**(absolute top calc(100%+6px), left0 right0): 흰배경 radius12 shadow `0 4px 24px rgba(20,56,127,0.14)` border `rgba(20,56,127,0.10)` z200, padding `12px 10px 14px`.
  - 월 네비 row(between) mb10: 좌우 버튼 28×28 원형 border`rgba(20,56,127,0.15)` bg`#F5F7FA`, Chevron 14×14 `#14387F`. 가운데 "YYYY년 M월" 15px w700 `#14387F`.
  - 요일헤더 grid7: 12px w500 (일`#D92D20`/토`#2B9CD8`/평일`#8A97A8`).
  - 날짜셀 height34: 원 28×28(선택 bg`#14387F`/오늘 bg`#E8F1FB`/그외 투명). 숫자 13px w500 (선택 흰/오늘`#14387F`/일`#D92D20`/토`#2B9CD8`/평일`#1A2332`).
  - 구분선 height1 `#EEF1F5` margin `0 -10px 12px`.
  - **시간 섹션** row gap6 (날짜 없으면 opacity0.4+비활성):
    - "시간" 13px w500 `#5A6B82`.
    - 오전/오후 토글: border1px`#E5E9EF` radius8 overflow hidden. 각 버튼 padding`8px 10px` 13px, 활성 bg`#14387F` 흰글자 w600 / 비활성 흰배경 `#5A6B82` w400.
    - 시 select width58 / 분 select width62. selectStyle: border`#E5E9EF` radius8 padding`9px 28px 9px 10px` 14px. ChevronDown 13×13 `#8A97A8`. 가운데 ":" 14px `#5A6B82` w500.
    - HOURS=1~12, MINUTES=0,5,...,55(5분 간격).
  - 미선택 안내: "날짜를 먼저 선택하면 시간을 지정할 수 있어요" 12px `#A0ADB8` 가운데 mt8.
- 시간 변환: 오전 12시→0시, 오후 12시→12시. 표시 "오전/오후 h:mm".

## 9. O-3 메모 상세 (`MemoDetailPage`) — 풀스크린 bg`#F5F7FA`
- **앱바** bg`#14387F`: 상태바여백 44 + row height56 px2. 뒤로(ArrowLeft 20×20 흰, 패딩8 원형). 가운데 "메모 상세" 18px bold 흰. 우측: **소유자면** MoreVertical 20×20(O-3a 메뉴), 아니면 빈 36×36.
  - **O-3a 더보기 메뉴**: absolute top`calc(100%+4px)` right0, 흰배경 radius10 shadow`0 4px 20px rgba(0,0,0,0.15)` border, minWidth120. [수정 14px w500 `#1A2332` padding`12px 16px` 하단border`#EEF1F5`][삭제 14px w500 `#D92D20`].
- **본문 스크롤**(pb80) padding `px4 pt4` space-y-3:
  - **본문 카드**: 흰배경 radius16 border.
    - 상단 padding`px4 pt4 pb3` space-y-3: 배지행(긴급+카테고리+프로젝트 gap1.5). 제목 18px w600 `#1A2332` leading-snug.
    - 작성정보 row gap1.5 12px `#8A94A6`: 아바타 20×20 원형 bg`#EBF3FB`(이니셜 10px `#14387F` w600) + "{author} 작성" · "{date} {time}".
    - (scheduledDate 있으면) **일정칩**: inline bg`#E8F1FB` radius8 padding`7px 10px`, CalendarDays14`#14387F` + "일정: YYYY년 M월 D일(요일) 오전/오후 h:mm" 13px w600 `#14387F`.
    - (tags) 칩들 gap1.5: bg`#EBF3FB` `#14387F` 12px w500 radius6 px2 py0.5 "@{tag}".
    - 구분선 height1 `#EEF1F5`.
    - 본문 padding`px4 py4`: 14px w400 `#2D3A4D` lineHeight1.6 whitespace pre-wrap.
  - **읽음확인 버튼**: full row 가운데 gap2 py3 radius12. 미확인 bg`#14387F`(CheckCircle14 흰 + "읽음 확인" 14px w600 흰) / 확인완료 bg`#E6F4EA`(CheckCircle14 `#2E7D52` + "확인 완료" `#2E7D52`).
  - **댓글 섹션** space-y-3: "댓글 (N)" 14px w600 `#1A2332`.
    - 댓글 카드: 흰배경 radius12 border padding3.5 row gap3. 아바타 28×28 원형 bg`#EBF3FB`(이니셜 11px `#14387F` w600). 이름 13px w500 `#1A2332` + 시간 12px `#8A97A8` + (status면 확인완료칩: bg`#E6F4EA` `#2E7D52` 11px CheckCircle12). 내용 14px `#2D3A4D` lineHeight1.5.
    - 빈상태: 흰카드 py10 col 가운데 gap2, MessageSquare 32×32 `#D1D9E6` + "첫 번째 댓글을 남겨보세요" 14px `#8A97A8`.
- **하단 입력창**: 흰배경 상단border`rgba(20,56,127,0.1)` padding`px4 py3` row(end) gap3. 아바타 32×32 원형 bg`#EBF3FB`("관" 12px `#14387F` w600). textarea(자동높이 max120) flex1 bg`#F5F7FA` radius12 padding`px3 py2.5` border`rgba(20,56,127,0.1)`(포커스`#2B9CD8`) 14px. 전송버튼 36×36 원형 bg`#14387F`(빈값`#D1D9E6`), Send 16×16 흰.
- **O-3b 삭제 확인 모달**: 딤`rgba(0,0,0,0.45)` z60. 카드 z61 가운데 width`min(90vw,320px)` radius16 padding`24px 20px 20px` col gap8. "메모를 삭제할까요?" 17px w700 `#1A2332`. 설명 "삭제된 메모는 복구할 수 없습니다." 14px `#5A6B82` mb8. 버튼 row gap10: [취소 border`#E5E9EF` bg`#F5F7FA` `#5A6B82` w500][삭제 bg`#D92D20` 흰 w600], 각 padding11 radius8 14px.

## 10. O-4 알림 패널 (`NotificationPanel`) — 우측 드로어
- 딤 `rgba(0,0,0,0.40)` z40 (opacity 트랜지션 0.28s). 패널 width88%(max420) 흰배경 우측, shadow`-4px 0 24px rgba(0,0,0,0.14)` z50, paddingTop safe-area(44). transform translateX(open 0/닫힘 100%) 0.28s cubic-bezier(0.32,0,0.2,1).
- **헤더** height56 px16 하단border`#EEF1F5`: 좌측 "알림" 18px w700 `#1A2332` + (미읽음>0) 카운트 원 18×18 bg`#D92D20` 흰 12px. 우측 gap12: (미읽음>0) "모두 읽음" 13px `#2B9CD8` + 닫기 X 20×20 `#5A6B82`.
- **목록**: 항목 row(start) gap12 padding`14px 16px`, 미읽음 bg`#F5F9FE`/읽음 흰.
  - 아이콘 원 36×36: comment bg`#E8F1FB`/`#2B9CD8`(MessageCircle) · mention bg`#EEEAF6`/`#6B5B95`(Bell) · status bg`#E6F4EA`/`#2E7D52`(CheckCircle) · urgent bg`#FEE4E2`/`#D92D20`(AlertCircle). 아이콘 16×16.
  - 텍스트: 제목 13px w700 `#1A2332` mb2. 내용 13px `#2D3A4D` lineHeight1.4 2줄클램프. 하단 "{memoTitle} · {timestamp}" 11px `#8A97A8` mt4.
  - 우측 미읽음 점 7×7 원 `#2B9CD8` (paddingTop6).
  - 항목 구분선 height1 `#EEF1F5` marginLeft64.
- 빈상태: 가운데 Bell 40×40(opacity0.5) + "알림이 없습니다" 14px `#8A97A8`.

## 11. O-5 프로필 편집 (`ProfileEditModal`) — 바텀시트
> ※ 디자인 원본은 shadcn 컴포넌트(Input/Label/Button) 사용. Flutter는 03Main 토큰으로 매핑.
- 딤 black/50 z50. 시트: 하단 고정 bg background radius `top 3xl(24px)` maxHeight90vh col.
- 헤더 padding4 하단border: "프로필 수정"(h2=20px w500) + 닫기 X 20×20 패딩2 원형(hover accent).
- 폼 padding6 space-y-6:
  - 프로필 사진 col 가운데 gap4: 원 96×96 그라데이션 bg(primary/20→primary/5), 이미지 또는 User 48×48(primary/50). 우하단 카메라 라벨 패딩2 bg primary 흰 원형, Camera 16×16. 안내 "사진을 클릭하여 변경" text-xs muted.
  - 필드 space-y-2 ×5: 이름*/직급/부서/이메일*/전화번호*. Label + Input(shadcn). placeholder 각각 지정.
- 버튼영역 padding4 상단border sticky: row gap2 [취소 outline flex1][저장 bg primary 흰 flex1].
- ※ 계획서상 사진은 회사서버 읽기전용 → Flutter 구현 시 카메라 변경 UI는 정책에 맞게 처리(스펙은 디자인 원본 보존).

## 12. O-6 캘린더 (`CalendarModal`) — 풀스크린 bg`#F5F7FA`
- safe-area여백 bg`#14387F`. **헤더** bg`#14387F` padding`12px 16px` row gap8: 뒤로 ArrowLeft 18×18 흰(원형32×32 투명) + "캘린더" 18px w700 흰.
- 스크롤:
  - **월 네비** padding`16px 16px 8px` row(between): 좌우 32×32 원형 흰배경 border`rgba(20,56,127,0.15)` Chevron 16×16 `#14387F`. 가운데 "YYYY년 M월" 18px w700 `#14387F`.
  - **달력 카드** margin`0 16px 12px` 흰배경 radius16 border:
    - 요일헤더 grid7 padding`10px 8px 4px`: 13px w500 (일`#D92D20`/토`#2B9CD8`/평일`#8A97A8`).
    - 날짜그리드 padding`0 8px 12px`: 셀 height48 margin`1px 0`. 숫자원 30×30 absolute top4(선택 bg`#14387F`/오늘 bg`#E8F1FB`/그외 투명). 숫자 15px w500(선택 흰/오늘`#14387F`/일`#D92D20`/토`#2B9CD8`/평일`#1A2332`). 도트(최대3) absolute top38 gap2: 4×4 카테고리색(긴급→이슈색).
  - **일정 리스트** padding`0 16px 32px`:
    - 섹션헤더 row gap6 mb10: "YYYY.MM.DD 일정" 14px w600 `#1A2332` + 카운트 알약(12px `#2B9CD8`/bg`#E8F1FB` radius10 padding`1px 7px`).
    - CalendarMemoCard(gap8): 흰배경 radius12 border padding`12px 12px 12px 10px` row(center) gap10. 좌측 캡슐바 width4 height36 radius999 카테고리색. 내용: 제목 16px w600 `#1A2332` lineHeight1.4 + 우측(col, end, gap4) [긴급칩 11px `#D92D20`/`#FEE4E2` radius6 px6 py2][카테고리칩 11px 카테고리색/카테고리bg radius6 px6 py2]. meta(time·author·project) 12px `#8A97A8` mt4.
    - 빈상태 "이 날짜에 등록된 일정이 없습니다" 14px `#8A97A8` py40 가운데.
- ※ FilterChip 함수는 정의돼 있으나 현재 렌더엔 미사용(카테고리 필터 칩). 도트는 전체 메모 기준.

## 13. P-02e 프로필 (`ProfileScreen`) — space-y-5(20px)
- **1. 프로필 카드**: 흰배경 radius16 border.
  - 상단 row gap3 padding`px4 py4`: 아바타 48×48 원형 bg`#EBF3FB` `#14387F` w700 16px(이니셜 2자). 이름 16px w600 `#1A2332` + (부서·직급) 12px `#8A97A8` mt0.5. 우측 편집버튼 row gap1.5 padding`px3 py1.5` bg`#E8F1FB` radius8: Pencil 14×14`#14387F` + "편집" 13px w500 `#14387F`.
  - 구분선 height1 `#EEF1F5`.
  - 이메일 행 row gap3 padding`px4 py3`: 아이콘박스 32×32 radius-lg bg`#EBF3FB` Mail14`#14387F`. 라벨 "이메일" 11px `#8A97A8` + 값 14px `#2D3A4D`(truncate).
  - 구분선 height1 `#EEF1F5` marginLeft56.
  - 전화번호 행: 동일 구조, Phone 아이콘.
- **2. 활동 통계**: 섹션라벨 "활동 통계"(12px w500 `#8A97A8` px1 mb2). 흰카드 radius16 border row(3등분):
  - 각 col 가운데 py4 gap1.5: 원형아이콘 32×32 [내메모 bg`#EBF3FB` FileText`#14387F`][댓글 bg`#EEEAF6` MessageSquare`#6B5B95`][북마크 bg`#E6F4EA` Bookmark`#2E7D52`]. 숫자 22px w700 `#14387F` lineHeight1. 라벨 11px `#8A97A8`.
  - 세로 구분선 width1 `#EEF1F5` margin`12px 0`.
- **3. 설정**: 섹션라벨 "설정". 흰카드 radius16 border:
  - 푸시 알림 행 row gap3 padding`px4 py3.5`: 아이콘박스 32×32 radius-lg bg`#FEF3E2` Bell14 `#D9822B`. "푸시 알림" 14px `#2D3A4D` flex1. **토글** 44×24 radius12(ON bg`#14387F`/OFF bg`#D1D8E0`), 손잡이 20×20 흰 원 shadow, ON시 left22/OFF left2.
  - 구분선 height1 `#EEF1F5` marginLeft56.
  - 버전 정보 행: 아이콘박스 bg`#EEF1F5` Info14 `#5A6B82`. "버전 정보" 14px `#2D3A4D` flex1 + "v1.0.0" 13px `#8A97A8`.
- **4. 로그아웃**: 상단 구분선 height1 `#EEF1F5` mb12. 버튼 full row 가운데 gap2 py2: LogOut 14×14 `#D92D20` + "로그아웃" 14px w500 `#D92D20`.

## 14. O-8 토스트 (`App.tsx`)
- fixed bottom safe-area(24) 가운데. bg `rgba(26,35,50,0.88)` 흰글자 14px w500 padding`10px 20px` radius100(알약). z200. 예: "삭제되었습니다".

---

## 15. 현재 Flutter 대비 주요 불일치 (token 우선 정리 대상)
- `app_colors.dart`: `catIssue` 빨강 → **주황 `#D9822B`** + 배경 `#FEF3E2`. `catSchedule` 배지 글자색 하늘 → **네이비 `#14387F`**(단 도트/바는 하늘 유지). 기타 글자색 `#5A6B82`.
- `memo_badges.dart`: 이슈 배경 `#FEE4E2`(긴급색) → **`#FEF3E2`**. 프로젝트 배지 배경 `#F5F7FA` + **border `#D1D9E6`** 추가, 글자 `#5A6B82`. 일정 배지 글자 네이비.
- 화면별 아이콘·간격·박스 크기·구분선은 위 §2~§14 스펙대로 1:1 점검.
