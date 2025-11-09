package com.xraiassistant.data.remote

import android.util.Log
import com.squareup.moshi.Moshi
import com.xraiassistant.data.models.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.withContext
import okhttp3.ResponseBody
import retrofit2.Response
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Real AI Provider Service
 *
 * Implements actual HTTP calls to Together.ai, OpenAI, and Anthropic APIs
 * with streaming support for real-time responses.
 *
 * Replaces the stub implementation.
 */
@Singleton
class RealAIProviderService @Inject constructor(
    private val togetherAIService: TogetherAIService,
    private val openAIService: OpenAIService,
    private val anthropicService: AnthropicService,
    private val moshi: Moshi
) {

    companion object {
        private const val TAG = "RealAIProviderService"
    }

    /**
     * Generate AI response with streaming
     *
     * Routes to appropriate provider based on provider name:
     * - "Together.ai" → Together.ai API
     * - "OpenAI" → OpenAI API
     * - "Anthropic" → Anthropic API
     *
     * @return Flow<String> emitting response chunks in real-time
     */
    suspend fun generateResponseStream(
        provider: String,
        apiKey: String,
        model: String,
        prompt: String,
        systemPrompt: String,
        temperature: Double,
        topP: Double
    ): Flow<String> = flow {
        Log.d(TAG, "🚀 Generating streaming response")
        Log.d(TAG, "Provider: $provider")
        Log.d(TAG, "Model: $model")
        Log.d(TAG, "Temperature: $temperature, Top-P: $topP")

        when (provider) {
            "Together.ai" -> {
                streamTogetherAI(apiKey, model, prompt, systemPrompt, temperature, topP)
                    .collect { chunk -> emit(chunk) }
            }
            "OpenAI" -> {
                streamOpenAI(apiKey, model, prompt, systemPrompt, temperature, topP)
                    .collect { chunk -> emit(chunk) }
            }
            "Anthropic" -> {
                streamAnthropic(apiKey, model, prompt, systemPrompt, temperature, topP)
                    .collect { chunk -> emit(chunk) }
            }
            else -> {
                Log.e(TAG, "❌ Unknown provider: $provider")
                throw IllegalArgumentException("Unknown provider: $provider")
            }
        }
    }.flowOn(Dispatchers.IO)

    /**
     * Stream response from Together.ai
     */
    private suspend fun streamTogetherAI(
        apiKey: String,
        model: String,
        prompt: String,
        systemPrompt: String,
        temperature: Double,
        topP: Double
    ): Flow<String> = flow {
        Log.d(TAG, "📡 Calling Together.ai API...")

        val messages = buildList {
            if (systemPrompt.isNotEmpty()) {
                add(APIChatMessage(role = "system", content = systemPrompt))
            }
            add(APIChatMessage(role = "user", content = prompt))
        }

        val request = TogetherAIRequest(
            model = model,
            messages = messages,
            temperature = temperature,
            topP = topP,
            stream = true,
            maxTokens = 4096
        )

        val response = togetherAIService.chatCompletion(
            authorization = "Bearer $apiKey",
            request = request
        )

        if (!response.isSuccessful) {
            val errorBody = response.errorBody()?.string()
            Log.e(TAG, "❌ Together.ai API error: ${response.code()} - $errorBody")
            throw Exception("Together.ai API error: ${response.code()} - $errorBody")
        }

        Log.d(TAG, "✅ Together.ai API response received, streaming chunks...")
        parseServerSentEvents(response.body()!!).collect { chunk ->
            emit(chunk)
        }
    }.flowOn(Dispatchers.IO)

    /**
     * Stream response from OpenAI
     */
    private suspend fun streamOpenAI(
        apiKey: String,
        model: String,
        prompt: String,
        systemPrompt: String,
        temperature: Double,
        topP: Double
    ): Flow<String> = flow {
        Log.d(TAG, "📡 Calling OpenAI API...")

        val messages = buildList {
            if (systemPrompt.isNotEmpty()) {
                add(APIChatMessage(role = "system", content = systemPrompt))
            }
            add(APIChatMessage(role = "user", content = prompt))
        }

        val request = OpenAIRequest(
            model = model,
            messages = messages,
            temperature = temperature,
            topP = topP,
            stream = true,
            maxTokens = 4096
        )

        val response = openAIService.chatCompletion(
            authorization = "Bearer $apiKey",
            request = request
        )

        if (!response.isSuccessful) {
            val errorBody = response.errorBody()?.string()
            Log.e(TAG, "❌ OpenAI API error: ${response.code()} - $errorBody")
            throw Exception("OpenAI API error: ${response.code()} - $errorBody")
        }

        Log.d(TAG, "✅ OpenAI API response received, streaming chunks...")
        parseServerSentEvents(response.body()!!).collect { chunk ->
            emit(chunk)
        }
    }.flowOn(Dispatchers.IO)

    /**
     * Stream response from Anthropic
     */
    private suspend fun streamAnthropic(
        apiKey: String,
        model: String,
        prompt: String,
        systemPrompt: String,
        temperature: Double,
        topP: Double
    ): Flow<String> = flow {
        Log.d(TAG, "📡 Calling Anthropic API...")

        val messages = listOf(
            APIChatMessage(role = "user", content = prompt)
        )

        val request = AnthropicRequest(
            model = model,
            messages = messages,
            temperature = temperature,
            topP = topP,
            stream = true,
            maxTokens = 4096,
            system = systemPrompt.takeIf { it.isNotEmpty() }
        )

        val response = anthropicService.messages(
            apiKey = apiKey,
            request = request
        )

        if (!response.isSuccessful) {
            val errorBody = response.errorBody()?.string()
            Log.e(TAG, "❌ Anthropic API error: ${response.code()} - $errorBody")
            throw Exception("Anthropic API error: ${response.code()} - $errorBody")
        }

        Log.d(TAG, "✅ Anthropic API response received, streaming chunks...")
        parseAnthropicServerSentEvents(response.body()!!).collect { chunk ->
            emit(chunk)
        }
    }.flowOn(Dispatchers.IO)

    /**
     * Parse Server-Sent Events (SSE) from Together.ai and OpenAI
     *
     * Format:
     * ```
     * data: {"choices":[{"delta":{"content":"Hello"}}]}
     * data: {"choices":[{"delta":{"content":" world"}}]}
     * data: [DONE]
     * ```
     */
    private suspend fun parseServerSentEvents(responseBody: ResponseBody): Flow<String> = flow {
        val source = responseBody.source()
        val adapter = moshi.adapter(TogetherAIResponse::class.java)

        try {
            while (!source.exhausted()) {
                val line = source.readUtf8Line() ?: break

                // SSE format: "data: {json}" or "data: [DONE]"
                if (line.startsWith("data: ")) {
                    val jsonData = line.substring(6).trim()

                    // Check for end marker
                    if (jsonData == "[DONE]") {
                        Log.d(TAG, "🏁 Stream complete")
                        break
                    }

                    // Parse JSON chunk - skip errors but keep emitting
                    val chunk = try {
                        adapter.fromJson(jsonData)
                    } catch (e: Exception) {
                        Log.w(TAG, "⚠️ Failed to parse chunk: $jsonData", e)
                        null
                    }

                    val content = chunk?.choices?.firstOrNull()?.delta?.content
                    if (!content.isNullOrEmpty()) {
                        emit(content)
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error reading stream", e)
            throw e
        } finally {
            responseBody.close()
        }
    }.flowOn(Dispatchers.IO)

    /**
     * Parse Server-Sent Events from Anthropic
     *
     * Anthropic uses slightly different format:
     * ```
     * data: {"type":"content_block_start",...}
     * data: {"type":"content_block_delta","delta":{"type":"text_delta","text":"Hello"}}
     * data: {"type":"content_block_delta","delta":{"type":"text_delta","text":" world"}}
     * data: {"type":"message_stop"}
     * ```
     */
    private suspend fun parseAnthropicServerSentEvents(responseBody: ResponseBody): Flow<String> = flow {
        val source = responseBody.source()
        val adapter = moshi.adapter(AnthropicResponse::class.java)

        try {
            while (!source.exhausted()) {
                val line = source.readUtf8Line() ?: break

                if (line.startsWith("data: ")) {
                    val jsonData = line.substring(6).trim()

                    // Parse JSON chunk - skip errors but keep emitting
                    val chunk = try {
                        adapter.fromJson(jsonData)
                    } catch (e: Exception) {
                        Log.w(TAG, "⚠️ Failed to parse Anthropic chunk: $jsonData", e)
                        null
                    }

                    // Check for text delta
                    if (chunk?.type == "content_block_delta") {
                        val text = chunk.delta?.text
                        if (!text.isNullOrEmpty()) {
                            emit(text)
                        }
                    }

                    // Check for completion
                    if (chunk?.type == "message_stop") {
                        Log.d(TAG, "🏁 Anthropic stream complete")
                        break
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error reading Anthropic stream", e)
            throw e
        } finally {
            responseBody.close()
        }
    }.flowOn(Dispatchers.IO)

    /**
     * Non-streaming version (collects all chunks into a single string)
     *
     * This is the interface used by the existing AIProviderService.kt stub.
     * We implement it by collecting the streaming response.
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
        val fullResponse = StringBuilder()

        generateResponseStream(
            provider, apiKey, model, prompt, systemPrompt, temperature, topP
        ).collect { chunk ->
            fullResponse.append(chunk)
        }

        return fullResponse.toString()
    }
}
