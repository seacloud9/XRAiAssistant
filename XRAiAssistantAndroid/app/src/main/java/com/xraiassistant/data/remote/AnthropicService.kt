package com.xraiassistant.data.remote

import com.xraiassistant.data.models.AnthropicRequest
import okhttp3.ResponseBody
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.Header
import retrofit2.http.POST
import retrofit2.http.Streaming

/**
 * Anthropic API Service
 *
 * Endpoint: https://api.anthropic.com
 * Documentation: https://docs.claude.com/en/api/messages
 *
 * Supported Models (2025):
 * - Claude Sonnet 4.5 (claude-sonnet-4-5-20250929) - Latest, 200K context, extended thinking
 * - Claude Opus 4.1 (claude-opus-4-1-20250805) - Most powerful, complex reasoning
 * - Claude Haiku 4.5 (claude-haiku-4-5-20251001) - Fast & cost-effective
 */
interface AnthropicService {

    /**
     * Messages API with streaming support
     *
     * Supports Claude Sonnet 4.5, Opus 4.1, and Haiku 4.5 with extended thinking.
     *
     * Example curl (Basic):
     * ```
     * curl -X POST "https://api.anthropic.com/v1/messages" \
     *   -H "x-api-key: YOUR_API_KEY" \
     *   -H "anthropic-version: 2023-06-01" \
     *   -H "Content-Type: application/json" \
     *   -d '{
     *     "model": "claude-sonnet-4-5-20250929",
     *     "messages": [{"role": "user", "content": "Hello"}],
     *     "stream": true,
     *     "max_tokens": 4096
     *   }'
     * ```
     *
     * Example curl (With Extended Thinking):
     * ```
     * curl -X POST "https://api.anthropic.com/v1/messages" \
     *   -H "x-api-key: YOUR_API_KEY" \
     *   -H "anthropic-version: 2023-06-01" \
     *   -H "Content-Type: application/json" \
     *   -d '{
     *     "model": "claude-sonnet-4-5-20250929",
     *     "messages": [{"role": "user", "content": "Solve this complex problem..."}],
     *     "stream": true,
     *     "max_tokens": 16000,
     *     "thinking": {
     *       "type": "enabled",
     *       "budget_tokens": 10000
     *     }
     *   }'
     * ```
     */
    @POST("v1/messages")
    @Streaming
    suspend fun messages(
        @Header("x-api-key") apiKey: String,
        @Header("anthropic-version") version: String = "2023-06-01",
        @Body request: AnthropicRequest
    ): Response<ResponseBody>
}
