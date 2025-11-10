package com.xraiassistant.data.models

import java.util.Date
import java.util.UUID

/**
 * Chat message data model
 * Equivalent to ChatMessage in iOS ChatViewModel.swift
 */
data class ChatMessage(
    val id: String = UUID.randomUUID().toString(),
    val content: String,
    val isUser: Boolean,
    val timestamp: Date = Date(),
    val model: String? = null,
    val libraryId: String? = null,  // Track which 3D library this message is for
    val isWelcomeMessage: Boolean = false  // NEW: Mark as welcome message to show "Run Demo" button
) {
    companion object {
        fun userMessage(content: String): ChatMessage {
            return ChatMessage(
                content = content,
                isUser = true
            )
        }
        
        fun aiMessage(content: String, model: String? = null, libraryId: String? = null): ChatMessage {
            return ChatMessage(
                content = content,
                isUser = false,
                model = model,
                libraryId = libraryId
            )
        }
    }
}