package com.xraiassistant.data.models

/**
 * AI Model data classes
 * Equivalent to the model management system in iOS ChatViewModel.swift
 */
data class AIModel(
    val id: String,
    val displayName: String,
    val description: String,
    val provider: String,
    val pricing: String = "",
    val capabilities: Set<AICapability> = emptySet()
)

enum class AICapability {
    TEXT_GENERATION,
    CODE_GENERATION,
    STREAMING,
    FUNCTION_CALLING
}

/**
 * Predefined AI models matching iOS implementation
 */
object AIModels {
    val DEEPSEEK_R1_70B = AIModel(
        id = "deepseek-ai/DeepSeek-R1-Distill-Llama-70B-free",
        displayName = "DeepSeek R1 70B",
        description = "Advanced reasoning & coding",
        provider = "Together.ai",
        pricing = "FREE",
        capabilities = setOf(
            AICapability.TEXT_GENERATION,
            AICapability.CODE_GENERATION,
            AICapability.STREAMING
        )
    )
    
    val LLAMA_3_3_70B = AIModel(
        id = "meta-llama/Llama-3.3-70B-Instruct-Turbo",
        displayName = "Llama 3.3 70B",
        description = "Latest Meta large model",
        provider = "Together.ai",
        pricing = "FREE",
        capabilities = setOf(
            AICapability.TEXT_GENERATION,
            AICapability.CODE_GENERATION,
            AICapability.STREAMING
        )
    )
    
    val LLAMA_3_8B_LITE = AIModel(
        id = "meta-llama/Llama-3-8b-chat-hf",
        displayName = "Llama 3 8B Lite",
        description = "Cost-effective option",
        provider = "Together.ai",
        pricing = "$0.10/1M",
        capabilities = setOf(
            AICapability.TEXT_GENERATION,
            AICapability.CODE_GENERATION
        )
    )
    
    val QWEN_2_5_7B_TURBO = AIModel(
        id = "Qwen/Qwen2.5-7B-Instruct-Turbo",
        displayName = "Qwen 2.5 7B Turbo",
        description = "Fast coding specialist",
        provider = "Together.ai",
        pricing = "$0.30/1M",
        capabilities = setOf(
            AICapability.TEXT_GENERATION,
            AICapability.CODE_GENERATION,
            AICapability.STREAMING
        )
    )
    
    val QWEN_2_5_CODER_32B = AIModel(
        id = "Qwen/Qwen2.5-Coder-32B-Instruct",
        displayName = "Qwen 2.5 Coder 32B",
        description = "Advanced coding & XR",
        provider = "Together.ai",
        pricing = "$0.80/1M",
        capabilities = setOf(
            AICapability.TEXT_GENERATION,
            AICapability.CODE_GENERATION,
            AICapability.STREAMING
        )
    )
    
    val GPT_4O = AIModel(
        id = "gpt-4o",
        displayName = "GPT-4o",
        description = "OpenAI's latest model",
        provider = "OpenAI",
        pricing = "$5.00/1M",
        capabilities = setOf(
            AICapability.TEXT_GENERATION,
            AICapability.CODE_GENERATION,
            AICapability.STREAMING,
            AICapability.FUNCTION_CALLING
        )
    )
    
    val CLAUDE_3_5_SONNET = AIModel(
        id = "claude-3-5-sonnet-20241022",
        displayName = "Claude 3.5 Sonnet",
        description = "Anthropic's advanced model",
        provider = "Anthropic",
        pricing = "$3.00/1M",
        capabilities = setOf(
            AICapability.TEXT_GENERATION,
            AICapability.CODE_GENERATION,
            AICapability.STREAMING
        )
    )
    
    val ALL_MODELS = listOf(
        DEEPSEEK_R1_70B,
        LLAMA_3_3_70B,
        LLAMA_3_8B_LITE,
        QWEN_2_5_7B_TURBO,
        QWEN_2_5_CODER_32B,
        GPT_4O,
        CLAUDE_3_5_SONNET
    )
    
    val MODELS_BY_PROVIDER = ALL_MODELS.groupBy { it.provider }
}