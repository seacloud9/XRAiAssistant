package com.xraiassistant.data.local

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.doublePreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKeys
import com.xraiassistant.data.repositories.AppSettings
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.runBlocking
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Settings DataStore
 * 
 * Manages app settings using DataStore Preferences and encrypted API keys
 * Equivalent to UserDefaults in iOS
 */
@Singleton
class SettingsDataStore @Inject constructor(
    @ApplicationContext private val context: Context
) {
    
    companion object {
        private const val SETTINGS_NAME = "xraiassistant_settings"
        private const val ENCRYPTED_PREFS_NAME = "xraiassistant_secure"
        
        // DataStore keys
        private val SELECTED_MODEL = stringPreferencesKey("selected_model")
        private val TEMPERATURE = doublePreferencesKey("temperature")
        private val TOP_P = doublePreferencesKey("top_p")
        private val SYSTEM_PROMPT = stringPreferencesKey("system_prompt")
        private val SELECTED_LIBRARY_ID = stringPreferencesKey("selected_library_id")
        
        // API Key prefixes
        private const val API_KEY_PREFIX = "api_key_"
        private const val DEFAULT_API_KEY = "changeMe"
    }
    
    // DataStore for regular settings
    private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = SETTINGS_NAME)
    
    // Encrypted SharedPreferences for API keys
    private val encryptedPrefs by lazy {
        val masterKeyAlias = MasterKeys.getOrCreate(MasterKeys.AES256_GCM_SPEC)

        EncryptedSharedPreferences.create(
            ENCRYPTED_PREFS_NAME,
            masterKeyAlias,
            context,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
        )
    }
    
    /**
     * Save app settings
     */
    suspend fun saveSettings(settings: AppSettings) {
        context.dataStore.edit { preferences ->
            preferences[SELECTED_MODEL] = settings.selectedModel
            preferences[TEMPERATURE] = settings.temperature
            preferences[TOP_P] = settings.topP
            preferences[SYSTEM_PROMPT] = settings.systemPrompt
            settings.selectedLibraryId?.let { 
                preferences[SELECTED_LIBRARY_ID] = it 
            }
        }
    }
    
    /**
     * Get app settings
     */
    suspend fun getSettings(): AppSettings {
        return context.dataStore.data.map { preferences ->
            AppSettings(
                selectedModel = preferences[SELECTED_MODEL] ?: AppSettings().selectedModel,
                temperature = preferences[TEMPERATURE] ?: AppSettings().temperature,
                topP = preferences[TOP_P] ?: AppSettings().topP,
                systemPrompt = preferences[SYSTEM_PROMPT] ?: AppSettings().systemPrompt,
                selectedLibraryId = preferences[SELECTED_LIBRARY_ID] ?: AppSettings().selectedLibraryId
            )
        }.first()
    }
    
    /**
     * Clear all settings
     */
    suspend fun clearSettings() {
        context.dataStore.edit { preferences ->
            preferences.clear()
        }
        // Also clear encrypted API keys
        encryptedPrefs.edit().clear().apply()
    }
    
    /**
     * Set API key for provider (encrypted storage)
     * Uses commit() instead of apply() to ensure synchronous save
     */
    suspend fun setAPIKey(provider: String, key: String) {
        encryptedPrefs.edit()
            .putString("${API_KEY_PREFIX}${provider}", key)
            .commit()  // Synchronous save - ensures key is persisted before returning
    }
    
    /**
     * Get API key for provider (encrypted storage)
     */
    suspend fun getAPIKey(provider: String): String {
        return encryptedPrefs.getString("${API_KEY_PREFIX}${provider}", DEFAULT_API_KEY)
            ?: DEFAULT_API_KEY
    }
    
    /**
     * Synchronous version for repository use
     * Note: This blocks and should be used sparingly
     */
    fun getAPIKeySync(provider: String): String {
        return runBlocking {
            getAPIKey(provider)
        }
    }
    
    /**
     * Check if API key exists for provider
     */
    suspend fun hasAPIKey(provider: String): Boolean {
        val key = getAPIKey(provider)
        return key != DEFAULT_API_KEY && key.isNotBlank()
    }
    
    /**
     * Get all configured providers
     */
    suspend fun getConfiguredProviders(): List<String> {
        val allKeys = encryptedPrefs.all
        return allKeys.keys
            .filter { it.startsWith(API_KEY_PREFIX) }
            .map { it.removePrefix(API_KEY_PREFIX) }
            .filter { provider ->
                val key = allKeys["${API_KEY_PREFIX}${provider}"] as? String
                key != null && key != DEFAULT_API_KEY && key.isNotBlank()
            }
    }
}