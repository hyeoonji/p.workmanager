package com.wintek.wism.data.model

data class Author(
    val id: Int,
    val name: String,
    val department: String? = null,
    val position: String? = null
)

data class UserProfile(
    val id: Int,
    val loginId: String,
    val name: String,
    val department: String? = null,
    val position: String? = null,
    val email: String? = null,
    val phone: String? = null,
    val photoUrl: String? = null,
    val role: String = "manager",
    val stats: UserStats = UserStats(),
    val settings: UserSettings = UserSettings()
)

data class UserStats(
    val postCount: Int = 0,
    val commentCount: Int = 0,
    val bookmarkCount: Int = 0
)

data class UserSettings(
    val pushEnabled: Boolean = true,
    val autoLoginEnabled: Boolean = false
)
