package com.xrai.assistant

import android.app.Application
import dagger.hilt.android.HiltAndroidApp
import timber.log.Timber

/**
 * XRAiAssistant Application class
 *
 * iOS equivalent: XRAiAssistant.swift (app entry point)
 *
 * Responsibilities:
 * - Initialize dependency injection (Hilt)
 * - Configure logging (Timber)
 * - Set up global configurations
 */
@HiltAndroidApp
class XRAiApplication : Application() {

    override fun onCreate() {
        super.onCreate()

        // Initialize logging
        if (BuildConfig.DEBUG) {
            Timber.plant(Timber.DebugTree())
            Timber.d("🚀 XRAiAssistant initialization starting...")
        }

        // Log application info
        Timber.i("📱 App Version: ${BuildConfig.VERSION_NAME} (${BuildConfig.VERSION_CODE})")
        Timber.i("🔧 Build Type: ${BuildConfig.BUILD_TYPE}")
        Timber.i("✅ XRAiAssistant initialization complete")
    }

    companion object {
        /**
         * Default API key constant
         * Users MUST configure their Together AI API key in Settings
         *
         * iOS equivalent: DEFAULT_API_KEY in ChatViewModel.swift (line 13)
         */
        const val DEFAULT_API_KEY = "changeMe"

        /**
         * App configuration constants
         */
        const val SHARED_PREFS_NAME = "XRAiAssistant_Preferences"
        const val PREF_KEY_API_KEY_PREFIX = "XRAiAssistant_APIKey_"
        const val PREF_KEY_SYSTEM_PROMPT = "XRAiAssistant_SystemPrompt"
        const val PREF_KEY_SELECTED_MODEL = "XRAiAssistant_SelectedModel"
        const val PREF_KEY_TEMPERATURE = "XRAiAssistant_Temperature"
        const val PREF_KEY_TOP_P = "XRAiAssistant_TopP"
        const val PREF_KEY_LIBRARY_ID = "XRAiAssistant_LibraryId"
        const val PREF_KEY_USE_SANDPACK = "XRAiAssistant_UseSandpackForR3F"
    }
}
