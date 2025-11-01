package com.xraiassistant.di

import android.content.Context
import com.xraiassistant.data.local.SettingsDataStore
import com.xraiassistant.data.remote.AIProviderService
import com.xraiassistant.data.repositories.AIProviderRepository
import com.xraiassistant.data.repositories.Library3DRepository
import com.xraiassistant.data.repositories.SettingsRepository
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

/**
 * Hilt Dependency Injection Module
 * 
 * Provides all app-level dependencies
 */
@Module
@InstallIn(SingletonComponent::class)
object AppModule {
    
    @Provides
    @Singleton
    fun provideSettingsDataStore(
        @ApplicationContext context: Context
    ): SettingsDataStore {
        return SettingsDataStore(context)
    }

    // AIProviderService and RealAIProviderService are automatically provided by Hilt
    // via @Inject constructor and @Singleton annotation - no manual provider needed

    @Provides
    @Singleton
    fun provideLibrary3DRepository(): Library3DRepository {
        return Library3DRepository()
    }
    
    @Provides
    @Singleton
    fun provideSettingsRepository(
        settingsDataStore: SettingsDataStore
    ): SettingsRepository {
        return SettingsRepository(settingsDataStore)
    }
    
    @Provides
    @Singleton
    fun provideAIProviderRepository(
        aiProviderService: AIProviderService,
        settingsDataStore: SettingsDataStore
    ): AIProviderRepository {
        return AIProviderRepository(aiProviderService, settingsDataStore)
    }
}