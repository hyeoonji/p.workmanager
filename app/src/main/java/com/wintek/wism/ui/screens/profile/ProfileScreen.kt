package com.wintek.wism.ui.screens.profile

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
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Business
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.Logout
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Phone
import androidx.compose.material.icons.filled.Work
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.rememberModalBottomSheetState
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
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.wintek.wism.data.model.UserProfile
import com.wintek.wism.data.model.UserStats
import com.wintek.wism.ui.theme.Background
import com.wintek.wism.ui.theme.Destructive
import com.wintek.wism.ui.theme.InputBackground
import com.wintek.wism.ui.theme.Primary
import com.wintek.wism.ui.theme.PrimaryLight
import com.wintek.wism.ui.theme.Surface
import com.wintek.wism.ui.theme.TextOnPrimary
import com.wintek.wism.ui.theme.TextSecondary
import com.wintek.wism.ui.theme.WismTheme
import com.wintek.wism.viewmodel.AuthViewModel
import com.wintek.wism.viewmodel.ProfileViewModel

@Composable
fun ProfileScreen(
    modifier: Modifier = Modifier,
    onLogout: () -> Unit = {},
    viewModel: ProfileViewModel = hiltViewModel(),
    authViewModel: AuthViewModel = hiltViewModel()
) {
    val state by viewModel.state.collectAsState()

    LaunchedEffect(Unit) { viewModel.loadProfile() }

    state.profile?.let { profile ->
        ProfileContent(
            modifier = modifier,
            profile = profile,
            onLogout = {
                authViewModel.logout()
                onLogout()
            },
            onPushToggle = { viewModel.updatePushEnabled(it) },
            onSaveProfile = { name, email, phone, department, position ->
                viewModel.updateProfile(name, email, phone, department, position)
            }
        )
    }
}

@Composable
private fun ProfileContent(
    modifier: Modifier = Modifier,
    profile: UserProfile,
    onLogout: () -> Unit = {},
    onPushToggle: (Boolean) -> Unit = {},
    onSaveProfile: (name: String, email: String?, phone: String?, department: String?, position: String?) -> Unit = { _, _, _, _, _ -> }
) {
    var showLogoutDialog by remember { mutableStateOf(false) }
    var showEditSheet by remember { mutableStateOf(false) }

    Column(
        modifier = modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // 프로필 카드
        Card(
            colors = CardDefaults.cardColors(containerColor = Background),
            border = CardDefaults.outlinedCardBorder()
        ) {
            Column(
                modifier = Modifier.fillMaxWidth().padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // 아바타
                Box(
                    modifier = Modifier
                        .size(96.dp)
                        .clip(CircleShape)
                        .background(PrimaryLight),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        Icons.Default.Person,
                        contentDescription = null,
                        modifier = Modifier.size(48.dp),
                        tint = Primary.copy(alpha = 0.5f)
                    )
                }

                Spacer(modifier = Modifier.height(12.dp))

                Text(profile.name, style = MaterialTheme.typography.titleLarge)
                if (profile.department != null || profile.position != null) {
                    Text(
                        listOfNotNull(profile.department, profile.position).joinToString(" / "),
                        style = MaterialTheme.typography.bodySmall,
                        color = TextSecondary
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))

                Button(
                    onClick = { showEditSheet = true },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(10.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = Primary)
                ) {
                    Icon(Icons.Default.Edit, contentDescription = null, modifier = Modifier.size(16.dp))
                    Spacer(modifier = Modifier.size(8.dp))
                    Text("프로필 수정", color = TextOnPrimary)
                }
            }
        }

        // 연락처 정보
        Card(
            colors = CardDefaults.cardColors(containerColor = Background),
            border = CardDefaults.outlinedCardBorder()
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text("연락처 정보", style = MaterialTheme.typography.titleMedium)
                Spacer(modifier = Modifier.height(16.dp))
                ContactItem(Icons.Default.Email, "이메일", profile.email ?: "-")
                Spacer(modifier = Modifier.height(12.dp))
                ContactItem(Icons.Default.Phone, "전화번호", profile.phone ?: "-")
                Spacer(modifier = Modifier.height(12.dp))
                ContactItem(Icons.Default.Work, "직급", profile.position ?: "-")
                Spacer(modifier = Modifier.height(12.dp))
                ContactItem(Icons.Default.Business, "부서", profile.department ?: "-")
            }
        }

        // 활동 통계
        Card(
            colors = CardDefaults.cardColors(containerColor = Background),
            border = CardDefaults.outlinedCardBorder()
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text("활동 통계", style = MaterialTheme.typography.titleMedium)
                Spacer(modifier = Modifier.height(16.dp))
                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceEvenly) {
                    StatItem("작성한 메모", profile.stats.postCount)
                    StatItem("댓글", profile.stats.commentCount)
                    StatItem("북마크", profile.stats.bookmarkCount)
                }
            }
        }

        // 앱 설정
        Card(
            colors = CardDefaults.cardColors(containerColor = Background),
            border = CardDefaults.outlinedCardBorder()
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text("앱 설정", style = MaterialTheme.typography.titleMedium)
                Spacer(modifier = Modifier.height(12.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text("푸시 알림", style = MaterialTheme.typography.bodyMedium)
                    Switch(
                        checked = profile.settings.pushEnabled,
                        onCheckedChange = onPushToggle
                    )
                }
                HorizontalDivider(modifier = Modifier.padding(vertical = 12.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text("버전", style = MaterialTheme.typography.bodyMedium)
                    Text("v1.0.0", style = MaterialTheme.typography.bodyMedium, color = TextSecondary)
                }
            }
        }

        // 로그아웃
        Button(
            onClick = { showLogoutDialog = true },
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(10.dp),
            colors = ButtonDefaults.buttonColors(containerColor = Destructive)
        ) {
            Icon(Icons.Default.Logout, contentDescription = null, modifier = Modifier.size(16.dp))
            Spacer(modifier = Modifier.size(8.dp))
            Text("로그아웃", color = TextOnPrimary)
        }
    }

    if (showLogoutDialog) {
        AlertDialog(
            onDismissRequest = { showLogoutDialog = false },
            title = { Text("로그아웃") },
            text = { Text("정말 로그아웃 하시겠습니까?") },
            confirmButton = {
                TextButton(onClick = { showLogoutDialog = false; onLogout() }) {
                    Text("로그아웃", color = Destructive)
                }
            },
            dismissButton = {
                TextButton(onClick = { showLogoutDialog = false }) { Text("취소") }
            }
        )
    }

    if (showEditSheet) {
        ProfileEditSheet(
            profile = profile,
            onDismiss = { showEditSheet = false },
            onSave = { name, email, phone, department, position ->
                onSaveProfile(name, email, phone, department, position)
                showEditSheet = false
            }
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ProfileEditSheet(
    profile: UserProfile,
    onDismiss: () -> Unit,
    onSave: (name: String, email: String?, phone: String?, department: String?, position: String?) -> Unit
) {
    var name by remember { mutableStateOf(profile.name) }
    var position by remember { mutableStateOf(profile.position ?: "") }
    var department by remember { mutableStateOf(profile.department ?: "") }
    var email by remember { mutableStateOf(profile.email ?: "") }
    var phone by remember { mutableStateOf(profile.phone ?: "") }

    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = sheetState,
        containerColor = Background
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 24.dp)
                .padding(bottom = 24.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text(
                "프로필 수정",
                style = MaterialTheme.typography.titleLarge,
                modifier = Modifier.fillMaxWidth(),
                textAlign = TextAlign.Center
            )

            // 아바타 (사진 변경은 추후 지원)
            Box(
                modifier = Modifier.fillMaxWidth(),
                contentAlignment = Alignment.Center
            ) {
                Box(
                    modifier = Modifier
                        .size(96.dp)
                        .clip(CircleShape)
                        .background(PrimaryLight),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        Icons.Default.Person,
                        contentDescription = null,
                        modifier = Modifier.size(48.dp),
                        tint = Primary.copy(alpha = 0.5f)
                    )
                }
            }

            EditField(label = "이름 *", value = name, onValueChange = { name = it }, placeholder = "이름을 입력하세요")
            EditField(label = "직급", value = position, onValueChange = { position = it }, placeholder = "예: 팀장, 부장")
            EditField(label = "부서", value = department, onValueChange = { department = it }, placeholder = "예: XR개발실 1팀")
            EditField(label = "이메일", value = email, onValueChange = { email = it }, placeholder = "example@wintek.co.kr")
            EditField(label = "전화번호", value = phone, onValueChange = { phone = it }, placeholder = "010-0000-0000")

            Spacer(modifier = Modifier.height(4.dp))

            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                OutlinedButton(
                    onClick = onDismiss,
                    modifier = Modifier.weight(1f),
                    shape = RoundedCornerShape(10.dp)
                ) { Text("취소") }
                Button(
                    onClick = {
                        onSave(
                            name.trim(),
                            email.trim().ifBlank { null },
                            phone.trim().ifBlank { null },
                            department.trim().ifBlank { null },
                            position.trim().ifBlank { null }
                        )
                    },
                    modifier = Modifier.weight(1f),
                    enabled = name.isNotBlank(),
                    shape = RoundedCornerShape(10.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = Primary)
                ) { Text("저장", color = TextOnPrimary) }
            }
        }
    }
}

@Composable
private fun EditField(
    label: String,
    value: String,
    onValueChange: (String) -> Unit,
    placeholder: String
) {
    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
        Text(label, style = MaterialTheme.typography.labelLarge)
        OutlinedTextField(
            value = value,
            onValueChange = onValueChange,
            placeholder = { Text(placeholder, color = TextSecondary) },
            modifier = Modifier.fillMaxWidth(),
            maxLines = 1,
            shape = RoundedCornerShape(10.dp),
            colors = OutlinedTextFieldDefaults.colors(
                unfocusedContainerColor = InputBackground,
                focusedContainerColor = InputBackground
            )
        )
    }
}

@Composable
private fun ContactItem(icon: ImageVector, label: String, value: String) {
    Row(verticalAlignment = Alignment.Top, horizontalArrangement = Arrangement.spacedBy(12.dp)) {
        Box(
            modifier = Modifier
                .size(36.dp)
                .clip(RoundedCornerShape(8.dp))
                .background(Surface),
            contentAlignment = Alignment.Center
        ) {
            Icon(icon, contentDescription = null, modifier = Modifier.size(20.dp), tint = Primary)
        }
        Column {
            Text(label, style = MaterialTheme.typography.labelSmall, color = TextSecondary)
            Text(value, style = MaterialTheme.typography.bodyMedium)
        }
    }
}

@Composable
private fun StatItem(label: String, count: Int) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(count.toString(), style = MaterialTheme.typography.headlineMedium, color = Primary)
        Spacer(modifier = Modifier.height(4.dp))
        Text(label, style = MaterialTheme.typography.labelSmall, color = TextSecondary)
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun ProfileScreenPreview() {
    WismTheme {
        ProfileContent(
            profile = UserProfile(
                id = 1, loginId = "kim.team", name = "김팀장",
                department = "XR개발실 1팀", position = "팀장",
                email = "kim@wintek.co.kr", phone = "010-1111-1111",
                stats = UserStats(postCount = 12, commentCount = 45, bookmarkCount = 8)
            )
        )
    }
}
