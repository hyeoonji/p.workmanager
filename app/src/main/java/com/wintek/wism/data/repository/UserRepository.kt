package com.wintek.wism.data.repository

import com.wintek.wism.data.model.Author
import com.wintek.wism.data.model.UserProfile
import com.wintek.wism.data.model.UserSettings
import kotlinx.coroutines.flow.Flow

interface UserRepository {
    suspend fun getActiveUsers(): List<Author>
    suspend fun getUserProfile(userId: Int): UserProfile?
    fun observeUserProfile(userId: Int): Flow<UserProfile?>
    suspend fun updateProfile(userId: Int, name: String, email: String?, phone: String?, department: String?, position: String?)
    suspend fun getUserSettings(userId: Int): UserSettings
    suspend fun updatePushEnabled(userId: Int, enabled: Boolean)
}
