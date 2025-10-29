package com.xrai.assistant.domain.model

/**
 * Available AI models organized by provider
 *
 * iOS equivalent: availableModels and allAvailableModels in ChatViewModel.swift (line 87-104)
 */
object AIModels {
    /**
     * Together.ai models (free and paid)
     */
    val togetherAIModels = listOf(
        AIModel(
            id = "deepseek-ai/DeepSeek-R1-Distill-Llama-70B-free",
            displayName = "DeepSeek R1 70B",
            description = "Advanced reasoning & coding",
            pricing = "FREE",
            provider = "Together.ai",
            isDefault = true
        ),
        AIModel(
            id = "meta-llama/Llama-3.3-70B-Instruct-Turbo-Free",
            displayName = "Llama 3.3 70B",
            description = "Latest large model",
            pricing = "FREE",
            provider = "Together.ai"
        ),
        AIModel(
            id = "meta-llama/Meta-Llama-3-8B-Instruct-Lite",
            displayName = "Llama 3 8B Lite",
            description = "Cost-effective option",
            pricing = "$0.10/1M",
            provider = "Together.ai"
        ),
        AIModel(
            id = "meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo",
            displayName = "Llama 3.1 8B Turbo",
            description = "Good balance",
            pricing = "$0.18/1M",
            provider = "Together.ai"
        ),
        AIModel(
            id = "Qwen/Qwen2.5-7B-Instruct-Turbo",
            displayName = "Qwen 2.5 7B Turbo",
            description = "Fast coding specialist",
            pricing = "$0.30/1M",
            provider = "Together.ai"
        ),
        AIModel(
            id = "Qwen/Qwen2.5-Coder-32B-Instruct",
            displayName = "Qwen 2.5 Coder 32B",
            description = "Advanced coding & XR",
            pricing = "$0.80/1M",
            provider = "Together.ai"
        )
    )

    /**
     * OpenAI models
     */
    val openAIModels = listOf(
        AIModel(
            id = "gpt-4o",
            displayName = "GPT-4o",
            description = "Most capable multimodal model",
            pricing = "$2.50/$10.00 per 1M tokens",
            provider = "OpenAI",
            isDefault = true
        ),
        AIModel(
            id = "gpt-4o-mini",
            displayName = "GPT-4o Mini",
            description = "Affordable and intelligent small model",
            pricing = "$0.15/$0.60 per 1M tokens",
            provider = "OpenAI"
        ),
        AIModel(
            id = "gpt-4-turbo",
            displayName = "GPT-4 Turbo",
            description = "Latest GPT-4 Turbo with vision",
            pricing = "$10.00/$30.00 per 1M tokens",
            provider = "OpenAI"
        )
    )

    /**
     * Anthropic Claude models
     */
    val anthropicModels = listOf(
        AIModel(
            id = "claude-3-5-sonnet-20241022",
            displayName = "Claude 3.5 Sonnet",
            description = "Most intelligent model",
            pricing = "$3.00/$15.00 per 1M tokens",
            provider = "Anthropic",
            isDefault = true
        ),
        AIModel(
            id = "claude-3-5-haiku-20241022",
            displayName = "Claude 3.5 Haiku",
            description = "Fastest model",
            pricing = "$0.80/$4.00 per 1M tokens",
            provider = "Anthropic"
        ),
        AIModel(
            id = "claude-3-opus-20240229",
            displayName = "Claude 3 Opus",
            description = "Most powerful model",
            pricing = "$15.00/$75.00 per 1M tokens",
            provider = "Anthropic"
        )
    )

    /**
     * All available models across all providers
     */
    val allModels = togetherAIModels + openAIModels + anthropicModels

    /**
     * Get models organized by provider
     */
    val modelsByProvider = mapOf(
        "Together.ai" to togetherAIModels,
        "OpenAI" to openAIModels,
        "Anthropic" to anthropicModels
    )

    /**
     * Get model by ID
     */
    fun getModel(id: String): AIModel? = allModels.find { it.id == id }

    /**
     * Get default model for a provider
     */
    fun getDefaultModel(provider: String): AIModel? =
        modelsByProvider[provider]?.find { it.isDefault }
}

/**
 * AI parameter presets
 *
 * iOS equivalent: getParameterDescription() in ChatViewModel.swift (line 516)
 */
enum class AIParameterPreset(
    val temperature: Double,
    val topP: Double,
    val displayName: String,
    val description: String
) {
    PRECISE(
        temperature = 0.2,
        topP = 0.3,
        displayName = "Precise & Focused",
        description = "Perfect for debugging"
    ),
    BALANCED(
        temperature = 0.7,
        topP = 0.9,
        displayName = "Balanced Creativity",
        description = "Ideal for most scenes"
    ),
    CREATIVE(
        temperature = 1.2,
        topP = 0.9,
        displayName = "Experimental Mode",
        description = "Maximum innovation"
    ),
    TEACHING(
        temperature = 0.7,
        topP = 0.8,
        displayName = "Teaching Mode",
        description = "Educational explanations"
    );

    companion object {
        /**
         * Get preset description based on current parameters
         */
        fun getDescription(temperature: Double, topP: Double): String {
            return when {
                temperature in 0.0..0.3 && topP in 0.1..0.5 -> PRECISE.description
                temperature in 0.4..0.8 && topP in 0.6..0.9 -> BALANCED.description
                temperature in 0.9..2.0 && topP in 0.9..1.0 -> CREATIVE.description
                else -> "Custom Configuration"
            }
        }
    }
}
