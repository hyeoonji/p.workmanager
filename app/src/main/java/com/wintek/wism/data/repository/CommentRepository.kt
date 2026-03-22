package com.wintek.wism.data.repository

import com.wintek.wism.data.model.Comment
import kotlinx.coroutines.flow.Flow

interface CommentRepository {
    suspend fun getCommentsByPostId(postId: Int): List<Comment>
    fun observeCommentsByPostId(postId: Int): Flow<List<Comment>>
    suspend fun addComment(postId: Int, userId: Int, content: String, type: String = "comment"): Long
}
