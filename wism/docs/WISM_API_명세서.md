# WISM API 명세서

| 항목 | 내용 |
| --- | --- |
| 버전 | v0.1 (2026-06-06) |
| Base URL (개발) | `https://{aws-dev-host}/api/v1` |
| 인증 | JWT Bearer (Access + Refresh) |
| 대상 | WISM 앱(Flutter) ↔ 백엔드 REST 서버 |

> 본 명세는 **클라이언트(앱) 요구 기준 초안**입니다. 서버팀과 합의 후 확정합니다.
> 데이터 구조는 `WISM_DB_스키마.sql`, 기능 정의는 `WISM_개발계획서.md`와 1:1 대응됩니다.

---

## 0. 공통 규약

### 0.1 기본
- 모든 통신은 **HTTPS**, 요청/응답 본문은 **JSON (UTF-8)**. (첨부 업로드만 `multipart/form-data`)
- 인증 필요한 모든 요청에 헤더: `Authorization: Bearer {accessToken}`
- 날짜·시각: **ISO 8601 (KST)** — 예 `2026-06-05T14:30:00+09:00`, 날짜만일 때 `2026-06-05`

### 0.2 페이징
- 요청: `?page={1부터}&size={기본 20}`
- 응답 공통 래퍼:
```json
{
  "items": [ /* ... */ ],
  "meta": { "page": 1, "size": 20, "totalCount": 137, "hasNext": true }
}
```

### 0.3 에러 응답 (공통)
- HTTP 상태 코드 + 본문:
```json
{ "code": "MEMO_NOT_FOUND", "message": "메모를 찾을 수 없습니다." }
```

| HTTP | 의미 | 예시 code |
| --- | --- | --- |
| 400 | 잘못된 요청/검증 실패 | `VALIDATION_ERROR` |
| 401 | 미인증/토큰 만료 | `TOKEN_EXPIRED`, `UNAUTHORIZED` |
| 403 | 권한 없음 | `FORBIDDEN` |
| 404 | 리소스 없음 | `MEMO_NOT_FOUND` |
| 409 | 충돌(중복 등) | `DUPLICATE` |
| 413 | 첨부 용량 초과 | `FILE_TOO_LARGE` |
| 415 | 허용되지 않은 형식 | `UNSUPPORTED_FILE_TYPE` |
| 500 | 서버 오류 | `INTERNAL_ERROR` |

### 0.4 공통 객체 형태

**User (요약)**
```json
{ "id": 5, "name": "김민준", "dept": "XR개발실 3팀", "position": "팀장", "photoUrl": null }
```

**Memo (상세)**
```json
{
  "id": 12,
  "title": "XR 헤드셋 납품 일정 확인 요청",
  "content": "6월 10일 ...",
  "priority": "긴급",
  "category": "일정",
  "project": { "id": 3, "name": "XR 헤드셋 납품", "clientName": "EQUIP" },
  "scheduledDate": "2026-06-10",
  "author": { "id": 5, "name": "김민준", "dept": "XR개발실 3팀", "position": "팀장", "photoUrl": null },
  "assignees": [ { "userId": 7, "name": "이예지" } ],
  "createdAt": "2026-06-05T14:30:00+09:00",
  "updatedAt": "2026-06-05T14:30:00+09:00",
  "readBy": 3,
  "totalReaders": 5,
  "viewCount": 12,
  "commentCount": 2,
  "bookmarked": false,
  "isRead": true,
  "attachments": [
    { "id": 1, "fileName": "일정표.pdf", "mimeType": "application/pdf", "size": 23456, "url": "/attachments/1/download" }
  ]
}
```
> 목록(list) 응답의 memo 항목은 `content`·`attachments` 제외한 **요약형**으로 반환.

---

## 1. 인증 (Auth)

### POST /auth/login
사번 + 비밀번호 로그인. (운영 시 기존 홈페이지 인증으로 대체)
```json
// Request
{ "employeeNo": "20230001", "password": "******" }
```
```json
// 200 Response
{
  "accessToken": "eyJ...",
  "refreshToken": "eyJ...",
  "expiresIn": 3600,
  "user": { "id": 5, "name": "김민준", "dept": "XR개발실 3팀", "position": "팀장", "photoUrl": null }
}
```
- 실패: `401 INVALID_CREDENTIALS` / 비활성 계정 `403 INACTIVE_USER` / 비관리자 `403 NOT_MANAGER`

### POST /auth/refresh
```json
// Request
{ "refreshToken": "eyJ..." }
// 200 Response
{ "accessToken": "eyJ...", "expiresIn": 3600 }
```

### POST /auth/logout  *(인증)*
```json
// Request
{ "refreshToken": "eyJ..." }
// 204 No Content
```

---

## 2. 사용자 (Users)

### GET /me  *(인증)*
내 프로필 + 활동 통계.
```json
// 200 Response
{
  "id": 5, "employeeNo": "20230001", "name": "김민준",
  "email": "kim@wintek.com", "phone": "010-1234-5678",
  "position": "팀장", "dept": "XR개발실 3팀", "photoUrl": null, "role": "manager",
  "stats": { "memoCount": 12, "commentCount": 45, "bookmarkCount": 8 }
}
```

### PUT /me  *(인증)*
프로필 수정 (이름·직급·부서·이메일·전화번호).
```json
// Request
{ "name": "김민준", "position": "팀장", "dept": "XR개발실 3팀",
  "email": "kim@wintek.com", "phone": "010-1234-5678" }
// 200 Response → /me 와 동일 형태
```
> **사진(photoUrl)은 회사 내부 서버 사진과 연동(읽기 전용)** — 앱/API에서 수정 불가. 수정 요청에 포함하지 않음.

### GET /users?q={이름}  *(인증)*
**담당자 태그 자동완성.** 이름 부분일치, 검색 대상 = 전체 직원.
```json
// GET /users?q=이예
// 200 Response
[
  { "id": 7, "name": "이예지", "dept": "사업 5실 3팀", "position": "주임연구원", "photoUrl": null }
]
```
- `q` 최소 1자, 결과 최대 20건. 동명이인은 dept·position으로 구분.

---

## 3. 사업 (Projects)

### GET /projects?q={사업명}  *(인증)*
**사업(프로젝트) 자동완성.** 선택 시 주관업체가 함께 반환되어 자동 연결.
```json
// GET /projects?q=XR
// 200 Response
[
  { "id": 3, "name": "XR 헤드셋 납품", "clientName": "EQUIP" },
  { "id": 4, "name": "XR 콘텐츠 개발", "clientName": "XR-EDU" }
]
```

---

## 4. 메모 (Memos)

### GET /memos  *(인증)*  — 목록/검색/필터
| 쿼리 | 설명 |
| --- | --- |
| `scope` | `all`(전체) / `my`(내 메모) / `bookmarks`(북마크). 기본 all |
| `category` | 일정/이슈/결정사항/회의록/기타 (복수 가능: 콤마) |
| `priority` | 긴급/일반 |
| `q` | 제목·내용·사업명 통합 검색 |
| `sort` | `latest`(기본) / `oldest` |
| `page`,`size` | 페이징 |
```json
// 200 Response (요약형 + 페이징 래퍼)
{
  "items": [
    {
      "id": 12, "title": "XR 헤드셋 납품 일정 확인 요청",
      "priority": "긴급", "category": "일정",
      "project": { "id": 3, "name": "XR 헤드셋 납품", "clientName": "EQUIP" },
      "scheduledDate": "2026-06-10",
      "author": { "id": 5, "name": "김민준" },
      "createdAt": "2026-06-05T11:00:00+09:00",
      "readBy": 3, "totalReaders": 5,
      "viewCount": 12, "commentCount": 0,
      "bookmarked": false, "isRead": false
    }
  ],
  "meta": { "page": 1, "size": 20, "totalCount": 8, "hasNext": false }
}
```

### GET /memos/{id}  *(인증)*
상세 조회. **조회수는 여기서 증가하지 않음** (읽음 확인 시에만 증가).
- 200: 공통 객체 **Memo(상세)** / 404 `MEMO_NOT_FOUND`

### POST /memos  *(인증)*
```json
// Request
{
  "title": "XR 헤드셋 납품 일정 확인 요청",
  "content": "6월 10일 ...",
  "priority": "긴급",
  "category": "일정",
  "projectId": 3,
  "scheduledDate": "2026-06-10",
  "assigneeIds": [7, 9]
}
```
- `title` 필수. `scheduledDate`는 `category=일정`일 때만 유효.
- 201: 생성된 Memo(상세). 담당자(assignee)에게 **mention 알림** 생성 + FCM 발송.

### PUT /memos/{id}  *(인증, 작성자 본인)*
- Request: POST와 동일 필드(부분 수정 허용). 200: 수정된 Memo / 403 `FORBIDDEN`(비소유자)

### DELETE /memos/{id}  *(인증, 작성자 본인)*
- 204 No Content / 403 `FORBIDDEN`

### POST /memos/{id}/read  *(인증)*
읽음 확인. (중복 호출 무시 — 멱등). 최초 확인 시 **조회수(viewCount)도 +1**(사람당 1회, 작성자 제외).
```json
// 200 Response
{ "memoId": 12, "readBy": 4, "totalReaders": 5, "viewCount": 3 }
```
> `totalReaders` = 작성 시점 활성 관리자 수 스냅샷(작성자 포함). `viewCount` = 작성자 제외 읽음확인 인원.

### PUT /memos/{id}/bookmark  /  DELETE /memos/{id}/bookmark  *(인증)*
북마크 추가/해제.
```json
// 200 Response
{ "memoId": 12, "bookmarked": true }
```

---

## 5. 댓글 (Comments)

### GET /memos/{id}/comments  *(인증)*
```json
// 200 Response
[
  { "id": 101, "author": { "id": 7, "name": "이예지" },
    "content": "예산안 검토 완료했습니다.", "type": "status",
    "createdAt": "2026-06-05T15:20:00+09:00" }
]
```

### POST /memos/{id}/comments  *(인증)*
```json
// Request
{ "content": "확인했습니다.", "type": "comment" }
// 201 Response → 생성된 comment 객체
```
- 작성 시 메모 작성자에게 **comment 알림** 생성 + FCM 발송.

### PUT /comments/{id}  *(인증, 작성자 본인)*  — `{ "content": "..." }` → 200
### DELETE /comments/{id}  *(인증, 작성자 본인)*  — 204

---

## 6. 첨부파일 (Attachments)

### POST /memos/{id}/attachments  *(인증, multipart/form-data)*
- 필드: `file` (바이너리)
- 제약: **파일당 10MB / 메모당 3개 / 허용형식: 이미지·PDF·HWP·Word·PPT·Excel**
```json
// 201 Response
{ "id": 1, "memoId": 12, "fileName": "일정표.pdf",
  "mimeType": "application/pdf", "size": 23456, "url": "/attachments/1/download" }
```
- 초과: `413 FILE_TOO_LARGE` / 개수초과 `400 ATTACHMENT_LIMIT_EXCEEDED` / 형식 `415 UNSUPPORTED_FILE_TYPE`

| 허용 형식 | 확장자 / MIME |
| --- | --- |
| 이미지 | jpg, jpeg, png, gif / image/* |
| PDF | pdf / application/pdf |
| 한글 | hwp, hwpx |
| Word | doc, docx |
| PowerPoint | ppt, pptx |
| Excel | xls, xlsx |

### GET /attachments/{id}/download  *(인증)*
- 200: 파일 바이너리 (`Content-Disposition: attachment; filename=...`). 인증 토큰 필수.

### DELETE /attachments/{id}  *(인증, 메모 작성자)*  — 204

---

## 7. 알림 (Notifications)

### GET /notifications  *(인증)*  — `?page=&size=`
```json
// 200 Response (페이징 래퍼)
{
  "items": [
    { "id": 555, "type": "mention", "title": "멘션됨",
      "content": "@김민준 확인 부탁드립니다", "memoId": 12,
      "isRead": false, "createdAt": "2026-06-05T11:50:00+09:00" }
  ],
  "meta": { "page": 1, "size": 20, "totalCount": 4, "hasNext": false }
}
```

### GET /notifications/unread-count  *(인증)*  — 헤더 배지용
```json
{ "count": 3 }
```

### PUT /notifications/{id}/read  *(인증)*  — 200 `{ "id":555, "isRead":true }`
### PUT /notifications/read-all  *(인증)*  — 204 (모두 읽음)

---

## 8. 디바이스 / 푸시 (Devices)

### POST /devices  *(인증)*  — FCM 토큰 등록/갱신
```json
// Request
{ "fcmToken": "f9X...", "platform": "android" }
// 200 / 201 Response
{ "id": 20, "platform": "android" }
```
- 동일 토큰 재등록 시 `updated_at`만 갱신(업서트).

### DELETE /devices/{fcmToken}  *(인증)*  — 로그아웃 시 토큰 해제. 204

---

## 부록. 엔드포인트 요약

| 분류 | 메서드 | 경로 |
| --- | --- | --- |
| 인증 | POST | /auth/login, /auth/refresh, /auth/logout |
| 사용자 | GET/PUT | /me |
| 담당자 검색 | GET | /users?q= |
| 사업 검색 | GET | /projects?q= |
| 메모 | GET/POST | /memos |
| 메모 | GET/PUT/DELETE | /memos/{id} |
| 읽음/북마크 | POST/PUT/DELETE | /memos/{id}/read, /memos/{id}/bookmark |
| 댓글 | GET/POST | /memos/{id}/comments |
| 댓글 | PUT/DELETE | /comments/{id} |
| 첨부 | POST | /memos/{id}/attachments |
| 첨부 | GET/DELETE | /attachments/{id}/download, /attachments/{id} |
| 알림 | GET | /notifications, /notifications/unread-count |
| 알림 | PUT | /notifications/{id}/read, /notifications/read-all |
| 디바이스 | POST/DELETE | /devices, /devices/{fcmToken} |

### 확정된 정책
- **② 조회수(viewCount)**: 읽음 확인 시에만 +1, 사람당 1회, 작성자 제외
- **③ totalReaders**: 작성 시점 활성 관리자 수(is_active & role manager/admin) 스냅샷, 작성자 포함
- **④ 프로필 사진**: 회사 내부 서버 사진 연동(읽기 전용, 수정 불가)
- **⑤ 검색**: 1차 `LIKE`, 필요 시 ngram FULLTEXT로 전환

### 서버팀과 남은 합의
- **① 인증**: 토큰 발급 주체(운영=홈페이지 계정 검증 후 WISM 서버 발급 권장)·만료(Access 1h / Refresh 30d 제안) 확정
- 운영 이전 시 `wintek_user`·`wintek_project`의 기존 테이블 매핑 방식
