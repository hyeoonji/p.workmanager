package com.wintek.wism.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.wintek.wism.data.local.entity.NotificationEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface NotificationDao {
    @Query("SELECT * FROM wism_notifications WHERE user_id = :userId ORDER BY created_at DESC")
    suspend fun getByUserId(userId: Int): List<NotificationEntity>

    @Query("SELECT * FROM wism_notifications WHERE user_id = :userId ORDER BY created_at DESC")
    fun observeByUserId(userId: Int): Flow<List<NotificationEntity>>

    @Query("SELECT COUNT(*) FROM wism_notifications WHERE user_id = :userId AND is_read = 0")
    suspend fun getUnreadCount(userId: Int): Int

    @Query("SELECT COUNT(*) FROM wism_notifications WHERE user_id = :userId AND is_read = 0")
    fun observeUnreadCount(userId: Int): Flow<Int>

    @Query("UPDATE wism_notifications SET is_read = 1 WHERE id = :id")
    suspend fun markAsRead(id: Int)

    @Query("UPDATE wism_notifications SET is_read = 1 WHERE user_id = :userId")
    suspend fun markAllAsRead(userId: Int)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(notification: NotificationEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(notifications: List<NotificationEntity>)
}
