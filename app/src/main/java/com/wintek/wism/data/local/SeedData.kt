package com.wintek.wism.data.local

import com.wintek.wism.data.local.entity.*
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

object SeedData {

    private val now = LocalDateTime.now()
    private val fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss")

    fun users(): List<UserEntity> = listOf(
        UserEntity(id = 1, loginId = "kim.team", password = "test1234", name = "김팀장",
            department = "XR개발실 1팀", position = "팀장", email = "kim@wintek.co.kr",
            phone = "010-1111-1111", role = "manager", createdAt = ts(-30), updatedAt = ts(-30)),
        UserEntity(id = 2, loginId = "park.team", password = "test1234", name = "박팀장",
            department = "XR개발실 2팀", position = "팀장", email = "park@wintek.co.kr",
            phone = "010-2222-2222", role = "manager", createdAt = ts(-30), updatedAt = ts(-30)),
        UserEntity(id = 3, loginId = "lee.team", password = "test1234", name = "이팀장",
            department = "XR개발실 3팀", position = "팀장", email = "lee@wintek.co.kr",
            phone = "010-3333-3333", role = "manager", createdAt = ts(-30), updatedAt = ts(-30)),
        UserEntity(id = 4, loginId = "choi.dir", password = "test1234", name = "최이사",
            department = "경영지원실", position = "이사", email = "choi@wintek.co.kr",
            phone = "010-4444-4444", role = "admin", createdAt = ts(-30), updatedAt = ts(-30)),
        UserEntity(id = 5, loginId = "shin.team", password = "test1234", name = "신팀장",
            department = "XR개발실 3팀", position = "대리", email = "shin@wintek.co.kr",
            phone = "010-5555-5555", role = "manager", createdAt = ts(-30), updatedAt = ts(-30))
    )

    fun posts(): List<PostEntity> = listOf(
        PostEntity(id = 1, userId = 2, category = "issue", priority = "urgent",
            title = "서버 장애 긴급 보고", content = "오전 10시경 메인 서버 다운 발생. 현재 복구 작업 진행 중이며, 예상 복구 시간은 오후 2시입니다. 관련 부서 긴급 대응 부탁드립니다.",
            project = "인프라", createdAt = ts(-2), updatedAt = ts(-2)),
        PostEntity(id = 2, userId = 2, category = "issue", priority = "urgent",
            title = "A프로젝트 납기 변경 긴급 공유", content = "오전 10시 클라이언트로부터 납기 변경 요청이 들어왔습니다. 기존 4월 말에서 4월 15일로 2주 앞당겨졌습니다. 각 팀별 일정 재조정 필요합니다.",
            project = "A프로젝트", createdAt = ts(-1), updatedAt = ts(-1)),
        PostEntity(id = 3, userId = 1, category = "schedule", priority = "normal",
            title = "3월 월간회의", content = "3월 월간회의를 다음과 같이 진행합니다.\n\n일시: 3월 25일(화) 오전 10시\n장소: 본사 3층 대회의실\n안건: 1분기 실적 리뷰, 2분기 계획 논의",
            createdAt = ts(0), updatedAt = ts(0)),
        PostEntity(id = 4, userId = 1, category = "schedule", priority = "normal",
            title = "고객사 미팅 일정", content = "B고객사 방문 미팅이 확정되었습니다.\n\n일시: 3월 28일(금) 오후 2시\n장소: B사 판교 오피스\n참석: 김팀장, 박팀장",
            project = "B프로젝트", createdAt = ts(0), updatedAt = ts(0)),
        PostEntity(id = 5, userId = 4, category = "decision", priority = "normal",
            title = "신규 프로젝트 착수 결정", content = "경영회의에서 C프로젝트 착수가 결정되었습니다.\n\n프로젝트명: C프로젝트 (XR 교육 플랫폼)\n착수일: 4월 1일\n담당: XR개발실 3팀\n예산: 별도 공지",
            project = "C프로젝트", createdAt = ts(-3), updatedAt = ts(-3)),
        PostEntity(id = 6, userId = 3, category = "meeting", priority = "normal",
            title = "주간 팀장회의 회의록", content = "금주 팀장회의 회의록입니다.\n\n1. A프로젝트 진행 현황 공유 (박팀장)\n2. 신규 인력 채용 건 (최이사)\n3. 사무실 이전 일정 확인\n\n다음 회의: 3월 29일(금) 오전 9시",
            createdAt = ts(-1), updatedAt = ts(-1)),
        PostEntity(id = 7, userId = 5, category = "other", priority = "normal",
            title = "사무실 이전 안내", content = "4월 중 사무실 이전이 예정되어 있습니다.\n\n이전 예정지: 판교 테크노밸리 2단지\n이전 시기: 4월 중순 (정확한 날짜 추후 공지)\n\n개인 짐 정리 부탁드립니다.",
            createdAt = ts(-5), updatedAt = ts(-5))
    )

    fun comments(): List<CommentEntity> = listOf(
        CommentEntity(id = 1, postId = 1, userId = 1, content = "확인했습니다. 1팀 서버 점검 완료.",
            type = "comment", createdAt = ts(-2, 1), updatedAt = ts(-2, 1)),
        CommentEntity(id = 2, postId = 1, userId = 3, content = "3팀도 영향 범위 확인 중입니다.",
            type = "comment", createdAt = ts(-2, 2), updatedAt = ts(-2, 2)),
        CommentEntity(id = 3, postId = 1, userId = 4, content = "확인 완료",
            type = "status", createdAt = ts(-2, 3), updatedAt = ts(-2, 3)),
        CommentEntity(id = 4, postId = 2, userId = 1, content = "1팀 일정 재조정하겠습니다.",
            type = "comment", createdAt = ts(-1, 1), updatedAt = ts(-1, 1)),
        CommentEntity(id = 5, postId = 2, userId = 3, content = "3팀도 확인했습니다.",
            type = "comment", createdAt = ts(-1, 2), updatedAt = ts(-1, 2)),
        CommentEntity(id = 6, postId = 3, userId = 2, content = "참석 확인합니다.",
            type = "comment", createdAt = ts(0, 1), updatedAt = ts(0, 1)),
        CommentEntity(id = 7, postId = 5, userId = 5, content = "3팀 준비하겠습니다.",
            type = "comment", createdAt = ts(-3, 1), updatedAt = ts(-3, 1))
    )

    fun tags(): List<TagEntity> = listOf(
        TagEntity(id = 1, name = "김팀장", createdAt = ts(-5)),
        TagEntity(id = 2, name = "박팀장", createdAt = ts(-5)),
        TagEntity(id = 3, name = "이팀장", createdAt = ts(-5)),
        TagEntity(id = 4, name = "최이사", createdAt = ts(-5)),
        TagEntity(id = 5, name = "신팀장", createdAt = ts(-5))
    )

    fun postTags(): List<PostTagCrossRef> = listOf(
        PostTagCrossRef(postId = 1, tagId = 1),
        PostTagCrossRef(postId = 1, tagId = 3),
        PostTagCrossRef(postId = 2, tagId = 1),
        PostTagCrossRef(postId = 2, tagId = 3),
        PostTagCrossRef(postId = 5, tagId = 5)
    )

    fun bookmarks(): List<BookmarkEntity> = listOf(
        BookmarkEntity(userId = 1, postId = 1, createdAt = ts(-1)),
        BookmarkEntity(userId = 1, postId = 5, createdAt = ts(-2)),
        BookmarkEntity(userId = 5, postId = 2, createdAt = ts(-1)),
        BookmarkEntity(userId = 5, postId = 3, createdAt = ts(0))
    )

    fun readReceipts(): List<ReadReceiptEntity> = listOf(
        ReadReceiptEntity(userId = 1, postId = 1, readAt = ts(-2, 1)),
        ReadReceiptEntity(userId = 3, postId = 1, readAt = ts(-2, 2)),
        ReadReceiptEntity(userId = 4, postId = 1, readAt = ts(-2, 3)),
        ReadReceiptEntity(userId = 1, postId = 2, readAt = ts(-1, 1)),
        ReadReceiptEntity(userId = 3, postId = 2, readAt = ts(-1, 2)),
        ReadReceiptEntity(userId = 2, postId = 3, readAt = ts(0, 1))
    )

    fun notifications(): List<NotificationEntity> = listOf(
        NotificationEntity(id = 1, userId = 1, type = "urgent", title = "긴급 이슈",
            content = "새로운 긴급 이슈가 등록되었습니다.", memoTitle = "서버 장애 긴급 보고",
            postId = 1, senderId = 2, createdAt = ts(-2)),
        NotificationEntity(id = 2, userId = 5, type = "urgent", title = "긴급 이슈",
            content = "새로운 긴급 이슈가 등록되었습니다.", memoTitle = "A프로젝트 납기 변경 긴급 공유",
            postId = 2, senderId = 2, createdAt = ts(-1)),
        NotificationEntity(id = 3, userId = 2, type = "comment", title = "새 댓글",
            content = "김팀장님이 댓글을 남겼습니다.", memoTitle = "서버 장애 긴급 보고",
            postId = 1, senderId = 1, createdAt = ts(-2, 1)),
        NotificationEntity(id = 4, userId = 2, type = "status", title = "확인 완료",
            content = "최이사님이 확인 완료했습니다.", memoTitle = "서버 장애 긴급 보고",
            postId = 1, senderId = 4, isRead = true, createdAt = ts(-2, 3)),
        NotificationEntity(id = 5, userId = 5, type = "mention", title = "멘션",
            content = "신규 프로젝트 착수 결정에서 멘션되었습니다.", memoTitle = "신규 프로젝트 착수 결정",
            postId = 5, senderId = 4, createdAt = ts(-3))
    )

    fun userSettings(): List<UserSettingsEntity> = listOf(
        UserSettingsEntity(id = 1, userId = 1, createdAt = ts(-30), updatedAt = ts(-30)),
        UserSettingsEntity(id = 2, userId = 2, createdAt = ts(-30), updatedAt = ts(-30)),
        UserSettingsEntity(id = 3, userId = 3, createdAt = ts(-30), updatedAt = ts(-30)),
        UserSettingsEntity(id = 4, userId = 4, createdAt = ts(-30), updatedAt = ts(-30)),
        UserSettingsEntity(id = 5, userId = 5, createdAt = ts(-30), updatedAt = ts(-30))
    )

    private fun ts(dayOffset: Int, hourOffset: Int = 0): String =
        now.plusDays(dayOffset.toLong()).plusHours(hourOffset.toLong()).format(fmt)
}
