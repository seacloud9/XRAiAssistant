package com.xraiassistant.data.local.entities

import androidx.room.Entity
import androidx.room.PrimaryKey

/**
 * Room entity for storing conversation metadata
 *
 * Stores conversation-level information like title, library used, and timestamps
 */
@Entity(tableName = "conversations")
data class ConversationEntity(
    @PrimaryKey
    val id: String,
    val title: String,
    val library3DID: String?,
    val modelUsed: String?,
    val createdAt: Long,
    val updatedAt: Long
)
