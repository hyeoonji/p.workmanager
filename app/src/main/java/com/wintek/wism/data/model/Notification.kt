package com.wintek.wism.data.model

data class Notification(
    val id: Int,
    val type: NotificationType,
    val title: String,
    val content: String,
    val memoTitle: String? = null,
    val postId: Int? = null,
    val sender: Author? = null,
    val isRead: Boolean = false,
    val createdAt: String
)
