package com.xraiassistant

import android.app.Application
import dagger.hilt.android.HiltAndroidApp

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
        
        // Initialize WebView debugging in debug builds
        if (BuildConfig.DEBUG) {
            android.webkit.WebView.setWebContentsDebuggingEnabled(true)
        }
    }
}