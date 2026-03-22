package com.wintek.wism.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.wintek.wism.data.model.Post
import com.wintek.wism.data.repository.AuthRepository
import com.wintek.wism.data.repository.PostRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class PostListState(
    val isLoading: Boolean = false,
    val posts: List<Post> = emptyList(),
    val searchQuery: String = "",
    val selectedCategory: String? = null,
    val selectedPriority: String? = null
)

data class PostDetailState(
    val isLoading: Boolean = false,
    val post: Post? = null
)

@HiltViewModel
class PostViewModel @Inject constructor(
    private val postRepository: PostRepository,
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _listState = MutableStateFlow(PostListState())
    val listState: StateFlow<PostListState> = _listState.asStateFlow()

    private val _detailState = MutableStateFlow(PostDetailState())
    val detailState: StateFlow<PostDetailState> = _detailState.asStateFlow()

    fun loadPosts(category: String? = null, priority: String? = null, search: String? = null) {
        viewModelScope.launch {
            _listState.value = _listState.value.copy(
                isLoading = true,
                selectedCategory = category,
                selectedPriority = priority,
                searchQuery = search ?: ""
            )
            val posts = postRepository.getPosts(category = category, priority = priority, search = search)
            _listState.value = _listState.value.copy(isLoading = false, posts = posts)
        }
    }

    fun loadMyPosts() {
        viewModelScope.launch {
            _listState.value = _listState.value.copy(isLoading = true)
            val userId = authRepository.getCurrentUserId() ?: return@launch
            val posts = postRepository.getMyPosts(userId)
            _listState.value = _listState.value.copy(isLoading = false, posts = posts)
        }
    }

    fun loadBookmarkedPosts() {
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
        }
    }

    fun markAsRead(postId: Int) {
        viewModelScope.launch {
            val userId = authRepository.getCurrentUserId() ?: return@launch
            postRepository.markAsRead(userId, postId)
        }
    }

    fun createPost(title: String, content: String, category: String, priority: String, project: String?, tags: List<String>) {
        viewModelScope.launch {
            val userId = authRepository.getCurrentUserId() ?: return@launch
            postRepository.createPost(userId, title, content, category, priority, project, tags)
        }
    }

    fun updatePost(postId: Int, title: String, content: String, category: String, priority: String, project: String?, tags: List<String>) {
        viewModelScope.launch {
            postRepository.updatePost(postId, title, content, category, priority, project, tags)
        }
    }

    fun deletePost(postId: Int) {
        viewModelScope.launch {
            postRepository.deletePost(postId)
        }
    }
}
