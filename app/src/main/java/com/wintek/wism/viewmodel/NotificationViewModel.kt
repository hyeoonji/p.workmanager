package com.wintek.wism.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.wintek.wism.data.model.Notification
import com.wintek.wism.data.repository.AuthRepository
import com.wintek.wism.data.repository.NotificationRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class NotificationState(
    val isLoading: Boolean = false,
    val notifications: List<Notification> = emptyList(),
    val unreadCount: Int = 0
)

@HiltViewModel
class NotificationViewModel @Inject constructor(
    private val notificationRepository: NotificationRepository,
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _state = MutableStateFlow(NotificationState())
    val state: StateFlow<NotificationState> = _state.asStateFlow()

    fun loadNotifications() {
        viewModelScope.launch {
            _state.value = _state.value.copy(isLoading = true)
            val userId = authRepository.getCurrentUserId() ?: return@launch
            val notifications = notificationRepository.getNotifications(userId)
            val unread = notifications.count { !it.isRead }
            _state.value = NotificationState(
                isLoading = false,
                notifications = notifications,
                unreadCount = unread
            )
        }
    }

    fun markAsRead(notificationId: Int) {
        viewModelScope.launch {
            notificationRepository.markAsRead(notificationId)
            loadNotifications()
        }
    }

    fun markAllAsRead() {
        viewModelScope.launch {
            val userId = authRepository.getCurrentUserId() ?: return@launch
            notificationRepository.markAllAsRead(userId)
            loadNotifications()
        }
    }
}
