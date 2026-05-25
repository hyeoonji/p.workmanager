package com.wintek.wism.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Bookmark
import androidx.compose.material.icons.filled.BookmarkBorder
import androidx.compose.material.icons.filled.ChatBubbleOutline
import androidx.compose.material.icons.filled.RemoveRedEye
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.wintek.wism.data.model.Author
import com.wintek.wism.data.model.Category
import com.wintek.wism.data.model.Post
import com.wintek.wism.data.model.Priority
import com.wintek.wism.ui.screens.dashboard.getCategoryColor
import com.wintek.wism.ui.theme.Background
import com.wintek.wism.ui.theme.Border
import com.wintek.wism.ui.theme.Primary
import com.wintek.wism.ui.theme.Surface
import com.wintek.wism.ui.theme.TextOnPrimary
import com.wintek.wism.ui.theme.TextSecondary
import com.wintek.wism.ui.theme.Urgent
import com.wintek.wism.ui.theme.UrgentLight
import com.wintek.wism.ui.theme.WismTheme

@Composable
fun MemoCard(
    post: Post,
    onClick: () -> Unit,
    onToggleBookmark: (Int) -> Unit
) {
    val isUrgent = post.priority == Priority.URGENT
    val isUnread = post.readBy < post.totalReaders

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .then(
                if (isUnread) Modifier.border(
                    width = 2.dp,
                    color = Primary,
                    shape = RoundedCornerShape(12.dp)
                ) else Modifier
            ),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(
            containerColor = if (isUrgent) UrgentLight else Background
        ),
        border = if (!isUnread) CardDefaults.outlinedCardBorder() else null
    ) {
        Row(
            modifier = Modifier.padding(12.dp),
            verticalAlignment = Alignment.Top
        ) {
            // 왼쪽: 콘텐츠
            Column(modifier = Modifier.weight(1f)) {
                // 배지 행
                Row(
                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    MemoCardBadge(
                        text = post.priority.label,
                        backgroundColor = if (isUrgent) Urgent else Primary,
                        textColor = TextOnPrimary
                    )
                    MemoCardBadge(
                        text = post.category.label,
                        textColor = getCategoryColor(post.category),
                        outlined = true
                    )
                    post.project?.let {
                        MemoCardBadge(
                            text = it,
                            backgroundColor = Surface,
                            textColor = TextSecondary
                        )
                    }
                }

                Spacer(modifier = Modifier.height(8.dp))

                // 제목
                Text(
                    text = post.title,
                    style = MaterialTheme.typography.bodyMedium,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )

                // 내용 미리보기
                if (post.content.isNotBlank()) {
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = post.content,
                        style = MaterialTheme.typography.bodySmall,
                        color = TextSecondary,
                        maxLines = 2,
                        overflow = TextOverflow.Ellipsis
                    )
                }

                // 태그(분류) + 참조(사람)
                if (post.tags.isNotEmpty() || post.references.isNotEmpty()) {
                    Spacer(modifier = Modifier.height(6.dp))
                    Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                        post.tags.forEach { tag ->
                            MemoCardBadge(text = "#$tag", textColor = TextSecondary, outlined = true)
                        }
                        post.references.forEach { person ->
                            MemoCardBadge(text = "@${person.name}", textColor = Primary, outlined = true)
                        }
                    }
                }

                Spacer(modifier = Modifier.height(8.dp))

                // 하단 메타 정보
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        text = post.author.name,
                        style = MaterialTheme.typography.labelSmall,
                        color = TextSecondary
                    )
                    Text("·", style = MaterialTheme.typography.labelSmall, color = TextSecondary)
                    Text(
                        text = formatDate(post.createdAt),
                        style = MaterialTheme.typography.labelSmall,
                        color = TextSecondary
                    )

                    // 읽음
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            Icons.Default.RemoveRedEye,
                            contentDescription = null,
                            modifier = Modifier.size(12.dp),
                            tint = TextSecondary
                        )
                        Spacer(modifier = Modifier.width(2.dp))
                        Text(
                            "${post.readBy}/${post.totalReaders}",
                            style = MaterialTheme.typography.labelSmall,
                            color = TextSecondary
                        )
                    }

                    // 댓글
                    if (post.commentCount > 0) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(
                                Icons.Default.ChatBubbleOutline,
                                contentDescription = null,
                                modifier = Modifier.size(12.dp),
                                tint = TextSecondary
                            )
                            Spacer(modifier = Modifier.width(2.dp))
                            Text(
                                "${post.commentCount}",
                                style = MaterialTheme.typography.labelSmall,
                                color = TextSecondary
                            )
                        }
                    }
                }
            }

            // 오른쪽: 북마크 버튼
            IconButton(
                onClick = { onToggleBookmark(post.id) },
                modifier = Modifier.size(32.dp)
            ) {
                Icon(
                    imageVector = if (post.isBookmarked) Icons.Default.Bookmark else Icons.Default.BookmarkBorder,
                    contentDescription = "북마크",
                    tint = if (post.isBookmarked) Primary else TextSecondary,
                    modifier = Modifier.size(18.dp)
                )
            }
        }
    }
}

@Composable
private fun MemoCardBadge(
    text: String,
    backgroundColor: Color = Color.Transparent,
    textColor: Color,
    outlined: Boolean = false
) {
    val shape = RoundedCornerShape(4.dp)
    Box(
        modifier = Modifier
            .clip(shape)
            .then(
                if (outlined) Modifier.border(1.dp, Border, shape)
                else Modifier.background(backgroundColor)
            )
            .padding(horizontal = 6.dp, vertical = 2.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = text,
            style = MaterialTheme.typography.labelSmall.copy(fontWeight = FontWeight.Medium),
            color = textColor
        )
    }
}

private fun formatDate(isoDate: String): String {
    return try {
        val date = isoDate.substringBefore("T")
        val parts = date.split("-")
        if (parts.size == 3) "${parts[1]}.${parts[2]}" else date
    } catch (_: Exception) {
        isoDate
    }
}

// ── Preview ──

@Preview(showBackground = true)
@Composable
private fun MemoCardPreview() {
    WismTheme {
        Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            MemoCard(
                post = Post(
                    id = 1, title = "서버 장애 긴급 보고",
                    content = "오전 10시경 메인 서버 다운 발생. 현재 복구 작업 진행 중이며 예상 복구 시간은 오후 2시입니다.",
                    category = Category.ISSUE, priority = Priority.URGENT,
                    author = Author(1, "박팀장", "XR개발실 2팀"),
                    project = "인프라", tags = listOf("김팀장", "이팀장"),
                    commentCount = 7, readBy = 3, totalReaders = 5,
                    isBookmarked = true,
                    createdAt = "2025-03-22T10:30:00", updatedAt = "2025-03-22T10:30:00"
                ),
                onClick = {},
                onToggleBookmark = {}
            )
            MemoCard(
                post = Post(
                    id = 2, title = "3월 월간회의 안건",
                    content = "이번 달 회의 안건을 공유합니다.",
                    category = Category.SCHEDULE, priority = Priority.NORMAL,
                    author = Author(2, "김팀장"),
                    commentCount = 3, readBy = 5, totalReaders = 5,
                    createdAt = "2025-03-22T09:00:00", updatedAt = "2025-03-22T09:00:00"
                ),
                onClick = {},
                onToggleBookmark = {}
            )
        }
    }
}
