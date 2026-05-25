package com.wintek.wism.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.systemBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ChatBubble
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.wintek.wism.data.model.Author
import com.wintek.wism.data.model.Notification
import com.wintek.wism.data.model.NotificationType
import com.wintek.wism.ui.theme.Background
import com.wintek.wism.ui.theme.Border
import com.wintek.wism.ui.theme.NotificationComment
import com.wintek.wism.ui.theme.NotificationStatus
import com.wintek.wism.ui.theme.Primary
import com.wintek.wism.ui.theme.Surface
import com.wintek.wism.ui.theme.TextOnPrimary
import com.wintek.wism.ui.theme.TextSecondary
import com.wintek.wism.ui.theme.Urgent
import com.wintek.wism.ui.theme.WismTheme

@Composable
fun NotificationPanel(
    notifications: List<Notification>,
    unreadCount: Int,
    onClose: () -> Unit,
    onNotificationClick: (Notification) -> Unit,
    onMarkAllAsRead: () -> Unit
) {
    // 배경 오버레이 + 패널
    Box(modifier = Modifier.fillMaxSize()) {
        // 반투명 배경
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(Color.Black.copy(alpha = 0.5f))
                .clickable(onClick = onClose)
        )

        // 알림 패널 (오른쪽)
        Column(
            modifier = Modifier
                .fillMaxHeight()
                .fillMaxWidth(0.85f)
                .align(Alignment.CenterEnd)
                .background(Background)
                .systemBarsPadding()
        ) {
            // 헤더
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    Icon(Icons.Default.Notifications, contentDescription = null, modifier = Modifier.size(20.dp))
                    Text("알림", style = MaterialTheme.typography.titleMedium)
                    if (unreadCount > 0) {
                        Box(
                            modifier = Modifier
                                .clip(CircleShape)
                                .background(Urgent)
                                .padding(horizontal = 6.dp, vertical = 2.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(unreadCount.toString(), style = MaterialTheme.typography.labelSmall, color = TextOnPrimary)
                        }
                    }
                }
                IconButton(onClick = onClose) {
                    Icon(Icons.Default.Close, contentDescription = "닫기")
                }
            }

            HorizontalDivider()

            // 알림 목록
            if (notifications.isEmpty()) {
                Box(modifier = Modifier.weight(1f).fillMaxWidth(), contentAlignment = Alignment.Center) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(Icons.Default.Notifications, null, Modifier.size(48.dp), tint = TextSecondary.copy(alpha = 0.5f))
                        Spacer(Modifier.height(8.dp))
                        Text("알림이 없습니다", color = TextSecondary)
                    }
                }
            } else {
                LazyColumn(modifier = Modifier.weight(1f)) {
                    items(notifications, key = { it.id }) { notification ->
                        NotificationItem(
                            notification = notification,
                            onClick = { onNotificationClick(notification) }
                        )
                        HorizontalDivider()
                    }
                }
            }

            // 모두 읽음 버튼
            if (unreadCount > 0) {
                HorizontalDivider()
                Box(modifier = Modifier.padding(16.dp)) {
                    Button(
                        onClick = onMarkAllAsRead,
                        modifier = Modifier.fillMaxWidth(),
                        colors = ButtonDefaults.buttonColors(containerColor = Primary)
                    ) {
                        Text("모든 알림 읽음 표시", color = TextOnPrimary)
                    }
                }
            }
        }
    }
}

@Composable
private fun NotificationItem(
    notification: Notification,
    onClick: () -> Unit
) {
    val (icon, iconTint) = getNotificationIconAndColor(notification.type)

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(if (!notification.isRead) Surface.copy(alpha = 0.5f) else Color.Transparent)
            .clickable(onClick = onClick)
            .padding(16.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Icon(icon, contentDescription = null, modifier = Modifier.size(16.dp).padding(top = 2.dp), tint = iconTint)
        Column(modifier = Modifier.weight(1f)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(notification.title, style = MaterialTheme.typography.bodyMedium)
                if (!notification.isRead) {
                    Box(modifier = Modifier.size(8.dp).clip(CircleShape).background(Primary))
                }
            }
            Spacer(Modifier.height(2.dp))
            Text(notification.content, style = MaterialTheme.typography.bodySmall, color = TextSecondary, maxLines = 1, overflow = TextOverflow.Ellipsis)
            Spacer(Modifier.height(2.dp))
            Text(
                "${notification.memoTitle ?: ""} · ${notification.createdAt.substringAfter("T").take(5)}",
                style = MaterialTheme.typography.labelSmall,
                color = TextSecondary
            )
        }
    }
}

private fun getNotificationIconAndColor(type: NotificationType): Pair<ImageVector, Color> = when (type) {
    NotificationType.COMMENT -> Icons.Default.ChatBubble to NotificationComment
    NotificationType.MENTION -> Icons.Default.Notifications to Primary
    NotificationType.STATUS -> Icons.Default.CheckCircle to NotificationStatus
    NotificationType.URGENT -> Icons.Default.Warning to Urgent
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun NotificationPanelPreview() {
    WismTheme {
        NotificationPanel(
            notifications = listOf(
                Notification(1, NotificationType.URGENT, "긴급 이슈", "새로운 긴급 이슈가 등록되었습니다.", "서버 장애 보고", 1, Author(2, "박팀장"), false, "2025-03-22T14:30:00"),
                Notification(2, NotificationType.COMMENT, "새 댓글", "김팀장님이 댓글을 남겼습니다.", "서버 장애 보고", 1, Author(1, "김팀장"), false, "2025-03-22T15:20:00"),
                Notification(3, NotificationType.STATUS, "확인 완료", "최이사님이 확인 완료했습니다.", "서버 장애 보고", 1, Author(4, "최이사"), true, "2025-03-22T16:00:00")
            ),
            unreadCount = 2,
            onClose = {},
            onNotificationClick = {},
            onMarkAllAsRead = {}
        )
    }
}
