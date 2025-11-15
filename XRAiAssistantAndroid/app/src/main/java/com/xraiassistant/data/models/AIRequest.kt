package com.xraiassistant.data.models

import com.squareup.moshi.Json
import com.squareup.moshi.JsonClass

/**
 * Common AI Request Models for all providers
 */

@JsonClass(generateAdapter = true)
data class APIChatMessage(
    @Json(name = "role") val role: String,
    @Json(name = "content") val content: String
)

@JsonClass(generateAdapter = true)
data class TogetherAIRequest(
    @Json(name = "model") val model: String,
    @Json(name = "messages") val messages: List<APIChatMessage>,
    @Json(name = "temperature") val temperature: Double = 0.7,
    @Json(name = "top_p") val topP: Double = 0.9,
    @Json(name = "stream") val stream: Boolean = true,
    @Json(name = "max_tokens") val maxTokens: Int? = null
)

@JsonClass(generateAdapter = true)
data class TogetherAIResponse(
    @Json(name = "id") val id: String,
    @Json(name = "choices") val choices: List<Choice>,
    @Json(name = "usage") val usage: Usage? = null
) {
    @JsonClass(generateAdapter = true)
    data class Choice(
        @Json(name = "message") val message: APIChatMessage? = null,
        @Json(name = "delta") val delta: Delta? = null,
        @Json(name = "finish_reason") val finishReason: String? = null
    )

    @JsonClass(generateAdapter = true)
    data class Delta(
        @Json(name = "role") val role: String? = null,
        @Json(name = "content") val content: String? = null
    )

    @JsonClass(generateAdapter = true)
    data class Usage(
        @Json(name = "prompt_tokens") val promptTokens: Int,
        @Json(name = "completion_tokens") val completionTokens: Int,
        @Json(name = "total_tokens") val totalTokens: Int
    )
}

@JsonClass(generateAdapter = true)
data class OpenAIRequest(
    @Json(name = "model") val model: String,
    @Json(name = "messages") val messages: List<APIChatMessage>,
    @Json(name = "temperature") val temperature: Double = 0.7,
    @Json(name = "top_p") val topP: Double = 0.9,
    @Json(name = "stream") val stream: Boolean = true,
    @Json(name = "max_tokens") val maxTokens: Int? = null
)

@JsonClass(generateAdapter = true)
data class OpenAIResponse(
    @Json(name = "id") val id: String,
    @Json(name = "choices") val choices: List<Choice>,
    @Json(name = "usage") val usage: Usage? = null
) {
    @JsonClass(generateAdapter = true)
    data class Choice(
        @Json(name = "message") val message: APIChatMessage? = null,
        @Json(name = "delta") val delta: Delta? = null,
        @Json(name = "finish_reason") val finishReason: String? = null
    )

    @JsonClass(generateAdapter = true)
    data class Delta(
        @Json(name = "role") val role: String? = null,
        @Json(name = "content") val content: String? = null
    )

    @JsonClass(generateAdapter = true)
    data class Usage(
        @Json(name = "prompt_tokens") val promptTokens: Int,
        @Json(name = "completion_tokens") val completionTokens: Int,
        @Json(name = "total_tokens") val totalTokens: Int
    )
}

@JsonClass(generateAdapter = true)
data class AnthropicRequest(
    @Json(name = "model") val model: String,
    @Json(name = "messages") val messages: List<APIChatMessage>,
    @Json(name = "temperature") val temperature: Double = 0.7,
    @Json(name = "top_p") val topP: Double? = null,  // NULLABLE: Claude 4.5+ doesn't allow both temperature and top_p
    @Json(name = "stream") val stream: Boolean = true,
    @Json(name = "max_tokens") val maxTokens: Int = 4096,
    @Json(name = "system") val system: String? = null,
    @Json(name = "thinking") val thinking: ThinkingConfig? = null  // Extended Thinking (Claude 4.5+)
) {
    /**
     * Extended Thinking configuration for Claude Sonnet 4.5+
     *
     * Enables Claude to show its reasoning process before responding.
     * Useful for complex coding, math, and logical reasoning tasks.
     *
     * Example:
     * ```
     * thinking = ThinkingConfig(
     *     type = "enabled",
     *     budgetTokens = 5000
     * )
     * ```
     *
     * IMPORTANT: Claude 4.5+ models only accept temperature OR top_p, not both.
     * Always set topP = null when using Anthropic API.
     */
    @JsonClass(generateAdapter = true)
    data class ThinkingConfig(
        @Json(name = "type") val type: String = "enabled",
        @Json(name = "budget_tokens") val budgetTokens: Int? = null  // Optional: max thinking tokens
    )
}

@JsonClass(generateAdapter = true)
data class AnthropicResponse(
    @Json(name = "id") val id: String? = null,  // NULLABLE: not all streaming events have id
    @Json(name = "type") val type: String,
    @Json(name = "content") val content: List<ContentBlock>? = null,
    @Json(name = "delta") val delta: Delta? = null,
    @Json(name = "usage") val usage: Usage? = null
) {
    @JsonClass(generateAdapter = true)
    data class ContentBlock(
        @Json(name = "type") val type: String,
        @Json(name = "text") val text: String? = null
    )

    @JsonClass(generateAdapter = true)
    data class Delta(
        @Json(name = "type") val type: String,
        @Json(name = "text") val text: String? = null
    )

    @JsonClass(generateAdapter = true)
    data class Usage(
        @Json(name = "input_tokens") val inputTokens: Int,
        @Json(name = "output_tokens") val outputTokens: Int
    )
}
