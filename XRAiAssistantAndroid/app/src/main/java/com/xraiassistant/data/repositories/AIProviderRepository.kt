package com.xraiassistant.data.repositories

import com.xraiassistant.data.remote.AIProviderService
import com.xraiassistant.data.local.SettingsDataStore
import kotlinx.coroutines.flow.first
import javax.inject.Inject
import javax.inject.Singleton

/**
 * AI Provider Repository
 * 
 * Manages AI provider configurations and API calls
 * Equivalent to AIProviderManager + ChatViewModel AI logic in iOS
 */
@Singleton
class AIProviderRepository @Inject constructor(
    private val aiProviderService: AIProviderService,
    private val settingsDataStore: SettingsDataStore
) {
    
    companion object {
        private const val DEFAULT_API_KEY = "changeMe"
        private const val PROVIDER_TOGETHER_AI = "Together.ai"
        private const val PROVIDER_OPENAI = "OpenAI"
        private const val PROVIDER_ANTHROPIC = "Anthropic"
    }
    
    /**
     * Generate AI response using specified model and parameters (non-streaming)
     */
    suspend fun generateResponse(
        prompt: String,
        model: String,
        temperature: Double,
        topP: Double,
        systemPrompt: String
    ): String {
        val provider = getProviderForModel(model)
        val apiKey = getAPIKeyForProvider(provider)

        if (apiKey == DEFAULT_API_KEY) {
            throw IllegalStateException("API key not configured for $provider")
        }

        return aiProviderService.generateResponse(
            provider = provider,
            apiKey = apiKey,
            model = model,
            prompt = prompt,
            systemPrompt = systemPrompt,
            temperature = temperature,
            topP = topP
        )
    }

    /**
     * Generate AI response with streaming (NEW - iOS parity)
     *
     * Returns a Flow that emits response chunks in real-time.
     * Provides better UX for long responses.
     */
    suspend fun generateResponseStream(
        prompt: String,
        model: String,
        temperature: Double,
        topP: Double,
        systemPrompt: String
    ): kotlinx.coroutines.flow.Flow<String> {
        val provider = getProviderForModel(model)
        val apiKey = getAPIKeyForProvider(provider)

        if (apiKey == DEFAULT_API_KEY) {
            throw IllegalStateException("API key not configured for $provider")
        }

        return aiProviderService.generateResponseStream(
            provider = provider,
            apiKey = apiKey,
            model = model,
            prompt = prompt,
            systemPrompt = systemPrompt,
            temperature = temperature,
            topP = topP
        )
    }
    
    /**
     * Check if provider is configured with valid API key
     */
    fun isProviderConfigured(provider: String): Boolean {
        val apiKey = getAPIKeyForProvider(provider)
        return apiKey != DEFAULT_API_KEY && apiKey.isNotBlank()
    }
    
    /**
     * Set API key for provider
     */
    suspend fun setAPIKey(provider: String, key: String) {
        settingsDataStore.setAPIKey(provider, key)
    }
    
    /**
     * Get API key for provider (returns masked version for display)
     */
    fun getAPIKey(provider: String): String {
        val apiKey = getAPIKeyForProvider(provider)
        return if (apiKey == DEFAULT_API_KEY || apiKey.isBlank()) {
            DEFAULT_API_KEY
        } else {
            // Mask the key for display: "sk-...xyz123"
            if (apiKey.length > 8) {
                "${apiKey.take(3)}...${apiKey.takeLast(6)}"
            } else {
                "***"
            }
        }
    }

    /**
     * Get raw API key for provider (for editing in settings)
     * Returns the full, unmasked API key
     */
    fun getRawAPIKey(provider: String): String {
        return getAPIKeyForProvider(provider)
    }
    
    /**
     * Get raw API key for provider (for API calls)
     */
    private fun getAPIKeyForProvider(provider: String): String {
        return try {
            // This would normally be async, but for simplicity we'll use a blocking call
            // In production, you'd want to cache these values
            settingsDataStore.getAPIKeySync(provider)
        } catch (e: Exception) {
            DEFAULT_API_KEY
        }
    }
    
    /**
     * Determine provider from model ID
     */
    private fun getProviderForModel(model: String): String {
        return when {
            model.startsWith("gpt-") -> PROVIDER_OPENAI
            model.startsWith("claude-") -> PROVIDER_ANTHROPIC
            model.contains("deepseek") || 
            model.contains("llama") || 
            model.contains("qwen") -> PROVIDER_TOGETHER_AI
            else -> PROVIDER_TOGETHER_AI // Default to Together.ai
        }
    }
    
    /**
     * Get all supported providers
     */
    fun getSupportedProviders(): List<String> {
        return listOf(PROVIDER_TOGETHER_AI, PROVIDER_OPENAI, PROVIDER_ANTHROPIC)
    }
    
    /**
     * Validate API key format for provider
     */
    fun validateAPIKey(provider: String, key: String): Boolean {
        return when (provider) {
            PROVIDER_TOGETHER_AI -> key.isNotBlank() && key != DEFAULT_API_KEY
            PROVIDER_OPENAI -> key.startsWith("sk-") && key.length > 20
            PROVIDER_ANTHROPIC -> key.startsWith("sk-ant-") && key.length > 20
            else -> key.isNotBlank() && key != DEFAULT_API_KEY
        }
    }
}