package com.wintek.wism.di

import android.content.Context
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.sqlite.db.SupportSQLiteDatabase
import com.wintek.wism.data.local.SeedData
import com.wintek.wism.data.local.WismDatabase
import com.wintek.wism.data.local.dao.*
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {

    @Volatile
    private var INSTANCE: WismDatabase? = null

    @Provides
    @Singleton
    fun provideDatabase(@ApplicationContext context: Context): WismDatabase {
        return INSTANCE ?: synchronized(this) {
            val instance = Room.databaseBuilder(
                context,
                WismDatabase::class.java,
                "wism_database"
            )
                .fallbackToDestructiveMigration(dropAllTables = true)
                .addCallback(object : RoomDatabase.Callback() {
                    override fun onCreate(db: SupportSQLiteDatabase) {
                        super.onCreate(db)
                        INSTANCE?.let { database ->
                            CoroutineScope(Dispatchers.IO).launch {
                                seedDatabase(database)
                            }
                        }
                    }
                })
                .build()
            INSTANCE = instance
            instance
        }
    }

    private suspend fun seedDatabase(database: WismDatabase) {
        database.userDao().insertAll(SeedData.users())
        database.postDao().insertAll(SeedData.posts())
        database.commentDao().insertAll(SeedData.comments())
        database.tagDao().insertAll(SeedData.tags())
        database.tagDao().insertPostTags(SeedData.postTags())
        database.referenceDao().insertAll(SeedData.postReferences())
        database.bookmarkDao().insertAll(SeedData.bookmarks())
        database.readReceiptDao().insertAll(SeedData.readReceipts())
        database.notificationDao().insertAll(SeedData.notifications())
        database.userSettingsDao().insertAll(SeedData.userSettings())
    }

    @Provides fun provideUserDao(db: WismDatabase): UserDao = db.userDao()
    @Provides fun providePostDao(db: WismDatabase): PostDao = db.postDao()
    @Provides fun provideCommentDao(db: WismDatabase): CommentDao = db.commentDao()
    @Provides fun provideBookmarkDao(db: WismDatabase): BookmarkDao = db.bookmarkDao()
    @Provides fun provideReadReceiptDao(db: WismDatabase): ReadReceiptDao = db.readReceiptDao()
    @Provides fun provideNotificationDao(db: WismDatabase): NotificationDao = db.notificationDao()
    @Provides fun provideTagDao(db: WismDatabase): TagDao = db.tagDao()
    @Provides fun provideReferenceDao(db: WismDatabase): ReferenceDao = db.referenceDao()
    @Provides fun provideUserSettingsDao(db: WismDatabase): UserSettingsDao = db.userSettingsDao()
}
