package com.wintek.wism.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.wintek.wism.data.local.entity.CommentEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface CommentDao {
    @Query("SELECT * FROM wism_comments WHERE post_id = :postId AND is_deleted = 0 ORDER BY created_at ASC")
    suspend fun getByPostId(postId: Int): List<CommentEntity>

    @Query("SELECT * FROM wism_comments WHERE post_id = :postId AND is_deleted = 0 ORDER BY created_at ASC")
    fun observeByPostId(postId: Int): Flow<List<CommentEntity>>

    @Query("SELECT COUNT(*) FROM wism_comments WHERE post_id = :postId AND is_deleted = 0")
    suspend fun countByPostId(postId: Int): Int

    @Query("SELECT COUNT(*) FROM wism_comments WHERE user_id = :userId AND is_deleted = 0")
    suspend fun countByUserId(userId: Int): Int

    @Query("UPDATE wism_comments SET content = :content, updated_at = :updatedAt WHERE id = :id")
    suspend fun updateContent(id: Int, content: String, updatedAt: String)

    @Query("UPDATE wism_comments SET is_deleted = 1, updated_at = :updatedAt WHERE id = :id")
    suspend fun softDelete(id: Int, updatedAt: String)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(comment: CommentEntity): Long

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(comments: List<CommentEntity>)
}
