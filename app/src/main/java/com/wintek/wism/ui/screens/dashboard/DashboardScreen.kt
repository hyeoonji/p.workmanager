package com.wintek.wism.ui.screens.dashboard

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
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
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CalendarToday
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.TrendingUp
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.wintek.wism.data.model.Author
import com.wintek.wism.data.model.Category
import com.wintek.wism.data.model.Post
import com.wintek.wism.data.model.Priority
import com.wintek.wism.ui.theme.Background
import com.wintek.wism.ui.theme.Border
import com.wintek.wism.ui.theme.CategoryDecision
import com.wintek.wism.ui.theme.CategoryIssue
import com.wintek.wism.ui.theme.CategoryMeeting
import com.wintek.wism.ui.theme.CategoryOther
import com.wintek.wism.ui.theme.CategorySchedule
import com.wintek.wism.ui.theme.TextSecondary
import com.wintek.wism.ui.theme.Primary
import com.wintek.wism.ui.theme.Surface
import com.wintek.wism.ui.theme.Urgent
import com.wintek.wism.ui.theme.UrgentBorder
import com.wintek.wism.ui.theme.TextOnPrimary
import com.wintek.wism.ui.theme.WismTheme
import com.wintek.wism.viewmodel.DashboardViewModel

@Composable
fun DashboardScreen(
    modifier: Modifier = Modifier,
    onPostClick: (Int) -> Unit = {},
    viewModel: DashboardViewModel = hiltViewModel()
) {
    val state by viewModel.state.collectAsState()

    LaunchedEffect(Unit) {
        viewModel.loadDashboard()
    }

    DashboardContent(
        modifier = modifier,
        urgentCount = state.data.urgentCount,
        todayCount = state.data.todayCount,
        myMemoCount = state.data.myMemoCount,
        urgentMemos = state.data.urgentMemos,
        todayMemos = state.data.todayMemos,
        onPostClick = onPostClick
    )
}

@Composable
private fun DashboardContent(
    modifier: Modifier = Modifier,
    urgentCount: Int = 0,
    todayCount: Int = 0,
    myMemoCount: Int = 0,
    urgentMemos: List<Post> = emptyList(),
    todayMemos: List<Post> = emptyList(),
    onPostClick: (Int) -> Unit = {}
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // 3열 통계 카드
        StatsRow(urgentCount, todayCount, myMemoCount)

        // 미확인 긴급 이슈
        if (urgentMemos.isNotEmpty()) {
            SectionCard(
                icon = Icons.Default.Notifications,
                iconTint = Urgent,
                title = "미확인 긴급 이슈",
                borderColor = UrgentBorder
            ) {
                urgentMemos.take(3).forEachIndexed { index, memo ->
                    if (index > 0) Spacer(modifier = Modifier.height(8.dp))
                    MemoItem(memo = memo, onClick = { onPostClick(memo.id) })
                }
            }
        }

        // 오늘의 주요 일정
        SectionCard(
            icon = Icons.Default.CalendarToday,
            iconTint = Primary,
            title = "오늘의 주요 일정"
        ) {
            if (todayMemos.isNotEmpty()) {
                todayMemos.forEachIndexed { index, memo ->
                    if (index > 0) Spacer(modifier = Modifier.height(8.dp))
                    MemoItem(memo = memo, onClick = { onPostClick(memo.id) })
                }
            } else {
                Text(
                    text = "오늘 등록된 일정이 없습니다",
                    style = MaterialTheme.typography.bodySmall,
                    color = TextSecondary,
                    modifier = Modifier.fillMaxWidth().padding(vertical = 16.dp),
                    textAlign = TextAlign.Center
                )
            }
        }
    }
}

// ── 3열 통계 카드 ──

@Composable
private fun StatsRow(urgentCount: Int, todayCount: Int, myMemoCount: Int) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        StatCard(Modifier.weight(1f), Icons.Default.Notifications, "긴급", urgentCount, Urgent)
        StatCard(Modifier.weight(1f), Icons.Default.CalendarToday, "오늘", todayCount, Primary)
        StatCard(Modifier.weight(1f), Icons.Default.TrendingUp, "내메모", myMemoCount, Primary)
    }
}

@Composable
private fun StatCard(
    modifier: Modifier,
    icon: ImageVector,
    label: String,
    count: Int,
    countColor: Color
) {
    Card(
        modifier = modifier,
        colors = CardDefaults.cardColors(containerColor = Background),
        border = CardDefaults.outlinedCardBorder()
    ) {
        Column(
            modifier = Modifier.fillMaxWidth().padding(12.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Icon(icon, contentDescription = label, modifier = Modifier.size(20.dp), tint = TextSecondary)
            Text(label, style = MaterialTheme.typography.labelSmall, color = TextSecondary)
            Text(count.toString(), style = MaterialTheme.typography.headlineMedium, color = countColor)
        }
    }
}

// ── 섹션 카드 ──

@Composable
private fun SectionCard(
    icon: ImageVector,
    iconTint: Color,
    title: String,
    borderColor: Color = Border,
    content: @Composable () -> Unit
) {
    Card(
        colors = CardDefaults.cardColors(containerColor = Background),
        border = CardDefaults.outlinedCardBorder().copy(
            brush = androidx.compose.ui.graphics.SolidColor(borderColor)
        )
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Icon(icon, contentDescription = null, modifier = Modifier.size(16.dp), tint = iconTint)
                Text(title, style = MaterialTheme.typography.titleMedium)
            }
            Spacer(modifier = Modifier.height(12.dp))
            content()
        }
    }
}

// ── 메모 아이템 ──

@Composable
private fun MemoItem(memo: Post, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(8.dp))
            .background(Surface)
            .clickable(onClick = onClick)
            .padding(12.dp)
    ) {
        Column(modifier = Modifier.weight(1f)) {
            // 배지
            Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                Badge(
                    text = memo.priority.label,
                    backgroundColor = if (memo.priority == Priority.URGENT) Urgent else Primary,
                    textColor = Background
                )
                Badge(
                    text = memo.category.label,
                    textColor = getCategoryColor(memo.category),
                    outlined = true
                )
            }

            Spacer(modifier = Modifier.height(6.dp))

            // 제목
            Text(
                text = memo.title,
                style = MaterialTheme.typography.bodyMedium,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis
            )

            Spacer(modifier = Modifier.height(4.dp))

            // 작성자
            Text(
                text = memo.author.name,
                style = MaterialTheme.typography.labelSmall,
                color = TextSecondary
            )
        }
    }
}

// ── 배지 ──

@Composable
fun Badge(
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

fun getCategoryColor(category: Category): Color = when (category) {
    Category.SCHEDULE -> CategorySchedule
    Category.ISSUE -> CategoryIssue
    Category.DECISION -> CategoryDecision
    Category.MEETING -> CategoryMeeting
    Category.OTHER -> CategoryOther
}

// ── Preview ──

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun DashboardScreenPreview() {
    WismTheme {
        DashboardContent(
            urgentCount = 2,
            todayCount = 3,
            myMemoCount = 5,
            urgentMemos = listOf(
                previewPost(1, "서버 장애 긴급 보고", Category.ISSUE, Priority.URGENT, "박팀장"),
                previewPost(2, "A프로젝트 납기 변경 긴급 공유", Category.ISSUE, Priority.URGENT, "박팀장")
            ),
            todayMemos = listOf(
                previewPost(3, "3월 월간회의", Category.SCHEDULE, Priority.NORMAL, "김팀장"),
                previewPost(4, "고객사 미팅 일정", Category.SCHEDULE, Priority.NORMAL, "김팀장")
            )
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun DashboardEmptyPreview() {
    WismTheme {
        DashboardContent()
    }
}

private fun previewPost(
    id: Int, title: String, category: Category, priority: Priority, authorName: String
) = Post(
    id = id, title = title, content = "", category = category, priority = priority,
    author = Author(id = 1, name = authorName),
    createdAt = "2025-03-22T10:00:00", updatedAt = "2025-03-22T10:00:00"
)
