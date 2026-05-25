package com.wintek.wism.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.wintek.wism.data.model.Author
import com.wintek.wism.data.model.Post
import com.wintek.wism.data.repository.AuthRepository
import com.wintek.wism.data.repository.CommentRepository
import com.wintek.wism.data.repository.PostRepository
import com.wintek.wism.data.repository.UserRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class PostListState(
    val isLoading: Boolean = false,
    val posts: List<Post> = emptyList(),
    val searchQuery: String = "",
    val selectedCategory: String? = null,
    val sortByPriority: Boolean = true
)

data class PostDetailState(
    val isLoading: Boolean = false,
    val post: Post? = null
)

sealed class PostEvent {
    object Saved : PostEvent()
    object Deleted : PostEvent()
}

@HiltViewModel
class PostViewModel @Inject constructor(
    private val postRepository: PostRepository,
    private val commentRepository: CommentRepository,
    private val authRepository: AuthRepository,
    private val userRepository: UserRepository
) : ViewModel() {

    private val _listState = MutableStateFlow(PostListState())
    val listState: StateFlow<PostListState> = _listState.asStateFlow()

    private val _detailState = MutableStateFlow(PostDetailState())
    val detailState: StateFlow<PostDetailState> = _detailState.asStateFlow()

    private val _availableUsers = MutableStateFlow<List<Author>>(emptyList())
    val availableUsers: StateFlow<List<Author>> = _availableUsers.asStateFlow()

    private val _event = MutableSharedFlow<PostEvent>()
    val event = _event.asSharedFlow()

    init {
        viewModelScope.launch {
            _availableUsers.value = userRepository.getActiveUsers()
        }
    }

    private var currentMode: ListMode = ListMode.All

    private sealed class ListMode {
        object All : ListMode()
        object My : ListMode()
        object Bookmarks : ListMode()
    }

    fun loadPosts(
        category: String? = null,
        search: String? = null,
        sortByPriority: Boolean = true
    ) {
        currentMode = ListMode.All
        viewModelScope.launch {
            _listState.value = _listState.value.copy(
                isLoading = true,
                selectedCategory = category,
                sortByPriority = sortByPriority,
                searchQuery = search ?: ""
            )
            val userId = authRepository.getCurrentUserId() ?: return@launch
            val posts = postRepository.getPosts(
                currentUserId = userId,
                category = category,
                search = search,
                sortByPriority = sortByPriority
            )
            _listState.value = _listState.value.copy(isLoading = false, posts = posts)
        }
    }

    fun loadMyPosts() {
        currentMode = ListMode.My
        viewModelScope.launch {
            _listState.value = _listState.value.copy(isLoading = true)
            val userId = authRepository.getCurrentUserId() ?: return@launch
            val posts = postRepository.getMyPosts(userId)
            _listState.value = _listState.value.copy(isLoading = false, posts = posts)
        }
    }

    fun loadBookmarkedPosts() {
        currentMode = ListMode.Bookmarks
        viewModelScope.launch {
            _listState.value = _listState.value.copy(isLoading = true)
            val userId = authRepository.getCurrentUserId() ?: return@launch
            val posts = postRepository.getBookmarkedPosts(userId)
            _listState.value = _listState.value.copy(isLoading = false, posts = posts)
        }
    }

    fun loadPostDetail(postId: Int) {
        viewModelScope.launch {
            _detailState.value = PostDetailState(isLoading = true)
            val userId = authRepository.getCurrentUserId() ?: return@launch
            val post = postRepository.getPostDetail(postId, userId)
            _detailState.value = PostDetailState(isLoading = false, post = post)
        }
    }

    fun toggleBookmark(postId: Int) {
        viewModelScope.launch {
            val userId = authRepository.getCurrentUserId() ?: return@launch
            postRepository.toggleBookmark(userId, postId)
            reloadCurrentList()
        }
    }

    fun markAsRead(postId: Int) {
        viewModelScope.launch {
            val userId = authRepository.getCurrentUserId() ?: return@launch
            postRepository.markAsRead(userId, postId)
            loadPostDetail(postId)
        }
    }

    fun addComment(postId: Int, content: String) {
        viewModelScope.launch {
            val userId = authRepository.getCurrentUserId() ?: return@launch
            commentRepository.addComment(postId, userId, content)
            loadPostDetail(postId)
        }
    }

    fun editComment(postId: Int, commentId: Int, content: String) {
        viewModelScope.launch {
            commentRepository.updateComment(commentId, content)
            loadPostDetail(postId)
        }
    }

    fun deleteComment(postId: Int, commentId: Int) {
        viewModelScope.launch {
            commentRepository.deleteComment(commentId)
            loadPostDetail(postId)
        }
    }

    fun createPost(title: String, content: String, category: String, priority: String, project: String?, scheduledDate: String?, tags: List<String>, referenceIds: List<Int>) {
        viewModelScope.launch {
            val userId = authRepository.getCurrentUserId() ?: return@launch
            postRepository.createPost(userId, title, content, category, priority, project, scheduledDate, tags, referenceIds)
            _event.emit(PostEvent.Saved)
        }
    }

    fun updatePost(postId: Int, title: String, content: String, category: String, priority: String, project: String?, scheduledDate: String?, tags: List<String>, referenceIds: List<Int>) {
        viewModelScope.launch {
            postRepository.updatePost(postId, title, content, category, priority, project, scheduledDate, tags, referenceIds)
            _event.emit(PostEvent.Saved)
        }
    }

    fun deletePost(postId: Int) {
        viewModelScope.launch {
            postRepository.deletePost(postId)
            _event.emit(PostEvent.Deleted)
        }
    }

    private fun reloadCurrentList() {
        val state = _listState.value
        when (currentMode) {
            ListMode.All -> loadPosts(state.selectedCategory, state.searchQuery, state.sortByPriority)
            ListMode.My -> loadMyPosts()
            ListMode.Bookmarks -> loadBookmarkedPosts()
        }
    }
}
