package com.wintek.wism.data.local.entity

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index

@Entity(
    tableName = "wism_bookmarks",
    primaryKeys = ["user_id", "post_id"],
    foreignKeys = [
        ForeignKey(entity = UserEntity::class, parentColumns = ["id"], childColumns = ["user_id"], onDelete = ForeignKey.CASCADE),
        ForeignKey(entity = PostEntity::class, parentColumns = ["id"], childColumns = ["post_id"], onDelete = ForeignKey.CASCADE)
    ],
    indices = [Index("user_id"), Index("post_id")]
)
data class BookmarkEntity(
    @ColumnInfo(name = "user_id") val userId: Int,
    @ColumnInfo(name = "post_id") val postId: Int,
    @ColumnInfo(name = "created_at") val createdAt: String
)
