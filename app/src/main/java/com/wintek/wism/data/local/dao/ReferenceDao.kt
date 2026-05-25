package com.wintek.wism.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.wintek.wism.data.local.entity.PostReferenceEntity
import com.wintek.wism.data.local.entity.UserEntity

@Dao
interface ReferenceDao {
    @Query("SELECT u.* FROM wism_users u INNER JOIN wism_post_references r ON u.id = r.user_id WHERE r.post_id = :postId")
    suspend fun getReferenceUsers(postId: Int): List<UserEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(ref: PostReferenceEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(refs: List<PostReferenceEntity>)

    @Query("DELETE FROM wism_post_references WHERE post_id = :postId")
    suspend fun deleteByPost(postId: Int)
}
