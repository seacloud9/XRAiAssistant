package com.xraiassistant.data.repositories

import com.xraiassistant.data.local.SettingsDataStore
import com.xraiassistant.data.models.AIModels
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Settings Repository
 * 
 * Manages app settings persistence
 * Equivalent to UserDefaults logic in iOS ChatViewModel
 */
@Singleton
class SettingsRepository @Inject constructor(
    private val settingsDataStore: SettingsDataStore
) {
    
    /**
     * Save all settings
     */
    suspend fun saveSettings(
        selectedModel: String,
        temperature: Double,
        topP: Double,
        systemPrompt: String,
        selectedLibraryId: String?
    ) {
        settingsDataStore.saveSettings(
            AppSettings(
                selectedModel = selectedModel,
                temperature = temperature,
                topP = topP,
                systemPrompt = systemPrompt,
                selectedLibraryId = selectedLibraryId
            )
        )
    }
    
    /**
     * Get current settings
     */
    suspend fun getSettings(): AppSettings {
        return settingsDataStore.getSettings()
    }
    
    /**
     * Clear all settings (reset to defaults)
     */
    suspend fun clearSettings() {
        settingsDataStore.clearSettings()
    }
}

/**
 * App settings data class
 */
data class AppSettings(
    val selectedModel: String = AIModels.DEEPSEEK_R1_70B.id,
    val temperature: Double = 0.7,
    val topP: Double = 0.9,
    val systemPrompt: String = "",
    val selectedLibraryId: String? = "babylonjs"
)