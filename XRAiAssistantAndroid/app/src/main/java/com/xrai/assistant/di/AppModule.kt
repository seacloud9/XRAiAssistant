package com.xrai.assistant.di

import android.content.Context
import android.content.SharedPreferences
import com.xrai.assistant.XRAiApplication
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

/**
 * Dependency injection module for XRAiAssistant
 *
 * iOS equivalent: No direct equivalent (iOS uses property injection and init)
 *
 * Provides:
 * - SharedPreferences for settings persistence
 * - AI provider instances
 * - Library3D manager
 * - Repository instances
 */
@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    /**
     * Provide SharedPreferences for settings persistence
     *
     * iOS equivalent: UserDefaults in ChatViewModel.swift (line 1169-1266)
     */
    @Provides
    @Singleton
    fun provideSharedPreferences(
        @ApplicationContext context: Context
    ): SharedPreferences {
        return context.getSharedPreferences(
            XRAiApplication.SHARED_PREFS_NAME,
            Context.MODE_PRIVATE
        )
    }

    /**
     * Provide application context
     */
    @Provides
    @Singleton
    fun provideApplicationContext(
        @ApplicationContext context: Context
    ): Context = context

    // TODO: Add providers for:
    // - AIProviderManager
    // - Library3DManager
    // - ConversationRepository
    // - CodeSandboxAPIClient
    // - WebViewManager
}
