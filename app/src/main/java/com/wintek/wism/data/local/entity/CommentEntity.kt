package com.wintek.wism.data.local.entity

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey

@Entity(
    tableName = "wism_comments",
    foreignKeys = [
        ForeignKey(entity = PostEntity::class, parentColumns = ["id"], childColumns = ["post_id"], onDelete = ForeignKey.CASCADE),
        ForeignKey(entity = UserEntity::class, parentColumns = ["id"], childColumns = ["user_id"], onDelete = ForeignKey.CASCADE)
    ],
    indices = [Index("post_id"), Index("user_id")]
)
data class CommentEntity(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    @ColumnInfo(name = "post_id") val postId: Int,
    @ColumnInfo(name = "user_id") val userId: Int,
    val content: String,
    val type: String = "comment",
    @ColumnInfo(name = "is_deleted") val isDeleted: Boolean = false,
    @ColumnInfo(name = "created_at") val createdAt: String,
    @ColumnInfo(name = "updated_at") val updatedAt: String
)
