package com.wintek.wism.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.wintek.wism.data.local.entity.BookmarkEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface BookmarkDao {
    @Query("SELECT post_id FROM wism_bookmarks WHERE user_id = :userId")
    suspend fun getBookmarkedPostIds(userId: Int): List<Int>

    @Query("SELECT post_id FROM wism_bookmarks WHERE user_id = :userId")
    fun observeBookmarkedPostIds(userId: Int): Flow<List<Int>>

    @Query("SELECT EXISTS(SELECT 1 FROM wism_bookmarks WHERE user_id = :userId AND post_id = :postId)")
    suspend fun isBookmarked(userId: Int, postId: Int): Boolean

    @Query("SELECT COUNT(*) FROM wism_bookmarks WHERE user_id = :userId")
    suspend fun countByUserId(userId: Int): Int

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(bookmark: BookmarkEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(bookmarks: List<BookmarkEntity>)

    @Query("DELETE FROM wism_bookmarks WHERE user_id = :userId AND post_id = :postId")
    suspend fun delete(userId: Int, postId: Int)
}
