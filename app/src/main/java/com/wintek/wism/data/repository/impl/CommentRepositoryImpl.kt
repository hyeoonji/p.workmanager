package com.wintek.wism.data.repository.impl

import com.wintek.wism.data.local.dao.CommentDao
import com.wintek.wism.data.local.dao.UserDao
import com.wintek.wism.data.local.entity.CommentEntity
import com.wintek.wism.data.model.Author
import com.wintek.wism.data.model.Comment
import com.wintek.wism.data.repository.CommentRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import javax.inject.Inject

class CommentRepositoryImpl @Inject constructor(
    private val commentDao: CommentDao,
    private val userDao: UserDao
) : CommentRepository {

    private val fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss")

    override suspend fun getCommentsByPostId(postId: Int): List<Comment> {
        return commentDao.getByPostId(postId).map { it.toComment() }
    }

    override fun observeCommentsByPostId(postId: Int): Flow<List<Comment>> {
        return commentDao.observeByPostId(postId).map { entities ->
            entities.map { it.toComment() }
        }
    }

    override suspend fun addComment(postId: Int, userId: Int, content: String, type: String): Long {
        val now = LocalDateTime.now().format(fmt)
        return commentDao.insert(
            CommentEntity(
                postId = postId, userId = userId, content = content,
                type = type, createdAt = now, updatedAt = now
            )
        )
    }

    override suspend fun updateComment(commentId: Int, content: String) {
        commentDao.updateContent(commentId, content, LocalDateTime.now().format(fmt))
    }

    override suspend fun deleteComment(commentId: Int) {
        commentDao.softDelete(commentId, LocalDateTime.now().format(fmt))
    }

    private suspend fun CommentEntity.toComment(): Comment {
        val user = userDao.getById(userId)
        return Comment(
            id = id,
            author = Author(id = userId, name = user?.name ?: "알 수 없음"),
            content = content,
            type = type,
            createdAt = createdAt
        )
    }
}
