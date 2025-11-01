package com.xraiassistant.data.remote

import kotlinx.coroutines.flow.Flow
import javax.inject.Inject
import javax.inject.Singleton

/**
 * AI Provider Service
 *
 * Facade/wrapper for RealAIProviderService that maintains backward compatibility
 * with the existing interface while providing real HTTP calls to AI providers.
 *
 * ✅ UPDATED: Now uses real API calls instead of stub implementation
 */
@Singleton
class AIProviderService @Inject constructor(
    private val realAIProviderService: RealAIProviderService
) {

    /**
     * Generate AI response (non-streaming)
     *
     * Collects all streaming chunks into a single string.
     * For real-time updates, use generateResponseStream() instead.
     */
    suspend fun generateResponse(
        provider: String,
        apiKey: String,
        model: String,
        prompt: String,
        systemPrompt: String,
        temperature: Double,
        topP: Double
    ): String {
        return realAIProviderService.generateResponse(
            provider, apiKey, model, prompt, systemPrompt, temperature, topP
        )
    }

    /**
     * Generate AI response with streaming
     *
     * Returns a Flow that emits response chunks in real-time.
     * Use this for better UX with long responses.
     *
     * Example:
     * ```kotlin
     * service.generateResponseStream(...).collect { chunk ->
     *     // Update UI with each chunk
     *     println(chunk)
     * }
     * ```
     */
    suspend fun generateResponseStream(
        provider: String,
        apiKey: String,
        model: String,
        prompt: String,
        systemPrompt: String,
        temperature: Double,
        topP: Double
    ): Flow<String> {
        return realAIProviderService.generateResponseStream(
            provider, apiKey, model, prompt, systemPrompt, temperature, topP
        )
    }
}