package com.wintek.wism.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import com.wintek.wism.data.local.entity.UserSettingsEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface UserSettingsDao {
    @Query("SELECT * FROM wism_user_settings WHERE user_id = :userId LIMIT 1")
    suspend fun getByUserId(userId: Int): UserSettingsEntity?

    @Query("SELECT * FROM wism_user_settings WHERE user_id = :userId LIMIT 1")
    fun observeByUserId(userId: Int): Flow<UserSettingsEntity?>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(settings: UserSettingsEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(settings: List<UserSettingsEntity>)

    @Update
    suspend fun update(settings: UserSettingsEntity)
}
