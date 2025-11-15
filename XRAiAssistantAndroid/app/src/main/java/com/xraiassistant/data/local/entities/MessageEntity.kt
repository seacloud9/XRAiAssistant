package com.xraiassistant.data.local.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey

/**
 * Room entity for storing individual chat messages
 *
 * Foreign key relationship with ConversationEntity ensures data integrity
 */
@Entity(
    tableName = "messages",
    foreignKeys = [
        ForeignKey(
            entity = ConversationEntity::class,
            parentColumns = ["id"],
            childColumns = ["conversationId"],
            onDelete = ForeignKey.CASCADE // Delete messages when conversation is deleted
        )
    ],
    indices = [Index("conversationId")] // Index for faster queries
)
data class MessageEntity(
    @PrimaryKey
    val id: String,
    val conversationId: String,
    val content: String,
    val isUser: Boolean,
    val timestamp: Long,
    val model: String?,
    val libraryId: String?
)
