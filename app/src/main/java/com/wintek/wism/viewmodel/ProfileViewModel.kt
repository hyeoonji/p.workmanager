package com.wintek.wism.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.wintek.wism.data.model.UserProfile
import com.wintek.wism.data.repository.AuthRepository
import com.wintek.wism.data.repository.UserRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class ProfileState(
    val isLoading: Boolean = false,
    val profile: UserProfile? = null
)

@HiltViewModel
class ProfileViewModel @Inject constructor(
    private val userRepository: UserRepository,
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _state = MutableStateFlow(ProfileState())
    val state: StateFlow<ProfileState> = _state.asStateFlow()

    fun loadProfile() {
        viewModelScope.launch {
            _state.value = _state.value.copy(isLoading = true)
            val userId = authRepository.getCurrentUserId() ?: return@launch
            val profile = userRepository.getUserProfile(userId)
            _state.value = ProfileState(isLoading = false, profile = profile)
        }
    }

    fun updateProfile(name: String, email: String?, phone: String?, department: String?, position: String?) {
        viewModelScope.launch {
            val userId = authRepository.getCurrentUserId() ?: return@launch
            userRepository.updateProfile(userId, name, email, phone, department, position)
            loadProfile()
        }
    }

    fun updatePushEnabled(enabled: Boolean) {
        viewModelScope.launch {
            val userId = authRepository.getCurrentUserId() ?: return@launch
            userRepository.updatePushEnabled(userId, enabled)
            loadProfile()
        }
    }
}
