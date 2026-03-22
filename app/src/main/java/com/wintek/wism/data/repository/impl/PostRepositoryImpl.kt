package com.wintek.wism.data.repository.impl

import com.wintek.wism.data.local.dao.*
import com.wintek.wism.data.local.entity.BookmarkEntity
import com.wintek.wism.data.local.entity.CommentEntity
import com.wintek.wism.data.local.entity.PostEntity
import com.wintek.wism.data.local.entity.PostTagCrossRef
import com.wintek.wism.data.local.entity.ReadReceiptEntity
import com.wintek.wism.data.local.entity.TagEntity
import com.wintek.wism.data.model.*
import com.wintek.wism.data.repository.PostRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import javax.inject.Inject

class PostRepositoryImpl @Inject constructor(
    private val postDao: PostDao,
    private val userDao: UserDao,
    private val commentDao: CommentDao,
    private val bookmarkDao: BookmarkDao,
    private val readReceiptDao: ReadReceiptDao,
    private val tagDao: TagDao
) : PostRepository {

    private val fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss")

    override suspend fun getPosts(
        currentUserId: Int,
        category: String?,
        search: String?,
        sortByPriority: Boolean,
        page: Int,
        limit: Int
    ): List<Post> {
        val offset = (page - 1) * limit
        val entities = if (sortByPriority) {
            postDao.getFilteredPostsByPriority(category, search, limit, offset)
        } else {
            postDao.getFilteredPostsByDate(category, search, limit, offset)
        }
        return entities.map { it.toPost(currentUserId) }
    }

    override suspend fun getMyPosts(userId: Int): List<Post> {
        return postDao.getByUserId(userId).map { it.toPost(userId) }
    }

    override suspend fun getBookmarkedPosts(userId: Int): List<Post> {
        val bookmarkedIds = bookmarkDao.getBookmarkedPostIds(userId)
        return bookmarkedIds.mapNotNull { postId ->
            postDao.getById(postId)?.toPost(userId)
        }
    }

    override suspend fun getPostDetail(postId: Int, currentUserId: Int): Post? {
        val entity = postDao.getById(postId) ?: return null
        val user = userDao.getById(entity.userId)
        val comments = commentDao.getByPostId(postId).map { comment ->
            val commentUser = userDao.getById(comment.userId)
            Comment(
                id = comment.id,
                author = Author(id = comment.userId, name = commentUser?.name ?: "알 수 없음"),
                content = comment.content,
                type = comment.type,
                createdAt = comment.createdAt
            )
        }
        val tags = tagDao.getTagNamesByPostId(postId)
        val readBy = readReceiptDao.countByPostId(postId)
        val totalReaders = userDao.getActiveCount()
        val isRead = readReceiptDao.isRead(currentUserId, postId)
        val isBookmarked = bookmarkDao.isBookmarked(currentUserId, postId)

        return Post(
            id = entity.id,
            title = entity.title,
            content = entity.content,
            category = Category.fromValue(entity.category),
            priority = Priority.fromValue(entity.priority),
            author = Author(
                id = entity.userId,
                name = user?.name ?: "알 수 없음",
                department = user?.department,
                position = user?.position
            ),
            project = entity.project,
            tags = tags,
            commentCount = comments.size,
            readBy = readBy,
            totalReaders = totalReaders,
            isRead = isRead,
            isBookmarked = isBookmarked,
            isMine = entity.userId == currentUserId,
            comments = comments,
            createdAt = entity.createdAt,
            updatedAt = entity.updatedAt
        )
    }

    override suspend fun createPost(
        userId: Int, title: String, content: String,
        category: String, priority: String, project: String?, tags: List<String>
    ): Long {
        val now = LocalDateTime.now().format(fmt)
        val postId = postDao.insert(
            PostEntity(
                userId = userId, title = title, content = content,
                category = category, priority = priority, project = project,
                createdAt = now, updatedAt = now
            )
        )
        saveTags(postId.toInt(), tags)
        return postId
    }

    override suspend fun updatePost(
        postId: Int, title: String, content: String,
        category: String, priority: String, project: String?, tags: List<String>
    ) {
        val existing = postDao.getById(postId) ?: return
        val now = LocalDateTime.now().format(fmt)
        postDao.update(
            existing.copy(
                title = title, content = content, category = category,
                priority = priority, project = project, updatedAt = now
            )
        )
        tagDao.deletePostTags(postId)
        saveTags(postId, tags)
    }

    override suspend fun deletePost(postId: Int) {
        postDao.softDelete(postId)
    }

    override suspend fun toggleBookmark(userId: Int, postId: Int): Boolean {
        val isBookmarked = bookmarkDao.isBookmarked(userId, postId)
        if (isBookmarked) {
            bookmarkDao.delete(userId, postId)
        } else {
            val now = LocalDateTime.now().format(fmt)
            bookmarkDao.insert(BookmarkEntity(userId, postId, now))
        }
        return !isBookmarked
    }

    override suspend fun markAsRead(userId: Int, postId: Int) {
        if (!readReceiptDao.isRead(userId, postId)) {
            val now = LocalDateTime.now().format(fmt)
            readReceiptDao.insert(ReadReceiptEntity(userId, postId, now))
            commentDao.insert(
                CommentEntity(
                    postId = postId, userId = userId, content = "확인 완료",
                    type = "status", createdAt = now, updatedAt = now
                )
            )
        }
    }

    override suspend fun getDashboardData(userId: Int): DashboardData {
        val today = LocalDate.now().toString()
        val urgentPosts = postDao.getUrgentPosts(3)
        val todayPosts = postDao.getTodayPosts(today)
        return DashboardData(
            urgentCount = postDao.getUrgentCount(),
            todayCount = postDao.getTodayCount(today),
            myMemoCount = postDao.countByUserId(userId),
            urgentMemos = urgentPosts.map { it.toPost(userId) },
            todayMemos = todayPosts.map { it.toPost(userId) }
        )
    }

    override fun observeAllPosts(): Flow<List<Post>> {
        return postDao.observeAllPosts().map { entities ->
            entities.map { it.toPost() }
        }
    }

    private suspend fun PostEntity.toPost(currentUserId: Int? = null): Post {
        val user = userDao.getById(userId)
        val commentCount = commentDao.countByPostId(id)
        val readBy = readReceiptDao.countByPostId(id)
        val totalReaders = userDao.getActiveCount()
        val tags = tagDao.getTagNamesByPostId(id)
        val isRead = currentUserId?.let { readReceiptDao.isRead(it, id) } ?: false
        val isBookmarked = currentUserId?.let { bookmarkDao.isBookmarked(it, id) } ?: false

        return Post(
            id = id, title = title, content = content,
            category = Category.fromValue(category),
            priority = Priority.fromValue(priority),
            author = Author(id = userId, name = user?.name ?: "알 수 없음", department = user?.department),
            project = project, tags = tags, commentCount = commentCount,
            readBy = readBy, totalReaders = totalReaders,
            isRead = isRead, isBookmarked = isBookmarked,
            isMine = currentUserId == userId,
            createdAt = createdAt, updatedAt = updatedAt
        )
    }

    private suspend fun saveTags(postId: Int, tagNames: List<String>) {
        val now = LocalDateTime.now().format(fmt)
        for (name in tagNames) {
            val tag = tagDao.findByName(name) ?: run {
                val id = tagDao.insert(TagEntity(name = name, createdAt = now))
                TagEntity(id = id.toInt(), name = name, createdAt = now)
            }
            tagDao.insertPostTag(PostTagCrossRef(postId = postId, tagId = tag.id))
        }
    }
}
