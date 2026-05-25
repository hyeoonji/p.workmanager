package com.wintek.wism.data.local.entity

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index

/**
 * 게시글의 "참조" 대상 사용자(사람). 담당자 태그와 달리 사용자 ID로 참조하여 동명이인 문제를 방지한다.
 */
@Entity(
    tableName = "wism_post_references",
    primaryKeys = ["post_id", "user_id"],
    foreignKeys = [
        ForeignKey(entity = PostEntity::class, parentColumns = ["id"], childColumns = ["post_id"], onDelete = ForeignKey.CASCADE),
        ForeignKey(entity = UserEntity::class, parentColumns = ["id"], childColumns = ["user_id"], onDelete = ForeignKey.CASCADE)
    ],
    indices = [Index("user_id")]
)
data class PostReferenceEntity(
    @ColumnInfo(name = "post_id") val postId: Int,
    @ColumnInfo(name = "user_id") val userId: Int
)
