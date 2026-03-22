package com.wintek.wism.data.repository

import com.wintek.wism.data.model.Notification
import kotlinx.coroutines.flow.Flow

interface NotificationRepository {
    suspend fun getNotifications(userId: Int): List<Notification>
    fun observeNotifications(userId: Int): Flow<List<Notification>>
    fun observeUnreadCount(userId: Int): Flow<Int>
    suspend fun markAsRead(notificationId: Int)
    suspend fun markAllAsRead(userId: Int)
}
