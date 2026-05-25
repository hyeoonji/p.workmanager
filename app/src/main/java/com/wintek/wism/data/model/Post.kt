package com.wintek.wism.data.model

data class Post(
    val id: Int,
    val title: String,
    val content: String,
    val category: Category,
    val priority: Priority,
    val author: Author,
    val project: String? = null,
    val scheduledDate: String? = null,
    val tags: List<String> = emptyList(),
    val references: List<Author> = emptyList(),
    val commentCount: Int = 0,
    val readBy: Int = 0,
    val totalReaders: Int = 0,
    val isRead: Boolean = false,
    val isBookmarked: Boolean = false,
    val isMine: Boolean = false,
    val comments: List<Comment> = emptyList(),
    val createdAt: String,
    val updatedAt: String
)

data class DashboardData(
    val urgentCount: Int = 0,
    val todayCount: Int = 0,
    val myMemoCount: Int = 0,
    val urgentMemos: List<Post> = emptyList(),
    val todayMemos: List<Post> = emptyList()
)
