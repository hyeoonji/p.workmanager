package com.wintek.wism.data.repository.impl

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.wintek.wism.data.local.dao.UserDao
import com.wintek.wism.data.local.dao.UserSettingsDao
import com.wintek.wism.data.model.UserProfile
import com.wintek.wism.data.model.UserSettings
import com.wintek.wism.data.model.UserStats
import com.wintek.wism.data.repository.AuthRepository
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import javax.inject.Inject

private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "wism_session")

class AuthRepositoryImpl @Inject constructor(
    @ApplicationContext private val context: Context,
    private val userDao: UserDao,
    private val userSettingsDao: UserSettingsDao
) : AuthRepository {

    companion object {
        private val KEY_USER_ID = intPreferencesKey("current_user_id")
        private val KEY_AUTO_LOGIN = booleanPreferencesKey("auto_login_enabled")
    }

    override suspend fun login(loginId: String, password: String): UserProfile? {
        val user = userDao.findByLoginIdAndPassword(loginId, password) ?: return null
        setCurrentUserId(user.id)
        val settings = userSettingsDao.getByUserId(user.id)
        return UserProfile(
            id = user.id,
            loginId = user.loginId,
            name = user.name,
            department = user.department,
            position = user.position,
            email = user.email,
            phone = user.phone,
            photoUrl = user.photoUrl,
            role = user.role,
            settings = UserSettings(
                pushEnabled = settings?.pushEnabled ?: true,
                autoLoginEnabled = settings?.autoLoginEnabled ?: false
            )
        )
    }

    override suspend fun getCurrentUserId(): Int? {
        return context.dataStore.data.map { prefs ->
            prefs[KEY_USER_ID]
        }.first()
    }

    override suspend fun setCurrentUserId(userId: Int?) {
        context.dataStore.edit { prefs ->
            if (userId != null) {
                prefs[KEY_USER_ID] = userId
            } else {
                prefs.remove(KEY_USER_ID)
            }
        }
    }

    override suspend fun isAutoLoginEnabled(): Boolean {
        return context.dataStore.data.map { prefs ->
            prefs[KEY_AUTO_LOGIN] ?: false
        }.first()
    }

    override suspend fun setAutoLoginEnabled(enabled: Boolean) {
        context.dataStore.edit { prefs ->
            prefs[KEY_AUTO_LOGIN] = enabled
        }
    }

    override suspend fun logout() {
        context.dataStore.edit { prefs ->
            prefs.remove(KEY_USER_ID)
        }
    }
}
