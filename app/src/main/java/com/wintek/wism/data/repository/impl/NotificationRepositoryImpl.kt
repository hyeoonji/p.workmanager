package com.wintek.wism.data.repository.impl

import com.wintek.wism.data.local.dao.NotificationDao
import com.wintek.wism.data.local.dao.UserDao
import com.wintek.wism.data.model.Author
import com.wintek.wism.data.model.Notification
import com.wintek.wism.data.model.NotificationType
import com.wintek.wism.data.repository.NotificationRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject

class NotificationRepositoryImpl @Inject constructor(
    private val notificationDao: NotificationDao,
    private val userDao: UserDao
) : NotificationRepository {

    override suspend fun getNotifications(userId: Int): List<Notification> {
        return notificationDao.getByUserId(userId).map { entity ->
            val sender = entity.senderId?.let { userDao.getById(it) }
            Notification(
                id = entity.id,
                type = NotificationType.fromValue(entity.type),
                title = entity.title,
                content = entity.content,
                memoTitle = entity.memoTitle,
                postId = entity.postId,
                sender = sender?.let { Author(id = it.id, name = it.name) },
                isRead = entity.isRead,
                createdAt = entity.createdAt
            )
        }
    }

    override fun observeNotifications(userId: Int): Flow<List<Notification>> {
        return notificationDao.observeByUserId(userId).map { entities ->
            entities.map { entity ->
                val sender = entity.senderId?.let { userDao.getById(it) }
                Notification(
                    id = entity.id,
                    type = NotificationType.fromValue(entity.type),
                    title = entity.title,
                    content = entity.content,
                    memoTitle = entity.memoTitle,
                    postId = entity.postId,
                    sender = sender?.let { Author(id = it.id, name = it.name) },
                    isRead = entity.isRead,
                    createdAt = entity.createdAt
                )
            }
        }
    }

    override fun observeUnreadCount(userId: Int): Flow<Int> {
        return notificationDao.observeUnreadCount(userId)
    }

    override suspend fun markAsRead(notificationId: Int) {
        notificationDao.markAsRead(notificationId)
    }

    override suspend fun markAllAsRead(userId: Int) {
        notificationDao.markAllAsRead(userId)
    }
}
