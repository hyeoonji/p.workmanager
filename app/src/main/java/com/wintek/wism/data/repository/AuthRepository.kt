package com.wintek.wism.data.repository

import com.wintek.wism.data.model.UserProfile

interface AuthRepository {
    suspend fun login(loginId: String, password: String): UserProfile?
    suspend fun getCurrentUserId(): Int?
    suspend fun setCurrentUserId(userId: Int?)
    suspend fun isAutoLoginEnabled(): Boolean
    suspend fun setAutoLoginEnabled(enabled: Boolean)
    suspend fun logout()
}
