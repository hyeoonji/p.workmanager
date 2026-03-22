# WISM REST API 명세서

> **이 문서는 Phase 2 (서버 연동) 참조용입니다.**
> Phase 1에서는 Room DB를 사용하며, 아래 API의 요청/응답 구조를 Room DAO 쿼리로 로컬 구현합니다.
> Phase 2 전환 시 Retrofit ApiService가 이 명세를 그대로 따릅니다.

## 0. 개요

| 항목 | 내용 |
|------|------|
| **Base URL** | `https://{서버주소}/api` |
| **통신** | HTTPS (JSON) |
| **인증** | JWT Bearer Token |
| **Content-Type** | `application/json` |

### 인증 헤더
```
Authorization: Bearer {jwt_token}
```
> 로그인 API를 제외한 모든 API는 JWT 토큰 필수

### 공통 응답 형식

**성공**
```json
{
    "success": true,
    "data": { ... }
}
```

**실패**
```json
{
    "success": false,
    "error": {
        "code": "UNAUTHORIZED",
        "message": "로그인이 필요합니다."
    }
}
```

### 공통 에러 코드

| HTTP 상태 | 코드 | 설명 |
|-----------|------|------|
| 400 | `BAD_REQUEST` | 필수 파라미터 누락 또는 유효하지 않은 값 |
| 401 | `UNAUTHORIZED` | 토큰 없음/만료/유효하지 않음 |
| 403 | `FORBIDDEN` | 권한 없음 (본인 글이 아닌데 수정/삭제 시도) |
| 404 | `NOT_FOUND` | 리소스 없음 |
| 500 | `SERVER_ERROR` | 서버 내부 오류 |

---

## 1. 인증 (Auth)

### 1-1. 로그인

```
POST /api/auth/login
```

> 인증 불필요 (토큰 없이 호출)

**Request Body:**
```json
{
    "login_id": "kim.team",
    "password": "test1234"
}
```

**Response (200):**
```json
{
    "success": true,
    "data": {
        "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        "expires_in": 604800,
        "user": {
            "id": 1,
            "login_id": "kim.team",
            "name": "김팀장",
            "department": "XR개발실 1팀",
            "position": "팀장",
            "email": "kim@wintek.co.kr",
            "phone": "010-1111-1111",
            "photo_url": null,
            "role": "manager"
        }
    }
}
```

**에러:**
| 상황 | HTTP | 코드 |
|------|------|------|
| 아이디/비밀번호 불일치 | 401 | `INVALID_CREDENTIALS` |
| 비활성 계정 | 403 | `ACCOUNT_DISABLED` |

---

### 1-2. 로그아웃

```
POST /api/auth/logout
```

**Request Body:**
```json
{
    "fcm_token": "현재_기기_FCM_토큰"
}
```
> FCM 토큰을 전달하면 서버에서 해당 토큰 삭제 (푸시 중단)

**Response (200):**
```json
{
    "success": true,
    "data": {
        "message": "로그아웃 되었습니다."
    }
}
```

---

## 2. 대시보드 (Dashboard)

### 2-1. 대시보드 요약 조회

```
GET /api/dashboard
```

**Response (200):**
```json
{
    "success": true,
    "data": {
        "stats": {
            "urgent_count": 2,
            "today_count": 3,
            "my_memo_count": 5
        },
        "urgent_memos": [
            {
                "id": 10,
                "title": "A프로젝트 납기 변경",
                "category": "issue",
                "author_name": "박팀장",
                "created_at": "2025-03-22 10:30:00"
            }
        ],
        "today_memos": [
            {
                "id": 12,
                "title": "3월 월간회의",
                "category": "schedule",
                "author_name": "김팀장",
                "created_at": "2025-03-22 09:00:00"
            }
        ]
    }
}
```

> urgent_memos: 미확인(안읽은) 긴급 메모 최대 3건
> today_memos: 오늘 날짜 게시글 전체

---

## 3. 게시글 (Posts)

### 3-1. 게시글 목록 조회

```
GET /api/posts
```

**Query Parameters:**

| 파라미터 | 타입 | 필수 | 설명 | 예시 |
|---------|------|------|------|------|
| page | int | - | 페이지 번호 (기본: 1) | `1` |
| limit | int | - | 페이지당 개수 (기본: 20) | `20` |
| search | string | - | 검색어 (제목+내용) | `서버` |
| category | string | - | 카테고리 필터 | `issue` |
| priority | string | - | 우선순위 필터 | `urgent` |
| filter | string | - | 특수 필터 (`my`, `bookmarks`) | `my` |

**예시:**
```
GET /api/posts?page=1&limit=20&category=issue&priority=urgent
GET /api/posts?search=서버&page=1
GET /api/posts?filter=my
GET /api/posts?filter=bookmarks
```

**Response (200):**
```json
{
    "success": true,
    "data": {
        "posts": [
            {
                "id": 10,
                "title": "A프로젝트 납기 변경 긴급 공유",
                "content": "오전 10시 클라이언트로부터 납기 변경 요청...",
                "category": "issue",
                "priority": "urgent",
                "project": "A프로젝트",
                "author": {
                    "id": 2,
                    "name": "박팀장",
                    "department": "XR개발실 2팀"
                },
                "tags": ["김팀장", "이수석"],
                "comment_count": 7,
                "read_by": 3,
                "total_readers": 5,
                "is_read": false,
                "is_bookmarked": true,
                "created_at": "2025-03-22 10:30:00",
                "updated_at": "2025-03-22 10:30:00"
            }
        ],
        "pagination": {
            "current_page": 1,
            "total_pages": 3,
            "total_count": 48,
            "has_next": true
        }
    }
}
```

> 정렬: 긴급(urgent) 메모 상단 고정, 그 안에서 최신순
> content: 목록에서는 미리보기 용도로 앞부분만 잘라서 반환 (100자)

---

### 3-2. 게시글 상세 조회

```
GET /api/posts/{id}
```

**Response (200):**
```json
{
    "success": true,
    "data": {
        "id": 10,
        "title": "A프로젝트 납기 변경 긴급 공유",
        "content": "본문 전체 내용...",
        "category": "issue",
        "priority": "urgent",
        "project": "A프로젝트",
        "author": {
            "id": 2,
            "name": "박팀장",
            "department": "XR개발실 2팀",
            "position": "팀장"
        },
        "tags": ["김팀장", "이수석"],
        "read_by": 3,
        "total_readers": 5,
        "is_read": false,
        "is_bookmarked": true,
        "is_mine": false,
        "comments": [
            {
                "id": 1,
                "author": {
                    "id": 1,
                    "name": "김팀장"
                },
                "content": "확인했습니다",
                "type": "comment",
                "created_at": "2025-03-22 11:00:00"
            },
            {
                "id": 2,
                "author": {
                    "id": 3,
                    "name": "이팀장"
                },
                "content": "확인 완료",
                "type": "status",
                "created_at": "2025-03-22 11:30:00"
            }
        ],
        "created_at": "2025-03-22 10:30:00",
        "updated_at": "2025-03-22 10:30:00"
    }
}
```

> `is_mine`: 현재 로그인 사용자의 글인지 (수정/삭제 메뉴 표시 여부)
> `comments`: 댓글 목록 포함 (별도 API 불필요)

---

### 3-3. 게시글 작성

```
POST /api/posts
```

**Request Body:**
```json
{
    "title": "3월 월간회의 안건",
    "content": "이번 달 회의 안건을 공유합니다...",
    "category": "meeting",
    "priority": "normal",
    "project": "A프로젝트",
    "tags": ["김팀장", "이수석"]
}
```

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| title | string | O | 제목 (최대 200자) |
| content | string | O | 본문 |
| category | string | O | schedule/issue/decision/meeting/other |
| priority | string | - | urgent/normal (기본: normal) |
| project | string | - | 프로젝트명 |
| tags | string[] | - | 태그 목록 |

**Response (201):**
```json
{
    "success": true,
    "data": {
        "id": 15,
        "message": "게시글이 등록되었습니다."
    }
}
```

> 작성 시 서버에서 처리 (Phase 2):
> 1. 게시글 저장
> 2. 태그 등록 (없으면 wism_tags에 신규 생성)
> 3. 전체 관리자에게 알림 생성 (긴급일 경우 urgent 타입)
> 4. 푸시 알림 발송 (FCM)

---

### 3-4. 게시글 수정

```
PUT /api/posts/{id}
```

> 본인 글만 수정 가능

**Request Body:**
```json
{
    "title": "3월 월간회의 안건 (수정)",
    "content": "수정된 내용...",
    "category": "meeting",
    "priority": "urgent",
    "project": "A프로젝트",
    "tags": ["김팀장"]
}
```

**Response (200):**
```json
{
    "success": true,
    "data": {
        "message": "게시글이 수정되었습니다."
    }
}
```

**에러:**
| 상황 | HTTP | 코드 |
|------|------|------|
| 본인 글이 아님 | 403 | `FORBIDDEN` |

---

### 3-5. 게시글 삭제

```
DELETE /api/posts/{id}
```

> 본인 글만 삭제 가능. 소프트 삭제 (is_deleted = 1)

**Response (200):**
```json
{
    "success": true,
    "data": {
        "message": "게시글이 삭제되었습니다."
    }
}
```

---

## 4. 댓글 (Comments)

### 4-1. 댓글 작성

```
POST /api/posts/{post_id}/comments
```

**Request Body:**
```json
{
    "content": "확인했습니다. 자료 전달 예정입니다.",
    "type": "comment"
}
```

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| content | string | O | 댓글 내용 |
| type | string | - | comment(일반) / status(확인완료). 기본: comment |

**Response (201):**
```json
{
    "success": true,
    "data": {
        "id": 25,
        "author": {
            "id": 1,
            "name": "김팀장"
        },
        "content": "확인했습니다. 자료 전달 예정입니다.",
        "type": "comment",
        "created_at": "2025-03-22 14:30:00"
    }
}
```

> 서버에서 처리 (Phase 2):
> 1. 댓글 저장
> 2. 게시글 작성자에게 알림 생성 (comment 타입)
> 3. 태그된 사용자에게 멘션 알림 생성 (mention 타입)
> 4. 푸시 알림 발송

---

## 5. 읽음 확인 (Read Receipts)

### 5-1. 읽음 확인 처리

```
POST /api/posts/{post_id}/read
```

> "확인 완료" 버튼 클릭 시 호출

**Request Body:** 없음

**Response (200):**
```json
{
    "success": true,
    "data": {
        "read_by": 4,
        "total_readers": 5,
        "message": "확인 완료 처리되었습니다."
    }
}
```

> 서버에서 처리 (Phase 2):
> 1. wism_read_receipts에 기록 (이미 있으면 무시)
> 2. type="status" 댓글 자동 생성 ("확인 완료")
> 3. 게시글 작성자에게 status 알림 생성

---

## 6. 북마크 (Bookmarks)

### 6-1. 북마크 토글

```
POST /api/posts/{post_id}/bookmark
```

> 이미 북마크 → 해제, 북마크 안됨 → 등록 (토글)

**Request Body:** 없음

**Response (200):**
```json
{
    "success": true,
    "data": {
        "bookmarked": true,
        "message": "북마크에 추가되었습니다."
    }
}
```
또는
```json
{
    "success": true,
    "data": {
        "bookmarked": false,
        "message": "북마크가 해제되었습니다."
    }
}
```

---

## 7. 알림 (Notifications)

### 7-1. 알림 목록 조회

```
GET /api/notifications
```

**Query Parameters:**

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| page | int | - | 페이지 (기본: 1) |
| limit | int | - | 개수 (기본: 50) |

**Response (200):**
```json
{
    "success": true,
    "data": {
        "notifications": [
            {
                "id": 1,
                "type": "comment",
                "title": "새 댓글",
                "content": "김팀장님이 댓글을 남겼습니다.",
                "memo_title": "서버 장애 긴급 보고",
                "post_id": 10,
                "sender": {
                    "id": 1,
                    "name": "김팀장"
                },
                "is_read": false,
                "created_at": "2025-03-22 14:30:00"
            },
            {
                "id": 2,
                "type": "urgent",
                "title": "긴급 이슈",
                "content": "새로운 긴급 이슈가 등록되었습니다.",
                "memo_title": "A프로젝트 납기 변경",
                "post_id": 10,
                "sender": {
                    "id": 2,
                    "name": "박팀장"
                },
                "is_read": false,
                "created_at": "2025-03-22 10:30:00"
            }
        ],
        "unread_count": 3
    }
}
```

---

### 7-2. 알림 읽음 처리 (개별)

```
PUT /api/notifications/{id}/read
```

**Response (200):**
```json
{
    "success": true,
    "data": {
        "unread_count": 2
    }
}
```

---

### 7-3. 알림 전체 읽음 처리

```
PUT /api/notifications/read-all
```

**Response (200):**
```json
{
    "success": true,
    "data": {
        "unread_count": 0,
        "message": "모든 알림을 읽음 처리했습니다."
    }
}
```

---

## 8. 사용자 (Users / Profile)

### 8-1. 내 정보 조회

```
GET /api/users/me
```

**Response (200):**
```json
{
    "success": true,
    "data": {
        "id": 1,
        "login_id": "kim.team",
        "name": "김팀장",
        "department": "XR개발실 1팀",
        "position": "팀장",
        "email": "kim@wintek.co.kr",
        "phone": "010-1111-1111",
        "photo_url": null,
        "role": "manager",
        "stats": {
            "post_count": 12,
            "comment_count": 45,
            "bookmark_count": 8
        },
        "settings": {
            "push_enabled": true,
            "auto_login_enabled": false
        }
    }
}
```

---

### 8-2. 프로필 수정

```
PUT /api/users/me
```

**Request Body:**
```json
{
    "name": "김팀장",
    "email": "kim.new@wintek.co.kr",
    "phone": "010-9999-9999",
    "department": "XR개발실 1팀",
    "position": "팀장"
}
```

> photo_url은 별도 이미지 업로드 API로 처리 (8-3)

**Response (200):**
```json
{
    "success": true,
    "data": {
        "message": "프로필이 수정되었습니다."
    }
}
```

---

### 8-3. 프로필 사진 업로드

```
POST /api/users/me/photo
```

> Content-Type: `multipart/form-data`

**Request:**
```
photo: (파일)
```

**Response (200):**
```json
{
    "success": true,
    "data": {
        "photo_url": "/uploads/profile/1_20250322.jpg"
    }
}
```

---

### 8-4. 설정 변경

```
PUT /api/users/me/settings
```

**Request Body:**
```json
{
    "push_enabled": false
}
```

**Response (200):**
```json
{
    "success": true,
    "data": {
        "push_enabled": false,
        "message": "설정이 변경되었습니다."
    }
}
```

---

## 9. FCM 토큰 (Push)

### 9-1. FCM 토큰 등록/갱신

```
POST /api/fcm/token
```

> 앱 실행 시 또는 토큰 갱신 시 호출

**Request Body:**
```json
{
    "token": "fMRLs8K7T2...",
    "device_type": "android"
}
```

**Response (200):**
```json
{
    "success": true,
    "data": {
        "message": "토큰이 등록되었습니다."
    }
}
```

> 같은 토큰이 이미 있으면 user_id만 갱신 (기기 변경 대응)

---

## 10. API 엔드포인트 요약

| # | Method | Endpoint | 설명 | 인증 |
|---|--------|----------|------|------|
| 1 | POST | `/api/auth/login` | 로그인 | X |
| 2 | POST | `/api/auth/logout` | 로그아웃 | O |
| 3 | GET | `/api/dashboard` | 대시보드 요약 | O |
| 4 | GET | `/api/posts` | 게시글 목록 (검색/필터/내메모/북마크) | O |
| 5 | GET | `/api/posts/{id}` | 게시글 상세 + 댓글 | O |
| 6 | POST | `/api/posts` | 게시글 작성 | O |
| 7 | PUT | `/api/posts/{id}` | 게시글 수정 | O |
| 8 | DELETE | `/api/posts/{id}` | 게시글 삭제 | O |
| 9 | POST | `/api/posts/{id}/comments` | 댓글 작성 | O |
| 10 | POST | `/api/posts/{id}/read` | 읽음 확인 | O |
| 11 | POST | `/api/posts/{id}/bookmark` | 북마크 토글 | O |
| 12 | GET | `/api/notifications` | 알림 목록 | O |
| 13 | PUT | `/api/notifications/{id}/read` | 알림 개별 읽음 | O |
| 14 | PUT | `/api/notifications/read-all` | 알림 전체 읽음 | O |
| 15 | GET | `/api/users/me` | 내 정보 조회 | O |
| 16 | PUT | `/api/users/me` | 프로필 수정 | O |
| 17 | POST | `/api/users/me/photo` | 프로필 사진 업로드 | O |
| 18 | PUT | `/api/users/me/settings` | 설정 변경 | O |
| 19 | POST | `/api/fcm/token` | FCM 토큰 등록 | O |

**총 19개 엔드포인트**

---

## 11. 화면별 API / DAO 매핑

| 화면 | Phase 2 API | Phase 1 Room DAO | 시점 |
|------|------------|-----------------|------|
| **P-01 로그인** | `POST /auth/login` | `UserDao.findByLoginIdAndPassword()` | 로그인 버튼 |
| | `POST /fcm/token` | (미사용) | 로그인 성공 직후 |
| **P-02 대시보드** | `GET /dashboard` | `PostDao.getUrgentUnreadCount()` + `PostDao.getTodayPosts()` + `PostDao.getMyPostCount()` | 화면 진입 / 새로고침 |
| **P-03 전체 게시판** | `GET /posts` | `PostDao.getPosts(category, priority, search, page)` | 화면 진입 / 스크롤 / 검색 |
| | `POST /posts/{id}/bookmark` | `BookmarkDao.toggle(userId, postId)` | 북마크 아이콘 |
| **P-04 내 메모** | `GET /posts?filter=my` | `PostDao.getMyPosts(userId)` | 화면 진입 |
| **P-05 북마크** | `GET /posts?filter=bookmarks` | `PostDao.getBookmarkedPosts(userId)` | 화면 진입 |
| **P-06 프로필** | `GET /users/me` | `UserDao.getById(userId)` + `PostDao.countByUser()` 등 | 화면 진입 |
| | `PUT /users/me` | `UserDao.update(user)` | 프로필 수정 |
| | `POST /users/me/photo` | (로컬 파일 저장) | 사진 변경 |
| | `PUT /users/me/settings` | `UserSettingsDao.update(settings)` | 푸시 토글 |
| | `POST /auth/logout` | DataStore 초기화 | 로그아웃 |
| **P-07 글 작성** | `POST /posts` | `PostDao.insert(post)` + `TagDao.insertAll()` | 저장 버튼 |
| **P-07 글 수정** | `PUT /posts/{id}` | `PostDao.update(post)` | 저장 버튼 |
| **P-08 상세** | `GET /posts/{id}` | `PostDao.getById(id)` + `CommentDao.getByPostId(id)` | 화면 진입 |
| | `POST /posts/{id}/comments` | `CommentDao.insert(comment)` + `NotificationDao.insert()` | 댓글 등록 |
| | `POST /posts/{id}/read` | `ReadReceiptDao.insert()` + `CommentDao.insert(status)` | 확인 완료 |
| | `DELETE /posts/{id}` | `PostDao.softDelete(id)` | 삭제 버튼 |
| **P-09 알림** | `GET /notifications` | `NotificationDao.getByUserId(userId)` | 패널 열기 |
| | `PUT /notifications/{id}/read` | `NotificationDao.markAsRead(id)` | 알림 클릭 |
| | `PUT /notifications/read-all` | `NotificationDao.markAllAsRead(userId)` | 모두 읽음 |

---

## 12. Retrofit ApiService 인터페이스 (Phase 2 참조)

> Phase 2 전환 시 아래 인터페이스를 구현하여 RemoteDataSource로 사용.

```kotlin
interface WismApiService {

    // Auth
    @POST("auth/login")
    suspend fun login(@Body request: LoginRequest): ApiResponse<LoginData>

    @POST("auth/logout")
    suspend fun logout(@Body request: LogoutRequest): ApiResponse<MessageData>

    // Dashboard
    @GET("dashboard")
    suspend fun getDashboard(): ApiResponse<DashboardData>

    // Posts
    @GET("posts")
    suspend fun getPosts(
        @Query("page") page: Int = 1,
        @Query("limit") limit: Int = 20,
        @Query("search") search: String? = null,
        @Query("category") category: String? = null,
        @Query("priority") priority: String? = null,
        @Query("filter") filter: String? = null
    ): ApiResponse<PostListData>

    @GET("posts/{id}")
    suspend fun getPost(@Path("id") id: Int): ApiResponse<PostDetailData>

    @POST("posts")
    suspend fun createPost(@Body request: CreatePostRequest): ApiResponse<CreatePostData>

    @PUT("posts/{id}")
    suspend fun updatePost(@Path("id") id: Int, @Body request: UpdatePostRequest): ApiResponse<MessageData>

    @DELETE("posts/{id}")
    suspend fun deletePost(@Path("id") id: Int): ApiResponse<MessageData>

    // Comments
    @POST("posts/{postId}/comments")
    suspend fun createComment(@Path("postId") postId: Int, @Body request: CreateCommentRequest): ApiResponse<CommentData>

    // Read Receipts
    @POST("posts/{postId}/read")
    suspend fun markAsRead(@Path("postId") postId: Int): ApiResponse<ReadReceiptData>

    // Bookmarks
    @POST("posts/{postId}/bookmark")
    suspend fun toggleBookmark(@Path("postId") postId: Int): ApiResponse<BookmarkData>

    // Notifications
    @GET("notifications")
    suspend fun getNotifications(
        @Query("page") page: Int = 1,
        @Query("limit") limit: Int = 50
    ): ApiResponse<NotificationListData>

    @PUT("notifications/{id}/read")
    suspend fun markNotificationAsRead(@Path("id") id: Int): ApiResponse<UnreadCountData>

    @PUT("notifications/read-all")
    suspend fun markAllNotificationsAsRead(): ApiResponse<UnreadCountData>

    // Users
    @GET("users/me")
    suspend fun getMyProfile(): ApiResponse<UserProfileData>

    @PUT("users/me")
    suspend fun updateProfile(@Body request: UpdateProfileRequest): ApiResponse<MessageData>

    @Multipart
    @POST("users/me/photo")
    suspend fun uploadPhoto(@Part photo: MultipartBody.Part): ApiResponse<PhotoData>

    @PUT("users/me/settings")
    suspend fun updateSettings(@Body request: UpdateSettingsRequest): ApiResponse<SettingsData>

    // FCM
    @POST("fcm/token")
    suspend fun registerFcmToken(@Body request: FcmTokenRequest): ApiResponse<MessageData>
}
```
