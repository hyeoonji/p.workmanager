package com.wintek.wism.data.repository

import com.wintek.wism.data.model.DashboardData
import com.wintek.wism.data.model.Post
import kotlinx.coroutines.flow.Flow

interface PostRepository {
    suspend fun getPosts(
        category: String? = null,
        priority: String? = null,
        search: String? = null,
        page: Int = 1,
        limit: Int = 20
    ): List<Post>

    suspend fun getMyPosts(userId: Int): List<Post>
    suspend fun getBookmarkedPosts(userId: Int): List<Post>
    suspend fun getPostDetail(postId: Int, currentUserId: Int): Post?
    suspend fun createPost(userId: Int, title: String, content: String, category: String, priority: String, project: String?, tags: List<String>): Long
    suspend fun updatePost(postId: Int, title: String, content: String, category: String, priority: String, project: String?, tags: List<String>)
    suspend fun deletePost(postId: Int)
    suspend fun toggleBookmark(userId: Int, postId: Int): Boolean
    suspend fun markAsRead(userId: Int, postId: Int)
    suspend fun getDashboardData(userId: Int): DashboardData
    fun observeAllPosts(): Flow<List<Post>>
}
