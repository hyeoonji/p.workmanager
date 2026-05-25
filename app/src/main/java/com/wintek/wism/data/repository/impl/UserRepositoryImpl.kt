package com.wintek.wism.data.repository.impl

import com.wintek.wism.data.local.dao.*
import com.wintek.wism.data.model.UserProfile
import com.wintek.wism.data.model.UserSettings
import com.wintek.wism.data.model.UserStats
import com.wintek.wism.data.repository.UserRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import javax.inject.Inject

class UserRepositoryImpl @Inject constructor(
    private val userDao: UserDao,
    private val postDao: PostDao,
    private val commentDao: CommentDao,
    private val bookmarkDao: BookmarkDao,
    private val userSettingsDao: UserSettingsDao
) : UserRepository {

    private val fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss")

    override suspend fun getActiveUsers(): List<com.wintek.wism.data.model.Author> {
        return userDao.getAllActive().map {
            com.wintek.wism.data.model.Author(id = it.id, name = it.name, department = it.department, position = it.position)
        }
    }

    override suspend fun getUserProfile(userId: Int): UserProfile? {
        val user = userDao.getById(userId) ?: return null
        val settings = userSettingsDao.getByUserId(userId)
        return UserProfile(
            id = user.id,
            loginId = user.loginId,
            name = user.name,
            department = user.department,
            position = user.position,
            email = user.email,
            phone = user.phone,
            photoUrl = user.photoUrl,
            role = user.role,
            stats = UserStats(
                postCount = postDao.countByUserId(userId),
                commentCount = commentDao.countByUserId(userId),
                bookmarkCount = bookmarkDao.countByUserId(userId)
            ),
            settings = UserSettings(
                pushEnabled = settings?.pushEnabled ?: true,
                autoLoginEnabled = settings?.autoLoginEnabled ?: false
            )
        )
    }

    override fun observeUserProfile(userId: Int): Flow<UserProfile?> {
        return userDao.observeById(userId).map { user ->
            user?.let {
                val settings = userSettingsDao.getByUserId(userId)
                UserProfile(
                    id = it.id, loginId = it.loginId, name = it.name,
                    department = it.department, position = it.position,
                    email = it.email, phone = it.phone, photoUrl = it.photoUrl,
                    role = it.role,
                    stats = UserStats(
                        postCount = postDao.countByUserId(userId),
                        commentCount = commentDao.countByUserId(userId),
                        bookmarkCount = bookmarkDao.countByUserId(userId)
                    ),
                    settings = UserSettings(
                        pushEnabled = settings?.pushEnabled ?: true,
                        autoLoginEnabled = settings?.autoLoginEnabled ?: false
                    )
                )
            }
        }
    }

    override suspend fun updateProfile(userId: Int, name: String, email: String?, phone: String?, department: String?, position: String?) {
        val user = userDao.getById(userId) ?: return
        val now = LocalDateTime.now().format(fmt)
        userDao.update(user.copy(name = name, email = email, phone = phone, department = department, position = position, updatedAt = now))
    }

    override suspend fun getUserSettings(userId: Int): UserSettings {
        val settings = userSettingsDao.getByUserId(userId)
        return UserSettings(
            pushEnabled = settings?.pushEnabled ?: true,
            autoLoginEnabled = settings?.autoLoginEnabled ?: false
        )
    }

    override suspend fun updatePushEnabled(userId: Int, enabled: Boolean) {
        val settings = userSettingsDao.getByUserId(userId) ?: return
        val now = LocalDateTime.now().format(fmt)
        userSettingsDao.update(settings.copy(pushEnabled = enabled, updatedAt = now))
    }
}
