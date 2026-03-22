package com.wintek.wism.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.wintek.wism.data.local.entity.ReadReceiptEntity

@Dao
interface ReadReceiptDao {
    @Query("SELECT COUNT(*) FROM wism_read_receipts WHERE post_id = :postId")
    suspend fun countByPostId(postId: Int): Int

    @Query("SELECT EXISTS(SELECT 1 FROM wism_read_receipts WHERE user_id = :userId AND post_id = :postId)")
    suspend fun isRead(userId: Int, postId: Int): Boolean

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(readReceipt: ReadReceiptEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(readReceipts: List<ReadReceiptEntity>)
}
