package com.xraiassistant

import android.app.Application
import com.xraiassistant.BuildConfig
import dagger.hilt.android.HiltAndroidApp
import android.util.Log

/**
 * XRAiAssistant Application
 * 
 * AI-powered Extended Reality development platform for Android
 * Ported from iOS Swift to Kotlin with Jetpack Compose
 */
@HiltAndroidApp
class XRAiAssistantApplication : Application() {
    
    override fun onCreate() {
        super.onCreate()
        
        Log.d("XRAiAssistant", "Application onCreate called")
        
        try {
            // Initialize WebView debugging in debug builds
            if (BuildConfig.DEBUG) {
                android.webkit.WebView.setWebContentsDebuggingEnabled(true)
                Log.d("XRAiAssistant", "WebView debugging enabled")
            }
            Log.d("XRAiAssistant", "Application onCreate completed successfully")
        } catch (e: Exception) {
            Log.e("XRAiAssistant", "Error in Application onCreate", e)
            throw e
        }
    }
}