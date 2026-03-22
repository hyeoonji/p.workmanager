package com.wintek.wism.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import com.wintek.wism.data.local.entity.PostEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface PostDao {
    @Query("""
        SELECT * FROM wism_posts
        WHERE is_deleted = 0
        ORDER BY
            CASE WHEN priority = 'urgent' THEN 0 ELSE 1 END,
            created_at DESC
        LIMIT :limit OFFSET :offset
    """)
    suspend fun getPosts(limit: Int = 20, offset: Int = 0): List<PostEntity>

    @Query("""
        SELECT * FROM wism_posts
        WHERE is_deleted = 0
        ORDER BY
            CASE WHEN priority = 'urgent' THEN 0 ELSE 1 END,
            created_at DESC
    """)
    fun observeAllPosts(): Flow<List<PostEntity>>

    @Query("""
        SELECT * FROM wism_posts
        WHERE is_deleted = 0
            AND (:category IS NULL OR category = :category)
            AND (:priority IS NULL OR priority = :priority)
            AND (:search IS NULL OR title LIKE '%' || :search || '%' OR content LIKE '%' || :search || '%')
        ORDER BY
            CASE WHEN priority = 'urgent' THEN 0 ELSE 1 END,
            created_at DESC
        LIMIT :limit OFFSET :offset
    """)
    suspend fun getFilteredPosts(
        category: String? = null,
        priority: String? = null,
        search: String? = null,
        limit: Int = 20,
        offset: Int = 0
    ): List<PostEntity>

    @Query("SELECT * FROM wism_posts WHERE id = :id AND is_deleted = 0")
    suspend fun getById(id: Int): PostEntity?

    @Query("SELECT * FROM wism_posts WHERE id = :id AND is_deleted = 0")
    fun observeById(id: Int): Flow<PostEntity?>

    @Query("SELECT * FROM wism_posts WHERE user_id = :userId AND is_deleted = 0 ORDER BY created_at DESC")
    suspend fun getByUserId(userId: Int): List<PostEntity>

    @Query("SELECT COUNT(*) FROM wism_posts WHERE user_id = :userId AND is_deleted = 0")
    suspend fun countByUserId(userId: Int): Int

    @Query("SELECT * FROM wism_posts WHERE priority = 'urgent' AND is_deleted = 0 ORDER BY created_at DESC LIMIT :limit")
    suspend fun getUrgentPosts(limit: Int = 3): List<PostEntity>

    @Query("SELECT COUNT(*) FROM wism_posts WHERE priority = 'urgent' AND is_deleted = 0")
    suspend fun getUrgentCount(): Int

    @Query("SELECT * FROM wism_posts WHERE is_deleted = 0 AND date(created_at) = date(:today) ORDER BY created_at DESC")
    suspend fun getTodayPosts(today: String): List<PostEntity>

    @Query("SELECT COUNT(*) FROM wism_posts WHERE is_deleted = 0 AND date(created_at) = date(:today)")
    suspend fun getTodayCount(today: String): Int

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(post: PostEntity): Long

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(posts: List<PostEntity>)

    @Update
    suspend fun update(post: PostEntity)

    @Query("UPDATE wism_posts SET is_deleted = 1 WHERE id = :id")
    suspend fun softDelete(id: Int)
}
