package com.wintek.wism.ui.screens.memo

import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
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
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.DatePicker
import androidx.compose.material3.DatePickerDialog
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.MenuAnchorType
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.material3.rememberDatePickerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.wintek.wism.data.model.Author
import com.wintek.wism.data.model.Category
import com.wintek.wism.data.model.Priority
import com.wintek.wism.ui.theme.Background
import com.wintek.wism.ui.theme.Border
import com.wintek.wism.ui.theme.InputBackground
import com.wintek.wism.ui.theme.Primary
import com.wintek.wism.ui.theme.Surface
import com.wintek.wism.ui.theme.TextOnPrimary
import com.wintek.wism.ui.theme.TextSecondary
import com.wintek.wism.ui.theme.WismTheme
import com.wintek.wism.viewmodel.PostEvent
import com.wintek.wism.viewmodel.PostViewModel
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.Clear
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneOffset

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun WriteMemoScreen(
    postId: Int? = null,
    onBack: () -> Unit = {},
    onSaved: () -> Unit = {},
    viewModel: PostViewModel = hiltViewModel()
) {
    val isEdit = postId != null
    var title by remember { mutableStateOf("") }
    var content by remember { mutableStateOf("") }
    var selectedPriority by remember { mutableStateOf(Priority.NORMAL) }
    var selectedCategory by remember { mutableStateOf(Category.SCHEDULE) }
    var project by remember { mutableStateOf("") }
    var scheduledDate by remember { mutableStateOf<String?>(null) }
    var showDatePicker by remember { mutableStateOf(false) }
    var tagInput by remember { mutableStateOf("") }
    var tags by remember { mutableStateOf(listOf<String>()) }
    var refInput by remember { mutableStateOf("") }
    var references by remember { mutableStateOf(listOf<com.wintek.wism.data.model.Author>()) }

    val availableUsers by viewModel.availableUsers.collectAsState()

    // 수정 모드: 기존 데이터 로드
    val detailState by viewModel.detailState.collectAsState()
    LaunchedEffect(postId) {
        if (postId != null) viewModel.loadPostDetail(postId)
    }
    LaunchedEffect(detailState.post) {
        detailState.post?.let { post ->
            if (isEdit) {
                title = post.title
                content = post.content
                selectedPriority = post.priority
                selectedCategory = post.category
                project = post.project ?: ""
                scheduledDate = post.scheduledDate
                tags = post.tags
                references = post.references
            }
        }
    }

    // 저장 완료 이벤트
    LaunchedEffect(Unit) {
        viewModel.event.collect { event ->
            if (event is PostEvent.Saved) onSaved()
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(if (isEdit) "메모 수정" else "새 메모 작성") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.Close, contentDescription = "닫기")
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
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            // 제목
            Text("제목 *", style = MaterialTheme.typography.labelLarge)
            OutlinedTextField(
                value = title,
                onValueChange = { title = it },
                placeholder = { Text("메모 제목을 입력하세요", color = TextSecondary) },
                modifier = Modifier.fillMaxWidth(),
                maxLines = 1,
                shape = RoundedCornerShape(10.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    unfocusedContainerColor = InputBackground,
                    focusedContainerColor = InputBackground
                )
            )

            // 우선순위 + 카테고리
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                FormDropdown(
                    modifier = Modifier.weight(1f),
                    label = "우선순위",
                    selectedText = selectedPriority.label,
                    options = Priority.entries.map { it to it.label },
                    onSelect = { selectedPriority = it }
                )
                FormDropdown(
                    modifier = Modifier.weight(1f),
                    label = "카테고리",
                    selectedText = selectedCategory.label,
                    options = Category.entries.map { it to it.label },
                    onSelect = { selectedCategory = it }
                )
            }

            // 일정 날짜 (선택)
            Text("일정 날짜 (선택)", style = MaterialTheme.typography.labelLarge)
            OutlinedTextField(
                value = scheduledDate ?: "",
                onValueChange = {},
                readOnly = true,
                placeholder = { Text("날짜를 지정하면 캘린더에 표시됩니다", color = TextSecondary) },
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { showDatePicker = true },
                enabled = false,
                shape = RoundedCornerShape(10.dp),
                leadingIcon = { Icon(Icons.Default.CalendarMonth, contentDescription = null, tint = Primary) },
                trailingIcon = {
                    if (scheduledDate != null) {
                        IconButton(onClick = { scheduledDate = null }) {
                            Icon(Icons.Default.Clear, contentDescription = "날짜 지우기", tint = TextSecondary)
                        }
                    }
                },
                colors = OutlinedTextFieldDefaults.colors(
                    disabledContainerColor = InputBackground,
                    disabledTextColor = androidx.compose.material3.MaterialTheme.colorScheme.onSurface,
                    disabledBorderColor = Border,
                    disabledLeadingIconColor = Primary,
                    disabledTrailingIconColor = TextSecondary,
                    disabledPlaceholderColor = TextSecondary
                )
            )

            // 프로젝트
            Text("프로젝트", style = MaterialTheme.typography.labelLarge)
            OutlinedTextField(
                value = project,
                onValueChange = { project = it },
                placeholder = { Text("관련 프로젝트명", color = TextSecondary) },
                modifier = Modifier.fillMaxWidth(),
                maxLines = 1,
                shape = RoundedCornerShape(10.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    unfocusedContainerColor = InputBackground,
                    focusedContainerColor = InputBackground
                )
            )

            // 내용
            Text("내용", style = MaterialTheme.typography.labelLarge)
            OutlinedTextField(
                value = content,
                onValueChange = { content = it },
                placeholder = { Text("메모 내용을 입력하세요", color = TextSecondary) },
                modifier = Modifier.fillMaxWidth().height(160.dp),
                shape = RoundedCornerShape(10.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    unfocusedContainerColor = InputBackground,
                    focusedContainerColor = InputBackground
                )
            )

            // 태그 (회사/사업 등 분류 라벨, 검색용)
            Text("태그", style = MaterialTheme.typography.labelLarge)
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedTextField(
                    value = tagInput,
                    onValueChange = { tagInput = it },
                    placeholder = { Text("회사·사업명 등", color = TextSecondary) },
                    modifier = Modifier.weight(1f),
                    maxLines = 1,
                    shape = RoundedCornerShape(10.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        unfocusedContainerColor = InputBackground,
                        focusedContainerColor = InputBackground
                    )
                )
                OutlinedButton(
                    onClick = {
                        if (tagInput.isNotBlank() && tagInput.trim() !in tags) {
                            tags = tags + tagInput.trim()
                            tagInput = ""
                        }
                    },
                    shape = RoundedCornerShape(10.dp)
                ) { Text("추가") }
            }
            if (tags.isNotEmpty()) {
                Row(
                    modifier = Modifier.fillMaxWidth().horizontalScroll(rememberScrollState()),
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    tags.forEach { tag ->
                        androidx.compose.material3.AssistChip(
                            onClick = { tags = tags - tag },
                            label = { Text("#$tag", style = MaterialTheme.typography.labelSmall) },
                            trailingIcon = {
                                Icon(Icons.Default.Close, contentDescription = "삭제", modifier = Modifier.size(14.dp))
                            }
                        )
                    }
                }
            }

            // 참조 (사람, 사용자 ID 기반 자동완성)
            Text("참조", style = MaterialTheme.typography.labelLarge)
            ReferencePicker(
                input = refInput,
                onInputChange = { refInput = it },
                candidates = availableUsers.filter { user ->
                    refInput.isNotBlank() &&
                        user.name.contains(refInput.trim(), ignoreCase = true) &&
                        references.none { it.id == user.id }
                },
                onSelect = { user ->
                    references = references + user
                    refInput = ""
                }
            )
            if (references.isNotEmpty()) {
                Row(
                    modifier = Modifier.fillMaxWidth().horizontalScroll(rememberScrollState()),
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    references.forEach { person ->
                        androidx.compose.material3.AssistChip(
                            onClick = { references = references - person },
                            label = { Text("@${person.name}", style = MaterialTheme.typography.labelSmall) },
                            trailingIcon = {
                                Icon(Icons.Default.Close, contentDescription = "삭제", modifier = Modifier.size(14.dp))
                            }
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // 버튼
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                OutlinedButton(
                    onClick = onBack,
                    modifier = Modifier.weight(1f),
                    shape = RoundedCornerShape(10.dp)
                ) { Text("취소") }
                Button(
                    onClick = {
                        val referenceIds = references.map { it.id }
                        if (isEdit && postId != null) {
                            viewModel.updatePost(postId, title, content, selectedCategory.value, selectedPriority.value, project.ifBlank { null }, scheduledDate, tags, referenceIds)
                        } else {
                            viewModel.createPost(title, content, selectedCategory.value, selectedPriority.value, project.ifBlank { null }, scheduledDate, tags, referenceIds)
                        }
                    },
                    modifier = Modifier.weight(1f),
                    enabled = title.isNotBlank(),
                    shape = RoundedCornerShape(10.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = Primary)
                ) { Text("저장", color = TextOnPrimary) }
            }
        }
    }

    if (showDatePicker) {
        val initialMillis = scheduledDate?.let {
            runCatching { LocalDate.parse(it).atStartOfDay(ZoneOffset.UTC).toInstant().toEpochMilli() }.getOrNull()
        }
        val datePickerState = rememberDatePickerState(initialSelectedDateMillis = initialMillis)
        DatePickerDialog(
            onDismissRequest = { showDatePicker = false },
            confirmButton = {
                TextButton(onClick = {
                    datePickerState.selectedDateMillis?.let { millis ->
                        scheduledDate = Instant.ofEpochMilli(millis).atZone(ZoneOffset.UTC).toLocalDate().toString()
                    }
                    showDatePicker = false
                }) { Text("확인", color = Primary) }
            },
            dismissButton = {
                TextButton(onClick = { showDatePicker = false }) { Text("취소") }
            }
        ) {
            DatePicker(state = datePickerState)
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ReferencePicker(
    input: String,
    onInputChange: (String) -> Unit,
    candidates: List<Author>,
    onSelect: (Author) -> Unit
) {
    var expanded by remember { mutableStateOf(false) }
    LaunchedEffect(candidates.size, input) {
        expanded = input.isNotBlank() && candidates.isNotEmpty()
    }
    ExposedDropdownMenuBox(expanded = expanded, onExpandedChange = {}) {
        OutlinedTextField(
            value = input,
            onValueChange = onInputChange,
            placeholder = { Text("이름 입력 후 선택", color = TextSecondary) },
            modifier = Modifier
                .menuAnchor(MenuAnchorType.PrimaryEditable)
                .fillMaxWidth(),
            maxLines = 1,
            shape = RoundedCornerShape(10.dp),
            colors = OutlinedTextFieldDefaults.colors(
                unfocusedContainerColor = InputBackground,
                focusedContainerColor = InputBackground
            )
        )
        if (candidates.isNotEmpty()) {
            ExposedDropdownMenu(expanded = expanded, onDismissRequest = { expanded = false }) {
                candidates.forEach { user ->
                    DropdownMenuItem(
                        text = {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.spacedBy(12.dp),
                                verticalAlignment = androidx.compose.ui.Alignment.CenterVertically
                            ) {
                                Text(user.name, style = MaterialTheme.typography.bodyMedium)
                                Text(
                                    listOfNotNull(user.department, user.position).joinToString(" / "),
                                    style = MaterialTheme.typography.labelSmall,
                                    color = TextSecondary
                                )
                            }
                        },
                        onClick = { onSelect(user) }
                    )
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun <T> FormDropdown(
    modifier: Modifier = Modifier,
    label: String,
    selectedText: String,
    options: List<Pair<T, String>>,
    onSelect: (T) -> Unit
) {
    var expanded by remember { mutableStateOf(false) }
    Column(modifier = modifier) {
        Text(label, style = MaterialTheme.typography.labelLarge)
        Spacer(modifier = Modifier.height(4.dp))
        ExposedDropdownMenuBox(expanded = expanded, onExpandedChange = { expanded = it }) {
            OutlinedTextField(
                value = selectedText,
                onValueChange = {},
                readOnly = true,
                modifier = Modifier.menuAnchor(MenuAnchorType.PrimaryNotEditable).fillMaxWidth(),
                trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded) },
                shape = RoundedCornerShape(10.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    unfocusedContainerColor = InputBackground,
                    focusedContainerColor = InputBackground
                )
            )
            ExposedDropdownMenu(expanded = expanded, onDismissRequest = { expanded = false }) {
                options.forEach { (value, displayLabel) ->
                    DropdownMenuItem(
                        text = { Text(displayLabel) },
                        onClick = { onSelect(value); expanded = false }
                    )
                }
            }
        }
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun WriteMemoScreenPreview() {
    WismTheme { WriteMemoScreen() }
}
