package com.wintek.wism.ui.screens.calendar

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.ChevronLeft
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
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
import com.wintek.wism.ui.screens.dashboard.Badge
import com.wintek.wism.ui.screens.dashboard.getCategoryColor
import com.wintek.wism.ui.theme.Background
import com.wintek.wism.ui.theme.Border
import com.wintek.wism.ui.theme.Primary
import com.wintek.wism.ui.theme.PrimaryLight
import com.wintek.wism.ui.theme.Surface
import com.wintek.wism.ui.theme.TextOnPrimary
import com.wintek.wism.ui.theme.TextSecondary
import com.wintek.wism.ui.theme.Urgent
import com.wintek.wism.ui.theme.WismTheme
import com.wintek.wism.viewmodel.PostViewModel
import java.time.DayOfWeek
import java.time.LocalDate
import java.time.YearMonth
import java.time.format.TextStyle
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CalendarScreen(
    onBack: () -> Unit = {},
    onPostClick: (Int) -> Unit = {},
    viewModel: PostViewModel = hiltViewModel()
) {
    val state by viewModel.listState.collectAsState()

    LaunchedEffect(Unit) {
        viewModel.loadPosts(sortByPriority = false)
    }

    CalendarContent(
        posts = state.posts,
        onBack = onBack,
        onPostClick = onPostClick
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun CalendarContent(
    posts: List<Post>,
    onBack: () -> Unit = {},
    onPostClick: (Int) -> Unit = {}
) {
    var currentMonth by remember { mutableStateOf(YearMonth.now()) }
    var selectedDate by remember { mutableStateOf<LocalDate?>(LocalDate.now()) }

    // 날짜별 게시글 매핑
    val postsByDate = remember(posts) {
        posts.groupBy { post ->
            try {
                LocalDate.parse(post.createdAt.substringBefore("T"))
            } catch (_: Exception) {
                null
            }
        }.filterKeys { it != null }.mapKeys { it.key!! }
    }

    val selectedPosts = selectedDate?.let { postsByDate[it] } ?: emptyList()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("캘린더") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "뒤로")
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
            // 달력
            CalendarGrid(
                yearMonth = currentMonth,
                selectedDate = selectedDate,
                postsByDate = postsByDate,
                onPrevMonth = { currentMonth = currentMonth.minusMonths(1) },
                onNextMonth = { currentMonth = currentMonth.plusMonths(1) },
                onDateClick = { selectedDate = it }
            )

            Spacer(modifier = Modifier.height(8.dp))

            // 선택된 날짜의 메모 목록
            if (selectedDate != null) {
                Text(
                    text = "${selectedDate!!.monthValue}월 ${selectedDate!!.dayOfMonth}일 일정 (${selectedPosts.size}건)",
                    style = MaterialTheme.typography.titleMedium,
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
                )

                if (selectedPosts.isNotEmpty()) {
                    LazyColumn(
                        modifier = Modifier.padding(horizontal = 16.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        items(selectedPosts, key = { it.id }) { post ->
                            CalendarPostItem(post = post, onClick = { onPostClick(post.id) })
                        }
                    }
                } else {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(32.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            "이 날짜에 등록된 일정이 없습니다",
                            style = MaterialTheme.typography.bodySmall,
                            color = TextSecondary
                        )
                    }
                }
            }
        }
    }
}

// ── 달력 그리드 ──

@Composable
private fun CalendarGrid(
    yearMonth: YearMonth,
    selectedDate: LocalDate?,
    postsByDate: Map<LocalDate, List<Post>>,
    onPrevMonth: () -> Unit,
    onNextMonth: () -> Unit,
    onDateClick: (LocalDate) -> Unit
) {
    val today = LocalDate.now()
    val daysInMonth = yearMonth.lengthOfMonth()
    val firstDayOfWeek = yearMonth.atDay(1).dayOfWeek.value % 7 // 일=0, 월=1, ..., 토=6
    val dayNames = listOf("일", "월", "화", "수", "목", "금", "토")

    Card(
        modifier = Modifier.padding(16.dp),
        colors = CardDefaults.cardColors(containerColor = Background),
        border = CardDefaults.outlinedCardBorder()
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            // 월 헤더
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(onClick = onPrevMonth) {
                    Icon(Icons.Default.ChevronLeft, contentDescription = "이전 달")
                }
                Text(
                    text = "${yearMonth.year}년 ${yearMonth.monthValue}월",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold
                )
                IconButton(onClick = onNextMonth) {
                    Icon(Icons.Default.ChevronRight, contentDescription = "다음 달")
                }
            }

            Spacer(modifier = Modifier.height(8.dp))

            // 요일 헤더
            Row(modifier = Modifier.fillMaxWidth()) {
                dayNames.forEach { day ->
                    Text(
                        text = day,
                        style = MaterialTheme.typography.labelSmall,
                        color = TextSecondary,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.weight(1f)
                    )
                }
            }

            Spacer(modifier = Modifier.height(4.dp))

            // 날짜 그리드
            val totalCells = firstDayOfWeek + daysInMonth
            val rows = (totalCells + 6) / 7

            for (row in 0 until rows) {
                Row(modifier = Modifier.fillMaxWidth()) {
                    for (col in 0 until 7) {
                        val cellIndex = row * 7 + col
                        val day = cellIndex - firstDayOfWeek + 1

                        if (day in 1..daysInMonth) {
                            val date = yearMonth.atDay(day)
                            val isToday = date == today
                            val isSelected = date == selectedDate
                            val hasPosts = postsByDate.containsKey(date)
                            val hasUrgent = postsByDate[date]?.any { it.priority == Priority.URGENT } == true

                            DayCell(
                                modifier = Modifier.weight(1f),
                                day = day,
                                isToday = isToday,
                                isSelected = isSelected,
                                hasPosts = hasPosts,
                                hasUrgent = hasUrgent,
                                onClick = { onDateClick(date) }
                            )
                        } else {
                            Box(modifier = Modifier.weight(1f).aspectRatio(1f))
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun DayCell(
    modifier: Modifier = Modifier,
    day: Int,
    isToday: Boolean,
    isSelected: Boolean,
    hasPosts: Boolean,
    hasUrgent: Boolean,
    onClick: () -> Unit
) {
    Box(
        modifier = modifier
            .aspectRatio(1f)
            .clip(CircleShape)
            .then(
                when {
                    isSelected -> Modifier.background(Primary)
                    isToday -> Modifier.background(PrimaryLight)
                    else -> Modifier
                }
            )
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                text = day.toString(),
                style = MaterialTheme.typography.bodySmall,
                color = when {
                    isSelected -> TextOnPrimary
                    isToday -> Primary
                    else -> MaterialTheme.colorScheme.onSurface
                },
                fontWeight = if (isToday || isSelected) FontWeight.Bold else FontWeight.Normal
            )
            // 일정 인디케이터
            if (hasPosts) {
                Box(
                    modifier = Modifier
                        .size(4.dp)
                        .clip(CircleShape)
                        .background(
                            when {
                                isSelected -> TextOnPrimary
                                hasUrgent -> Urgent
                                else -> Primary
                            }
                        )
                )
            }
        }
    }
}

// ── 선택된 날짜의 게시글 아이템 ──

@Composable
private fun CalendarPostItem(
    post: Post,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(8.dp))
            .background(Surface)
            .clickable(onClick = onClick)
            .padding(12.dp),
        verticalAlignment = Alignment.Top
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                Badge(
                    text = post.priority.label,
                    backgroundColor = if (post.priority == Priority.URGENT) Urgent else Primary,
                    textColor = TextOnPrimary
                )
                Badge(
                    text = post.category.label,
                    textColor = getCategoryColor(post.category),
                    outlined = true
                )
                post.project?.let {
                    Badge(text = it, backgroundColor = Surface, textColor = TextSecondary)
                }
            }

            Spacer(modifier = Modifier.height(6.dp))

            Text(
                text = post.title,
                style = MaterialTheme.typography.bodyMedium,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis
            )

            Spacer(modifier = Modifier.height(4.dp))

            Text(
                text = "${post.author.name} · ${post.createdAt.substringAfter("T").take(5)}",
                style = MaterialTheme.typography.labelSmall,
                color = TextSecondary
            )
        }
    }
}

// ── Preview ──

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun CalendarScreenPreview() {
    WismTheme {
        CalendarContent(
            posts = listOf(
                Post(
                    id = 1, title = "3월 월간회의", content = "회의 안건",
                    category = Category.SCHEDULE, priority = Priority.NORMAL,
                    author = Author(1, "김팀장"),
                    createdAt = "${LocalDate.now()}T10:00:00", updatedAt = "${LocalDate.now()}T10:00:00"
                ),
                Post(
                    id = 2, title = "서버 장애 긴급 보고", content = "서버 다운",
                    category = Category.ISSUE, priority = Priority.URGENT,
                    author = Author(2, "박팀장"),
                    createdAt = "${LocalDate.now()}T14:30:00", updatedAt = "${LocalDate.now()}T14:30:00"
                )
            )
        )
    }
}
