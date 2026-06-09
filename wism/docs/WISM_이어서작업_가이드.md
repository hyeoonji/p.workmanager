# WISM 이어서 작업 가이드 (다른 PC 인수인계)

> 작성 2026-06-08. 이 문서 하나로 **다른 PC에서 서버 띄우고 작업 이어가기** 가능.

---

## 0. 현재까지 한 것
- **앱(Flutter)**: 디자인 `a.Design/03Main` 1:1 매칭 완료(아이콘=lucide), 메모/캘린더/알림/프로필 등. **Mock → 실서버 연동**으로 전환.
- **백엔드**: `07.WISM/3.wism_server` — NestJS + Prisma + **SQLite**. 인증·메모·댓글·알림·검색 API 완료. seed(관리자 21 / 사업 10 / 공지 12).
- **외부 접속**: Cloudflare 퀵터널(임시 주소).

## 남은 작업 (TODO)
1. **③ FCM 푸시 — ✅✅ 완료 + 실기기 검증 완료 (2026-06-09)**
   - 실기기(SM-G991N)에서 로그인→토큰 등록(`POST /devices`)→긴급 메모 발송→**상단바 푸시 수신 확인 완료**.
   - 외부 접속은 Cloudflare 퀵터널(`cloudflared.exe tunnel --url http://localhost:8080`)로 검증 — 같은 와이파이/방화벽 불필요. ⚠️ 터널 주소는 실행마다 바뀌니 바뀌면 `wism/.env`의 `API_BASE_URL` 교체 후 `flutter build apk --release` 재빌드.
   - ⚠️ 포그라운드(앱 켜둔 상태) 수신은 현재 로그만 — 시스템 알림 표시는 앱이 백그라운드/종료일 때. 포그라운드 표시·딥링크는 추후 개선 항목.
   - **Firebase 프로젝트**: `wism-ea32d` (Android 패키지 `com.wintek.wism`).
   - **서버**: `src/devices/` 모듈 — `POST /devices`(토큰 업서트), `DELETE /devices/{fcmToken}`(204). `PushService`(firebase-admin)가 댓글·멘션·긴급 알림 생성 지점(`memos.service.ts`)에서 자동 발송. 서비스계정 키는 `secrets/firebase-service-account.json`(gitignore), `.env`의 `FIREBASE_SERVICE_ACCOUNT`로 연결 → 서버 기동 시 "FCM 푸시 활성화됨" 로그 확인. **키 없으면 자동 no-op**(알림창은 정상).
   - **앱**: `firebase_core`+`firebase_messaging`. `android/app/google-services.json` 배치, gradle 플러그인(`com.google.gms.google-services`) 적용. `lib/core/push/push_service.dart`가 권한요청+토큰등록(`POST /devices`)+수신, 로그인/로그아웃 시 `auth_controller.dart`에서 등록/해제. `main.dart`에서 `Firebase.initializeApp()`+백그라운드 핸들러. 매니페스트 `POST_NOTIFICATIONS` 권한 추가됨.
   - ⬜ **남은 것**: 실기기/에뮬레이터에서 로그인 → 토큰 등록 확인 → 다른 계정이 댓글/멘션/긴급 메모 작성 → 푸시 수신 확인. (포그라운드 표시는 현재 로그만 — 필요 시 `flutter_local_notifications`로 표시. 알림 탭 시 딥링크 이동도 추후.)
2. **첨부문서** — `docs/WISM_API_명세서.md` 6장(멀티파트 업로드/다운로드/삭제, 10MB·메모당 3개·허용형식) 서버 구현 + 앱 첨부 UI(M2에서 보류했던 부분).
3. (선택) **고정 공개주소** — ngrok 무료 고정 도메인 또는 Cloudflare named tunnel(+도메인).
4. (선택) **운영 전환** — Prisma `provider`를 `mysql`로, 사내 서버/DB 연동.

---

## 1. 코드 받기 (새 PC)

### 앱 (이미 GitHub에 있음)
```bash
git clone https://github.com/Hyeoonji/P.WorkManager.git
cd P.WorkManager        # (= 2.wism_flutter/wism 내용)
git checkout v_flutter
flutter pub get
```

### 백엔드 (`3.wism_server`) — **별도 GitHub 레포에서 받기** (필수!)
```bash
git clone -b test https://github.com/Hyeoonji/P.WorkManager-Server.git
cd P.WorkManager-Server
```
> ⚠️ 백엔드는 **앱과 다른 레포**(`P.WorkManager-Server`)에 있음. **코드는 `test` 브랜치**(master는 비어 있음). DB(`prisma/data/wism.db`)도 포함돼 데이터가 함께 옴. 이후 §3대로 실행.

---

## 2. 사전 설치 (새 PC 공통)
- **Node.js LTS** (https://nodejs.org) — `node -v`로 확인
- **Flutter SDK** (앱 빌드용)
- **Git**

## 3. 백엔드 서버 실행 (새 PC)
```bash
cd 3.wism_server
npm install
# 아래 .env 파일을 3.wism_server/ 에 생성 (git에 안 올라감)
npx prisma generate
# ↓ DB(prisma/data/wism.db)는 git에 포함돼 함께 받아짐(데이터 그대로).
#   DB가 없는 경우(폴더만 받았을 때)에만 아래 두 줄 실행:
# npx prisma db push    # 테이블 생성
# npx prisma db seed    # 관리자21·사업10·공지12 시드
npm run start:dev       # 서버 기동: http://localhost:8080/api/v1
```

**`3.wism_server/.env` 내용:**
```env
PORT=8080
DATABASE_URL="file:./data/wism.db"
JWT_ACCESS_SECRET=wism_dev_access_secret_change_me
JWT_REFRESH_SECRET=wism_dev_refresh_secret_change_me
ACCESS_TOKEN_TTL=3600
REFRESH_TOKEN_TTL=2592000
DEV_LOGIN_PASSWORD=0000
```

**개발 로그인:** 사번 `00000`~`00020` / 비번 `0000` (00000 이태경 대표이사 등 관리자 21명)

## 4. 백엔드 레포 (이미 GitHub에 올라가 있음)
- **레포:** https://github.com/Hyeoonji/P.WorkManager-Server
- **브랜치:** 코드는 **`test`**, `master`는 비어 있음 → 받을 때 `git clone -b test ...` (§1 참고)
- `.gitignore`: `node_modules/`, `.env` 제외. **DB(`prisma/data/wism.db`)는 git에 포함** → clone만 하면 **데이터(공지·테스트 글)까지** 옴. `.env`만 만들고 `npm install` 후 바로 실행.
- 데이터를 초기화하려면 `prisma/data/wism.db` 삭제 후 `npx prisma db push && npx prisma db seed`.
- 새 PC에서 수정 후 올릴 때: `git add -A && git commit -m "..." && git push origin test`

---

## 5. 앱 ↔ 서버 연결 (`wism/.env`)
```env
# 같은 와이파이: 서버 PC의 LAN IP
API_BASE_URL=http://<서버PC_IP>:8080/api/v1
USE_MOCK_AUTH=false
```
- 서버 PC IP 확인: `ipconfig` → IPv4 (예 192.168.x.x)
- **방화벽**: 서버 PC에서 8080 인바운드 허용(관리자 PowerShell):
  ```powershell
  New-NetFirewallRule -DisplayName "WISM Dev 8080" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8080 -Profile Private,Domain
  ```
  + Wi-Fi 네트워크를 "개인(Private)"으로.
- **외부망(셀룰러 등)**: Cloudflare 터널 — *git에 올릴 것 없음. 새 PC에서 설치 후 실행만.*
  ```bash
  winget install --id Cloudflare.cloudflared -e     # 최초 1회 설치
  cloudflared tunnel --url http://localhost:8080    # 서버 켜둔 상태에서 실행
  ```
  출력되는 `https://xxxx.trycloudflare.com` 주소를 `.env`의 API_BASE_URL에 `/api/v1` 붙여 사용.
  ⚠️ **퀵터널 주소는 실행마다 랜덤**으로 바뀜 → 그때 .env 교체 후 `flutter build apk --release`. 같은 와이파이면 터널 없이 LAN IP만으로 충분.
  (고정 주소가 필요하면 ngrok 무료 도메인 / Cloudflare named tunnel — 계정·자격증명 필요, git에 올리지 말 것)
- `.env` 변경 후 APK 재빌드: `flutter build apk --release`
- 안드로이드: HTTP(평문) 허용·INTERNET 권한 이미 `AndroidManifest.xml`에 적용됨.

---

## 6. 서버 API 요약 (`3.wism_server/src`)
- 인증: `POST /auth/login` `/auth/refresh` `/auth/logout`
- 내 정보: `GET·PUT /me`
- 메모: `GET·POST /memos`, `GET·PUT·DELETE /memos/{id}`, `POST /memos/{id}/read`, `PUT·DELETE /memos/{id}/bookmark`
- 댓글: `GET·POST /memos/{id}/comments`, `PUT·DELETE /comments/{id}`
- 알림: `GET /notifications`, `/notifications/unread-count`, `PUT /notifications/{id}/read`, `/notifications/read-all`
- 검색: `GET /users?q=`, `GET /projects?q=`
- 디바이스(FCM): `POST /devices`(토큰 등록/업서트), `DELETE /devices/{fcmToken}`(해제) — `src/devices/`
- 날짜는 KST 벽시계 ISO(offset 없음)로 응답 — `src/common/serialize.ts`

## 7. 참고 문서 (repo `docs/`)
- 디자인 스펙: `WISM_디자인_스펙_03Main.md`
- API 명세: `WISM_API_명세서.md`
- DB 스키마(MySQL 운영용): `WISM_DB_스키마.sql`, 시드: `WISM_seed_users.sql`
- 개발 계획서: `WISM_개발계획서.md`
