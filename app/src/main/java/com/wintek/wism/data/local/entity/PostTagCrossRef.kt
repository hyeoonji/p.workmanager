package com.wintek.wism.data.local.entity

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index

@Entity(
    tableName = "wism_post_tags",
    primaryKeys = ["post_id", "tag_id"],
    foreignKeys = [
        ForeignKey(entity = PostEntity::class, parentColumns = ["id"], childColumns = ["post_id"], onDelete = ForeignKey.CASCADE),
        ForeignKey(entity = TagEntity::class, parentColumns = ["id"], childColumns = ["tag_id"], onDelete = ForeignKey.CASCADE)
    ],
    indices = [Index("tag_id")]
)
data class PostTagCrossRef(
    @ColumnInfo(name = "post_id") val postId: Int,
    @ColumnInfo(name = "tag_id") val tagId: Int
)
