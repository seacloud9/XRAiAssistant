package com.xrai.assistant.domain.model

import java.util.Date

/**
 * Domain model representing a chat message
 *
 * iOS equivalent: ChatMessage struct in ChatViewModel.swift (line 1384)
 *
 * @property id Unique identifier for the message
 * @property content The message text content
 * @property isUser Whether this is a user message (true) or AI message (false)
 * @property timestamp When the message was created
 * @property libraryId Optional ID of the 3D library active when message was created
 */
data class ChatMessage(
    val id: String,
    val content: String,
    val isUser: Boolean,
    val timestamp: Date = Date(),
    val libraryId: String? = null
) {
    companion object {
        /**
         * Create a user message
         */
        fun userMessage(
            content: String,
            libraryId: String? = null
        ): ChatMessage = ChatMessage(
            id = java.util.UUID.randomUUID().toString(),
            content = content,
            isUser = true,
            timestamp = Date(),
            libraryId = libraryId
        )

        /**
         * Create an AI assistant message
         */
        fun assistantMessage(
            content: String,
            libraryId: String? = null
        ): ChatMessage = ChatMessage(
            id = java.util.UUID.randomUUID().toString(),
            content = content,
            isUser = false,
            timestamp = Date(),
            libraryId = libraryId
        )
    }
}

/**
 * Chat-related errors
 *
 * iOS equivalent: ChatError enum in ChatViewModel.swift (line 1392)
 */
sealed class ChatError : Exception() {
    data object SessionCreationFailed : ChatError() {
        override val message: String = "Failed to create agent session"
    }

    data object InvalidResponse : ChatError() {
        override val message: String = "Invalid response from server"
    }

    data class NetworkError(override val message: String) : ChatError()
}
