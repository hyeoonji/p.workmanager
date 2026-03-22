package com.wintek.wism.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.wintek.wism.data.local.entity.PostTagCrossRef
import com.wintek.wism.data.local.entity.TagEntity

@Dao
interface TagDao {
    @Query("SELECT t.name FROM wism_tags t INNER JOIN wism_post_tags pt ON t.id = pt.tag_id WHERE pt.post_id = :postId")
    suspend fun getTagNamesByPostId(postId: Int): List<String>

    @Query("SELECT * FROM wism_tags WHERE name = :name LIMIT 1")
    suspend fun findByName(name: String): TagEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(tag: TagEntity): Long

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(tags: List<TagEntity>)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertPostTag(crossRef: PostTagCrossRef)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertPostTags(crossRefs: List<PostTagCrossRef>)

    @Query("DELETE FROM wism_post_tags WHERE post_id = :postId")
    suspend fun deletePostTags(postId: Int)
}
