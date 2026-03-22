package com.wintek.wism.data.local.entity

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "wism_users")
data class UserEntity(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    @ColumnInfo(name = "login_id") val loginId: String,
    val password: String,
    val name: String,
    val department: String? = null,
    val position: String? = null,
    val email: String? = null,
    val phone: String? = null,
    @ColumnInfo(name = "photo_url") val photoUrl: String? = null,
    val role: String = "manager",
    @ColumnInfo(name = "is_active") val isActive: Boolean = true,
    @ColumnInfo(name = "created_at") val createdAt: String,
    @ColumnInfo(name = "updated_at") val updatedAt: String
)
