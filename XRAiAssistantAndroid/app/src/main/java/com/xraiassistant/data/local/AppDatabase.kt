package com.xraiassistant.data.local

import androidx.room.Database
import androidx.room.RoomDatabase
import com.xraiassistant.data.local.dao.ConversationDao
import com.xraiassistant.data.local.entities.ConversationEntity
import com.xraiassistant.data.local.entities.MessageEntity

/**
 * Room Database for XRAiAssistant
 *
 * Stores chat conversations and messages with full history support
 *
 * @version 1 - Initial database schema
 */
@Database(
    entities = [
        ConversationEntity::class,
        MessageEntity::class
    ],
    version = 1,
    exportSchema = false // Set to false for development - enable with schemaLocation in production
)
abstract class AppDatabase : RoomDatabase() {

    /**
     * Provides access to conversation and message operations
     */
    abstract fun conversationDao(): ConversationDao

    companion object {
        const val DATABASE_NAME = "xraiassistant_db"
    }
}
