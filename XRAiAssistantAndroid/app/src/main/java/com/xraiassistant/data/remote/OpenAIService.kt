package com.xraiassistant.data.remote

import com.xraiassistant.data.models.OpenAIRequest
import okhttp3.ResponseBody
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.Header
import retrofit2.http.POST
import retrofit2.http.Streaming

/**
 * OpenAI API Service
 *
 * Endpoint: https://api.openai.com
 * Documentation: https://platform.openai.com/docs/api-reference/chat
 */
interface OpenAIService {

    /**
     * Chat completions with streaming support
     *
     * Example curl:
     * ```
     * curl -X POST "https://api.openai.com/v1/chat/completions" \
     *   -H "Authorization: Bearer YOUR_API_KEY" \
     *   -H "Content-Type: application/json" \
     *   -d '{
     *     "model": "gpt-4o",
     *     "messages": [{"role": "user", "content": "Hello"}],
     *     "stream": true
     *   }'
     * ```
     */
    @POST("v1/chat/completions")
    @Streaming
    suspend fun chatCompletion(
        @Header("Authorization") authorization: String,
        @Body request: OpenAIRequest
    ): Response<ResponseBody>
}
