# WISM - Wintek Insight System Manager

## 프로젝트 개요
- 회사(Wintek) 내 관리자급(팀장/임원)만 사용하는 업무 관리 모바일 앱
- 일정, 이슈, 결정사항, 회의록, 기타를 공유하는 게시판 형태
- UI 디자인: Figma 프로토타입 기반 (Proto 폴더: `C:\Shin\Organization\Wintek\1.Project\07.WISM\a.Design\Proto`)

## 기술 스택
- **플랫폼**: Android Native (Kotlin)
- **IDE**: Android Studio
- **개발 방식**: 바이브 코딩 (AI 보조 개발)
- **백엔드**: PHP REST API + MySQL (추후)
- **서버 로드맵**: 로컬 Mock 데이터 → AWS → 사내 서버 (wims.win-tek.co.kr, JSP/Servlet 기반)

## 사내 서버 정보
- URL: http://wims.win-tek.co.kr/
- 시스템: WIMS 2.0 (Wintek Information Management System), JSP/Servlet
- 로그인: POST /servlet/WSA_Login_sr (필드: H_Userid, H_Userpw, H_MenuGb, H_Mode)

## 화면 구성 (9개)
- P-01: 로그인 (Splash/Login)
- P-02: 홈 대시보드 (탭1)
- P-03: 전체 게시판 (탭2)
- P-04: 내 메모 (탭3)
- P-05: 북마크 (탭4)
- P-06: 프로필/설정 (탭5)
- P-07: 게시글 작성/수정 (FAB → 모달)
- P-08: 게시글 상세 + 댓글 (모달)
- P-09: 알림 패널 (헤더 벨 아이콘 → 슬라이드)

## 주요 기능
- 5개 카테고리: 일정, 이슈, 결정사항, 회의록, 기타
- 우선순위: 긴급/일반
- 북마크, 읽음 확인 (readBy/totalReaders)
- 검색/필터링
- 알림 4종: 댓글, 멘션, 확인완료, 긴급
- 하단 5탭 + FAB(글쓰기) + 헤더 알림벨

## 디자인 토큰
- Primary: #7c3aed (보라)
- Urgent: #f97316 (주황)
- Destructive: #d4183d (빨강)
- Background: #ffffff
- Surface: #f3f4f6
- Muted Text: #717182
- Border Radius: 10px
- Header 높이: 56px, TabBar: 64px, FAB: 56x56

## 설계 문서
- `docs/01_기술스택_및_아키텍처.md`
- `docs/02_DB_스키마.md` (10개 테이블, 테스트 데이터 포함)
- `docs/03_API_명세서.md` (19개 엔드포인트)
- `docs/04_화면_플로우.md` (화면별 상세, 디자인 토큰, 데이터 모델)

## 커밋 규칙
- Conventional Commits 형식 (feat:, fix:, chore:, docs: 등)
- 영어로 작성
- Co-Authored-By 없음
- 기능 단위로 나눠서 커밋

## 이전 프로젝트 (0.WISM - Flutter)
Flutter로 진행했으나 에뮬레이터/빌드 이슈로 Android Native(Kotlin)로 전환.
이전 작업물(모델, Provider 등)은 참고용으로 0.WISM에 남아있음.
