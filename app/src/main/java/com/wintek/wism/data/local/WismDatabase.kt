package com.wintek.wism.data.local

import androidx.room.Database
import androidx.room.RoomDatabase
import com.wintek.wism.data.local.dao.*
import com.wintek.wism.data.local.entity.*

@Database(
    entities = [
        UserEntity::class,
        PostEntity::class,
        CommentEntity::class,
        TagEntity::class,
        PostTagCrossRef::class,
        PostReferenceEntity::class,
        BookmarkEntity::class,
        ReadReceiptEntity::class,
        NotificationEntity::class,
        UserSettingsEntity::class
    ],
    version = 3,
    exportSchema = true
)
abstract class WismDatabase : RoomDatabase() {
    abstract fun userDao(): UserDao
    abstract fun postDao(): PostDao
    abstract fun commentDao(): CommentDao
    abstract fun bookmarkDao(): BookmarkDao
    abstract fun readReceiptDao(): ReadReceiptDao
    abstract fun notificationDao(): NotificationDao
    abstract fun tagDao(): TagDao
    abstract fun referenceDao(): ReferenceDao
    abstract fun userSettingsDao(): UserSettingsDao
}
