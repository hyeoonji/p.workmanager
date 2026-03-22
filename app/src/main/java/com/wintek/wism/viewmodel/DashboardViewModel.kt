package com.wintek.wism.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.wintek.wism.data.model.DashboardData
import com.wintek.wism.data.repository.AuthRepository
import com.wintek.wism.data.repository.PostRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class DashboardState(
    val isLoading: Boolean = false,
    val data: DashboardData = DashboardData()
)

@HiltViewModel
class DashboardViewModel @Inject constructor(
    private val postRepository: PostRepository,
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _state = MutableStateFlow(DashboardState())
    val state: StateFlow<DashboardState> = _state.asStateFlow()

    fun loadDashboard() {
        viewModelScope.launch {
            _state.value = _state.value.copy(isLoading = true)
            val userId = authRepository.getCurrentUserId() ?: return@launch
            val data = postRepository.getDashboardData(userId)
            _state.value = DashboardState(isLoading = false, data = data)
        }
    }
}
