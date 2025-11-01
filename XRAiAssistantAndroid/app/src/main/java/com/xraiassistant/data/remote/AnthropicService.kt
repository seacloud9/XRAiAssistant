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
 * Documentation: https://docs.anthropic.com/en/api/messages
 */
interface AnthropicService {

    /**
     * Messages API with streaming support
     *
     * Example curl:
     * ```
     * curl -X POST "https://api.anthropic.com/v1/messages" \
     *   -H "x-api-key: YOUR_API_KEY" \
     *   -H "anthropic-version: 2023-06-01" \
     *   -H "Content-Type: application/json" \
     *   -d '{
     *     "model": "claude-3-5-sonnet-20241022",
     *     "messages": [{"role": "user", "content": "Hello"}],
     *     "stream": true,
     *     "max_tokens": 4096
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
