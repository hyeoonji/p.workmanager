package com.wintek.wism.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import com.wintek.wism.data.local.entity.UserEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface UserDao {
    @Query("SELECT * FROM wism_users WHERE login_id = :loginId AND password = :password AND is_active = 1 LIMIT 1")
    suspend fun findByLoginIdAndPassword(loginId: String, password: String): UserEntity?

    @Query("SELECT * FROM wism_users WHERE id = :id")
    suspend fun getById(id: Int): UserEntity?

    @Query("SELECT * FROM wism_users WHERE id = :id")
    fun observeById(id: Int): Flow<UserEntity?>

    @Query("SELECT * FROM wism_users WHERE is_active = 1")
    suspend fun getAllActive(): List<UserEntity>

    @Query("SELECT COUNT(*) FROM wism_users WHERE is_active = 1")
    suspend fun getActiveCount(): Int

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(users: List<UserEntity>)

    @Update
    suspend fun update(user: UserEntity)
}
