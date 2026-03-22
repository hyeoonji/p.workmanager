package com.wintek.wism.ui.screens.memo

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.ChatBubbleOutline
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.RemoveRedEye
import androidx.compose.material.icons.filled.Send
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.wintek.wism.data.model.Author
import com.wintek.wism.data.model.Category
import com.wintek.wism.data.model.Comment
import com.wintek.wism.data.model.Post
import com.wintek.wism.data.model.Priority
import com.wintek.wism.ui.screens.dashboard.Badge
import com.wintek.wism.ui.screens.dashboard.getCategoryColor
import com.wintek.wism.ui.theme.Background
import com.wintek.wism.ui.theme.Border
import com.wintek.wism.ui.theme.InputBackground
import com.wintek.wism.ui.theme.Primary
import com.wintek.wism.ui.theme.PrimaryLight
import com.wintek.wism.ui.theme.Success
import com.wintek.wism.ui.theme.Surface
import com.wintek.wism.ui.theme.TextOnPrimary
import com.wintek.wism.ui.theme.TextSecondary
import com.wintek.wism.ui.theme.Urgent
import com.wintek.wism.ui.theme.WismTheme

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MemoDetailScreen(
    postId: Int,
    onBack: () -> Unit = {},
    onEdit: () -> Unit = {}
) {
    // TODO: ViewModel 연동. 지금은 프리뷰용 더미 데이터
    val post = previewDetailPost()
    var commentText by remember { mutableStateOf("") }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {},
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "뒤로")
                    }
                },
                actions = {
                    IconButton(onClick = { /* TODO: 수정/삭제 메뉴 */ }) {
                        Icon(Icons.Default.MoreVert, contentDescription = "더보기")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Background)
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
        ) {
            Column(
                modifier = Modifier
                    .weight(1f)
                    .verticalScroll(rememberScrollState())
                    .padding(16.dp)
            ) {
                // 배지
                Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                    Badge(
                        text = post.priority.label,
                        backgroundColor = if (post.priority == Priority.URGENT) Urgent else Primary,
                        textColor = TextOnPrimary
                    )
                    Badge(text = post.category.label, textColor = getCategoryColor(post.category), outlined = true)
                    post.project?.let { Badge(text = it, backgroundColor = Surface, textColor = TextSecondary) }
                }

                Spacer(modifier = Modifier.height(12.dp))

                // 제목
                Text(post.title, style = MaterialTheme.typography.titleLarge)

                Spacer(modifier = Modifier.height(8.dp))

                // 작성자 정보
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        modifier = Modifier.size(28.dp).clip(CircleShape).background(PrimaryLight),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(Icons.Default.Person, null, Modifier.size(16.dp), tint = Primary)
                    }
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(post.author.name, style = MaterialTheme.typography.bodyMedium)
                }

                // 메타
                Row(
                    modifier = Modifier.padding(top = 4.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(post.createdAt.substringBefore("T"), style = MaterialTheme.typography.labelSmall, color = TextSecondary)
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.RemoveRedEye, null, Modifier.size(12.dp), tint = TextSecondary)
                        Spacer(Modifier.width(2.dp))
                        Text("${post.readBy}/${post.totalReaders}", style = MaterialTheme.typography.labelSmall, color = TextSecondary)
                    }
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.ChatBubbleOutline, null, Modifier.size(12.dp), tint = TextSecondary)
                        Spacer(Modifier.width(2.dp))
                        Text("${post.comments.size}", style = MaterialTheme.typography.labelSmall, color = TextSecondary)
                    }
                }

                // 태그
                if (post.tags.isNotEmpty()) {
                    Spacer(modifier = Modifier.height(8.dp))
                    Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                        Text("담당자:", style = MaterialTheme.typography.labelSmall, color = TextSecondary)
                        post.tags.forEach { tag ->
                            Badge(text = "@$tag", textColor = TextSecondary, outlined = true)
                        }
                    }
                }

                HorizontalDivider(modifier = Modifier.padding(vertical = 16.dp))

                // 본문
                Text(post.content, style = MaterialTheme.typography.bodyMedium)

                HorizontalDivider(modifier = Modifier.padding(vertical = 16.dp))

                // 확인 완료 버튼
                OutlinedButton(
                    onClick = { /* TODO: markAsRead */ },
                    shape = RoundedCornerShape(10.dp)
                ) {
                    Icon(Icons.Default.CheckCircle, null, Modifier.size(16.dp))
                    Spacer(Modifier.width(8.dp))
                    Text("확인 완료")
                }

                HorizontalDivider(modifier = Modifier.padding(vertical = 16.dp))

                // 댓글 섹션
                Text("댓글 (${post.comments.size})", style = MaterialTheme.typography.titleMedium)
                Spacer(modifier = Modifier.height(12.dp))

                if (post.comments.isNotEmpty()) {
                    post.comments.forEach { comment ->
                        CommentItem(comment)
                        Spacer(modifier = Modifier.height(8.dp))
                    }
                } else {
                    Text(
                        "아직 댓글이 없습니다",
                        style = MaterialTheme.typography.bodySmall,
                        color = TextSecondary,
                        modifier = Modifier.fillMaxWidth().padding(vertical = 16.dp),
                        textAlign = androidx.compose.ui.text.style.TextAlign.Center
                    )
                }
            }

            // 댓글 입력
            HorizontalDivider()
            Row(
                modifier = Modifier.fillMaxWidth().padding(12.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                OutlinedTextField(
                    value = commentText,
                    onValueChange = { commentText = it },
                    placeholder = { Text("댓글을 입력하세요...", color = TextSecondary) },
                    modifier = Modifier.weight(1f),
                    singleLine = true,
                    shape = RoundedCornerShape(10.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        unfocusedContainerColor = InputBackground,
                        focusedContainerColor = InputBackground
                    )
                )
                IconButton(
                    onClick = { /* TODO: 댓글 전송 */ commentText = "" },
                    enabled = commentText.isNotBlank()
                ) {
                    Icon(Icons.Default.Send, contentDescription = "전송", tint = if (commentText.isNotBlank()) Primary else TextSecondary)
                }
            }
        }
    }
}

@Composable
private fun CommentItem(comment: Comment) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(8.dp))
            .background(Surface)
            .padding(10.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Box(
            modifier = Modifier.size(28.dp).clip(CircleShape).background(PrimaryLight),
            contentAlignment = Alignment.Center
        ) {
            Text(comment.author.name.first().toString(), style = MaterialTheme.typography.labelSmall, color = Primary)
        }
        Column(modifier = Modifier.weight(1f)) {
            Row(horizontalArrangement = Arrangement.spacedBy(6.dp), verticalAlignment = Alignment.CenterVertically) {
                Text(comment.author.name, style = MaterialTheme.typography.labelSmall)
                Text(comment.createdAt.substringAfter("T").take(5), style = MaterialTheme.typography.labelSmall, color = TextSecondary)
                if (comment.type == "status") {
                    Badge(text = "확인완료", backgroundColor = Success.copy(alpha = 0.15f), textColor = Success)
                }
            }
            Spacer(modifier = Modifier.height(2.dp))
            Text(comment.content, style = MaterialTheme.typography.bodySmall)
        }
    }
}

private fun previewDetailPost() = Post(
    id = 1, title = "서버 장애 긴급 보고",
    content = "오전 10시경 메인 서버 다운 발생. 현재 복구 작업 진행 중이며, 예상 복구 시간은 오후 2시입니다.\n\n관련 부서 긴급 대응 부탁드립니다.",
    category = Category.ISSUE, priority = Priority.URGENT,
    author = Author(2, "박팀장", "XR개발실 2팀", "팀장"),
    project = "인프라", tags = listOf("김팀장", "이팀장"),
    commentCount = 3, readBy = 3, totalReaders = 5,
    comments = listOf(
        Comment(1, Author(1, "김팀장"), "확인했습니다. 1팀 서버 점검 완료.", "comment", "2025-03-22T11:00:00"),
        Comment(2, Author(3, "이팀장"), "3팀도 영향 범위 확인 중입니다.", "comment", "2025-03-22T12:00:00"),
        Comment(3, Author(4, "최이사"), "확인 완료", "status", "2025-03-22T13:00:00")
    ),
    createdAt = "2025-03-22T10:30:00", updatedAt = "2025-03-22T10:30:00"
)

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun MemoDetailScreenPreview() {
    WismTheme { MemoDetailScreen(postId = 1) }
}
