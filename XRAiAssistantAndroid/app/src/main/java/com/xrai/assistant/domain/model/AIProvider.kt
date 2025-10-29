package com.xrai.assistant.domain.model

import kotlinx.coroutines.flow.Flow

/**
 * AI Provider interface defining the contract for LLM services
 *
 * iOS equivalent: AIProvider protocol in AIProvider.swift (line 5)
 *
 * Implementations: Together.ai, OpenAI, Anthropic
 */
interface AIProvider {
    val name: String
    val models: List<AIModel>
    val requiresAPIKey: Boolean

    /**
     * Configure the provider with an API key
     */
    fun configure(apiKey: String)

    /**
     * Generate a streaming response from the AI
     *
     * @param messages Conversation history
     * @param model Model ID to use
     * @param temperature Controls randomness (0.0-2.0)
     * @param topP Controls nucleus sampling (0.1-1.0)
     * @return Flow emitting response chunks
     */
    suspend fun generateResponse(
        messages: List<AIMessage>,
        model: String,
        temperature: Double,
        topP: Double
    ): Flow<String>
}

/**
 * AI Model metadata
 *
 * iOS equivalent: AIModel struct in AIProvider.swift (line 21)
 */
data class AIModel(
    val id: String,
    val displayName: String,
    val description: String,
    val pricing: String = "",
    val provider: String,
    val isDefault: Boolean = false
)

/**
 * Message in an AI conversation
 *
 * iOS equivalent: AIMessage struct in AIProvider.swift (line 39)
 */
data class AIMessage(
    val content: String,
    val role: AIMessageRole
)

/**
 * Role of a message in conversation
 *
 * iOS equivalent: AIMessageRole enum in AIProvider.swift (line 44)
 */
enum class AIMessageRole {
    SYSTEM,
    USER,
    ASSISTANT
}

/**
 * Provider configuration settings
 *
 * iOS equivalent: ProviderConfiguration struct in AIProvider.swift (line 52)
 */
data class ProviderConfiguration(
    val apiKey: String,
    val baseURL: String? = null,
    val defaultModel: String,
    val supportedParameters: Set<AIParameter>
)

/**
 * AI parameters that can be configured
 *
 * iOS equivalent: AIParameter enum in AIProvider.swift (line 59)
 */
enum class AIParameter {
    TEMPERATURE,
    TOP_P,
    MAX_TOKENS,
    STREAM
}

/**
 * AI provider errors
 *
 * iOS equivalent: AIProviderError enum in AIProvider.swift (line 68)
 */
sealed class AIProviderError : Exception() {
    data object InvalidAPIKey : AIProviderError() {
        override val message: String = "Invalid API key provided"
    }

    data object ModelNotSupported : AIProviderError() {
        override val message: String = "Model not supported by this provider"
    }

    data object RateLimitExceeded : AIProviderError() {
        override val message: String = "Rate limit exceeded"
    }

    data class NetworkError(override val message: String) : AIProviderError()

    data object ResponseEmpty : AIProviderError() {
        override val message: String = "Empty response received"
    }

    data class ConfigurationError(override val message: String) : AIProviderError()
}

/**
 * Constants for AI configuration
 *
 * iOS equivalent: Constants in ChatViewModel.swift (line 13)
 */
object AIConstants {
    const val DEFAULT_API_KEY = "changeMe"
    const val DEFAULT_TEMPERATURE = 0.7
    const val DEFAULT_TOP_P = 0.9
    const val MAX_RETRY_ATTEMPTS = 1
    const val MINIMUM_RESPONSE_LENGTH = 50
}
