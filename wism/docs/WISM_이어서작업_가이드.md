# WISM 이어서 작업 가이드 (다른 PC 인수인계)

> 작성 2026-06-08. 이 문서 하나로 **다른 PC에서 서버 띄우고 작업 이어가기** 가능.

---

## 0. 현재까지 한 것
- **앱(Flutter)**: 디자인 `a.Design/03Main` 1:1 매칭 완료(아이콘=lucide), 메모/캘린더/알림/프로필 등. **Mock → 실서버 연동**으로 전환.
- **백엔드**: `07.WISM/3.wism_server` — NestJS + Prisma + **SQLite**. 인증·메모·댓글·알림·검색 API 완료. seed(관리자 21 / 사업 10 / 공지 12).
- **외부 접속**: Cloudflare 퀵터널(임시 주소).

## 남은 작업 (TODO)
1. **③ FCM 푸시** — Firebase 콘솔 선행: ① Firebase 프로젝트 생성 → ② Android 앱 등록(applicationId는 `android/app/build.gradle(.kts)`의 `applicationId` 확인) → ③ `google-services.json` 받아 `android/app/`에 → ④ 서비스 계정 비공개 키 발급. 이후 **서버** firebase-admin + `DevicesModule`(`POST /devices`, `DELETE /devices/{token}`), **앱** `firebase_messaging`(권한·토큰등록·수신·딥링크).
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

### 백엔드 (`3.wism_server`) — 아래 3·4 참고로 전송/실행

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

## 4. 백엔드 코드 전송 (git 아직 미연동)
`3.wism_server`는 아직 원격이 없음. 둘 중 하나:

**(A) 새 GitHub 레포 만들어 푸시** (권장)
```bash
cd 3.wism_server
git init
git add -A
git commit -m "WISM backend (NestJS+Prisma+SQLite)"
git branch -M main
git remote add origin <GitHub에서 만든 새 레포 URL>
git push -u origin main
```
> `.gitignore`에 `node_modules/`, `.env` 제외. **DB(`prisma/data/wism.db`)는 git에 포함** → 새 PC는 pull/clone만 하면 **데이터(공지·테스트 글까지) 그대로** 옴. `.env`만 재생성하고 `npm install` 후 바로 실행. (임시 저널 `*.db-journal/-wal`만 제외)

**(B) 폴더 복사** (USB/클라우드) — `node_modules` 빼고 복사(`data/wism.db` 포함) 후 `npm install`.

> 참고: DB가 git에 있어 데이터가 함께 이동함. 데이터를 초기 상태로 되돌리려면 `prisma/data/wism.db` 삭제 후 `npx prisma db push && npx prisma db seed`.

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
- **외부망(셀룰러 등)**: Cloudflare 터널
  ```bash
  cloudflared tunnel --url http://localhost:8080
  ```
  출력되는 `https://xxxx.trycloudflare.com` 주소를 `.env`의 API_BASE_URL에 `/api/v1` 붙여 사용. (재시작 시 주소 변경 → .env 교체 후 재빌드)
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
- 날짜는 KST 벽시계 ISO(offset 없음)로 응답 — `src/common/serialize.ts`

## 7. 참고 문서 (repo `docs/`)
- 디자인 스펙: `WISM_디자인_스펙_03Main.md`
- API 명세: `WISM_API_명세서.md`
- DB 스키마(MySQL 운영용): `WISM_DB_스키마.sql`, 시드: `WISM_seed_users.sql`
- 개발 계획서: `WISM_개발계획서.md`
