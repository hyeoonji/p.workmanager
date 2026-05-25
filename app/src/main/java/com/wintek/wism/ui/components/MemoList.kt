package com.wintek.wism.ui.components

import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.MenuAnchorType
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.wintek.wism.data.model.Author
import com.wintek.wism.data.model.Category
import com.wintek.wism.data.model.Post
import com.wintek.wism.data.model.Priority
import com.wintek.wism.ui.theme.InputBackground
import com.wintek.wism.ui.theme.Primary
import com.wintek.wism.ui.theme.TextSecondary
import com.wintek.wism.ui.theme.WismTheme

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MemoList(
    modifier: Modifier = Modifier,
    posts: List<Post>,
    onPostClick: (Int) -> Unit,
    onToggleBookmark: (Int) -> Unit,
    onSearch: (String) -> Unit = {},
    onCategoryFilter: (String?) -> Unit = {},
    onSortChanged: (Boolean) -> Unit = {},  // true = 우선순위순, false = 최신순
    emptyMessage: String = "메모가 없습니다"
) {
    var searchQuery by remember { mutableStateOf("") }
    var selectedCategory by remember { mutableStateOf<String?>(null) }
    var sortByPriority by remember { mutableStateOf(true) }

    Column(modifier = modifier.fillMaxSize()) {
        // 검색바
        OutlinedTextField(
            value = searchQuery,
            onValueChange = {
                searchQuery = it
                onSearch(it)
            },
            placeholder = { Text("제목·내용·태그 검색...", color = TextSecondary) },
            leadingIcon = {
                Icon(Icons.Default.Search, contentDescription = null, modifier = Modifier.size(18.dp), tint = TextSecondary)
            },
            trailingIcon = {
                if (searchQuery.isNotEmpty()) {
                    IconButton(onClick = {
                        searchQuery = ""
                        onSearch("")
                    }) {
                        Icon(Icons.Default.Close, contentDescription = "지우기", modifier = Modifier.size(18.dp))
                    }
                }
            },
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 8.dp),
            maxLines = 1,
            shape = RoundedCornerShape(10.dp),
            colors = OutlinedTextFieldDefaults.colors(
                unfocusedContainerColor = InputBackground,
                focusedContainerColor = InputBackground
            )
        )

        // 카테고리 탭 (상단 구분)
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .horizontalScroll(rememberScrollState())
                .padding(horizontal = 16.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            FilterChip(
                selected = selectedCategory == null,
                onClick = {
                    selectedCategory = null
                    onCategoryFilter(null)
                },
                label = { Text("전체") }
            )
            Category.entries.forEach { category ->
                FilterChip(
                    selected = selectedCategory == category.value,
                    onClick = {
                        selectedCategory = category.value
                        onCategoryFilter(category.value)
                    },
                    label = { Text(category.label) }
                )
            }
        }

        // 정렬 행
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            FilterDropdown(
                modifier = Modifier.weight(1f),
                label = if (sortByPriority) "우선순위순" else "최신순",
                options = listOf("priority" to "우선순위순", "date" to "최신순"),
                selectedValue = if (sortByPriority) "priority" else "date",
                onSelect = {
                    sortByPriority = it == "priority"
                    onSortChanged(sortByPriority)
                }
            )
        }

        // 결과 카운트
        Text(
            text = "${posts.size}개의 메모",
            style = MaterialTheme.typography.labelSmall,
            color = TextSecondary,
            modifier = Modifier.padding(horizontal = 20.dp, vertical = 8.dp)
        )

        // 메모 리스트
        if (posts.isNotEmpty()) {
            LazyColumn(
                contentPadding = PaddingValues(horizontal = 16.dp, vertical = 4.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                items(posts, key = { it.id }) { post ->
                    MemoCard(
                        post = post,
                        onClick = { onPostClick(post.id) },
                        onToggleBookmark = onToggleBookmark
                    )
                }
            }
        } else {
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = emptyMessage,
                    style = MaterialTheme.typography.bodySmall,
                    color = TextSecondary,
                    textAlign = TextAlign.Center
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun FilterDropdown(
    modifier: Modifier = Modifier,
    label: String,
    options: List<Pair<String, String>>,
    selectedValue: String?,
    onSelect: (String?) -> Unit
) {
    var expanded by remember { mutableStateOf(false) }

    ExposedDropdownMenuBox(
        expanded = expanded,
        onExpandedChange = { expanded = it },
        modifier = modifier
    ) {
        OutlinedTextField(
            value = label,
            onValueChange = {},
            readOnly = true,
            modifier = Modifier
                .menuAnchor(MenuAnchorType.PrimaryNotEditable)
                .fillMaxWidth()
                .height(44.dp),
            textStyle = MaterialTheme.typography.labelSmall,
            trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded) },
            shape = RoundedCornerShape(10.dp),
            colors = OutlinedTextFieldDefaults.colors(
                unfocusedContainerColor = InputBackground,
                focusedContainerColor = InputBackground
            )
        )
        ExposedDropdownMenu(expanded = expanded, onDismissRequest = { expanded = false }) {
            DropdownMenuItem(
                text = { Text("전체") },
                onClick = {
                    onSelect(null)
                    expanded = false
                }
            )
            options.forEach { (value, displayLabel) ->
                DropdownMenuItem(
                    text = { Text(displayLabel) },
                    onClick = {
                        onSelect(value)
                        expanded = false
                    }
                )
            }
        }
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun MemoListPreview() {
    WismTheme {
        MemoList(
            posts = listOf(
                Post(
                    id = 1, title = "서버 장애 긴급 보고",
                    content = "오전 10시경 메인 서버 다운 발생.",
                    category = Category.ISSUE, priority = Priority.URGENT,
                    author = Author(1, "박팀장"), commentCount = 7, readBy = 3, totalReaders = 5,
                    isBookmarked = true,
                    createdAt = "2025-03-22T10:30:00", updatedAt = "2025-03-22T10:30:00"
                ),
                Post(
                    id = 2, title = "3월 월간회의 안건",
                    content = "이번 달 회의 안건을 공유합니다.",
                    category = Category.SCHEDULE, priority = Priority.NORMAL,
                    author = Author(2, "김팀장"), readBy = 5, totalReaders = 5,
                    createdAt = "2025-03-22T09:00:00", updatedAt = "2025-03-22T09:00:00"
                )
            ),
            onPostClick = {},
            onToggleBookmark = {}
        )
    }
}
