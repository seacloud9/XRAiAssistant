package com.xraiassistant.data.local.dao

import androidx.room.*
import com.xraiassistant.data.local.entities.ConversationEntity
import com.xraiassistant.data.local.entities.MessageEntity
import kotlinx.coroutines.flow.Flow

/**
 * Room DAO for conversation and message database operations
 *
 * Provides CRUD operations for conversations and messages with reactive Flow support
 */
@Dao
interface ConversationDao {

    // MARK: - Conversation Operations

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertConversation(conversation: ConversationEntity)

    @Update
    suspend fun updateConversation(conversation: ConversationEntity)

    @Query("SELECT * FROM conversations ORDER BY updatedAt DESC")
    fun getAllConversations(): Flow<List<ConversationEntity>>

    @Query("SELECT * FROM conversations WHERE id = :conversationId")
    suspend fun getConversationById(conversationId: String): ConversationEntity?

    @Query("DELETE FROM conversations WHERE id = :conversationId")
    suspend fun deleteConversation(conversationId: String)

    @Query("DELETE FROM conversations")
    suspend fun deleteAllConversations()

    // MARK: - Message Operations

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertMessage(message: MessageEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertMessages(messages: List<MessageEntity>)

    @Query("SELECT * FROM messages WHERE conversationId = :conversationId ORDER BY timestamp ASC")
    suspend fun getMessagesForConversation(conversationId: String): List<MessageEntity>

    @Query("DELETE FROM messages WHERE conversationId = :conversationId")
    suspend fun deleteMessagesForConversation(conversationId: String)

    // MARK: - Complex Queries

    /**
     * Get conversation with all its messages
     * Returns pair of conversation and messages
     */
    @Transaction
    suspend fun getConversationWithMessages(conversationId: String): Pair<ConversationEntity?, List<MessageEntity>> {
        val conversation = getConversationById(conversationId)
        val messages = getMessagesForConversation(conversationId)
        return Pair(conversation, messages)
    }
}
