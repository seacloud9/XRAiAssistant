package com.xraiassistant.data.remote

import com.xraiassistant.data.models.TogetherAIRequest
import okhttp3.ResponseBody
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.Header
import retrofit2.http.POST
import retrofit2.http.Streaming

/**
 * Together.ai API Service
 *
 * Endpoint: https://api.together.xyz
 * Documentation: https://docs.together.ai/reference/chat-completions
 */
interface TogetherAIService {

    /**
     * Chat completions with streaming support
     *
     * Example curl:
     * ```
     * curl -X POST "https://api.together.xyz/v1/chat/completions" \
     *   -H "Authorization: Bearer YOUR_API_KEY" \
     *   -H "Content-Type: application/json" \
     *   -d '{
     *     "model": "meta-llama/Llama-3.3-70B-Instruct-Turbo",
     *     "messages": [{"role": "user", "content": "Hello"}],
     *     "stream": true
     *   }'
     * ```
     */
    @POST("v1/chat/completions")
    @Streaming
    suspend fun chatCompletion(
        @Header("Authorization") authorization: String,
        @Body request: TogetherAIRequest
    ): Response<ResponseBody>
}
