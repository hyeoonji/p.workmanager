package com.wintek.wism.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.wintek.wism.data.model.UserProfile
import com.wintek.wism.data.repository.AuthRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class AuthState(
    val isLoading: Boolean = true,
    val isLoggedIn: Boolean = false,
    val currentUserId: Int? = null,
    val user: UserProfile? = null,
    val loginError: String? = null
)

@HiltViewModel
class AuthViewModel @Inject constructor(
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _state = MutableStateFlow(AuthState())
    val state: StateFlow<AuthState> = _state.asStateFlow()

    init {
        checkSession()
    }

    private fun checkSession() {
        viewModelScope.launch {
            val userId = authRepository.getCurrentUserId()
            val autoLogin = authRepository.isAutoLoginEnabled()
            _state.value = _state.value.copy(
                isLoading = false,
                isLoggedIn = userId != null && autoLogin,
                currentUserId = userId
            )
        }
    }

    fun login(loginId: String, password: String, autoLogin: Boolean) {
        viewModelScope.launch {
            _state.value = _state.value.copy(isLoading = true, loginError = null)
            val user = authRepository.login(loginId, password)
            if (user != null) {
                authRepository.setAutoLoginEnabled(autoLogin)
                _state.value = _state.value.copy(
                    isLoading = false,
                    isLoggedIn = true,
                    currentUserId = user.id,
                    user = user,
                    loginError = null
                )
            } else {
                _state.value = _state.value.copy(
                    isLoading = false,
                    loginError = "아이디 또는 비밀번호가 일치하지 않습니다."
                )
            }
        }
    }

    fun logout() {
        viewModelScope.launch {
            authRepository.logout()
            authRepository.setAutoLoginEnabled(false)
            _state.value = AuthState(isLoading = false)
        }
    }
}
