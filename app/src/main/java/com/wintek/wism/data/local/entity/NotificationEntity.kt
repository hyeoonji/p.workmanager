package com.wintek.wism.data.local.entity

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey

@Entity(
    tableName = "wism_notifications",
    foreignKeys = [
        ForeignKey(entity = UserEntity::class, parentColumns = ["id"], childColumns = ["user_id"], onDelete = ForeignKey.CASCADE),
        ForeignKey(entity = PostEntity::class, parentColumns = ["id"], childColumns = ["post_id"], onDelete = ForeignKey.SET_NULL),
        ForeignKey(entity = UserEntity::class, parentColumns = ["id"], childColumns = ["sender_id"], onDelete = ForeignKey.SET_NULL)
    ],
    indices = [Index("user_id", "is_read"), Index("created_at")]
)
data class NotificationEntity(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    @ColumnInfo(name = "user_id") val userId: Int,
    val type: String,
    @ColumnInfo(name = "post_id") val postId: Int? = null,
    @ColumnInfo(name = "comment_id") val commentId: Int? = null,
    @ColumnInfo(name = "sender_id") val senderId: Int? = null,
    val title: String,
    val content: String,
    @ColumnInfo(name = "memo_title") val memoTitle: String? = null,
    @ColumnInfo(name = "is_read") val isRead: Boolean = false,
    @ColumnInfo(name = "created_at") val createdAt: String
)
