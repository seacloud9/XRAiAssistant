package com.xraiassistant.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.SmartToy
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.xraiassistant.data.models.ChatMessage
import java.text.SimpleDateFormat
import java.util.*

/**
 * Chat Message Card
 * 
 * Displays individual chat messages with different styling for user vs AI
 * Equivalent to ChatMessageView in iOS ContentView.swift
 */
@Composable
fun ChatMessageCard(
    message: ChatMessage,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier,
        horizontalArrangement = if (message.isUser) {
            Arrangement.End
        } else {
            Arrangement.Start
        }
    ) {
        if (message.isUser) {
            Spacer(modifier = Modifier.weight(0.2f))
        }
        
        Column(
            horizontalAlignment = if (message.isUser) {
                Alignment.End
            } else {
                Alignment.Start
            }
        ) {
            Box(
                modifier = Modifier
                    .clip(
                        RoundedCornerShape(
                            topStart = 16.dp,
                            topEnd = 16.dp,
                            bottomStart = if (message.isUser) 16.dp else 4.dp,
                            bottomEnd = if (message.isUser) 4.dp else 16.dp
                        )
                    )
                    .background(
                        if (message.isUser) {
                            MaterialTheme.colorScheme.primary
                        } else {
                            MaterialTheme.colorScheme.surfaceVariant
                        }
                    )
                    .padding(horizontal = 16.dp, vertical = 12.dp)
            ) {
                Column {
                    // Header with icon and sender info
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        Icon(
                            imageVector = if (message.isUser) Icons.Default.Person else Icons.Default.SmartToy,
                            contentDescription = if (message.isUser) "User" else "AI",
                            tint = if (message.isUser) {
                                MaterialTheme.colorScheme.onPrimary
                            } else {
                                Color(0xFF2196F3)
                            },
                            modifier = Modifier.size(14.dp)
                        )
                        Text(
                            text = if (message.isUser) "You" else (message.model ?: "AI Assistant"),
                            style = MaterialTheme.typography.labelSmall,
                            color = if (message.isUser) {
                                MaterialTheme.colorScheme.onPrimary
                            } else {
                                Color(0xFF2196F3)
                            },
                            fontWeight = FontWeight.SemiBold
                        )
                    }
                    
                    Spacer(modifier = Modifier.height(6.dp))
                    
                    // Message content
                    Text(
                        text = message.content,
                        color = if (message.isUser) {
                            MaterialTheme.colorScheme.onPrimary
                        } else {
                            MaterialTheme.colorScheme.onSurfaceVariant
                        },
                        style = MaterialTheme.typography.bodyMedium
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(4.dp))
            
            Text(
                text = formatTime(message.timestamp),
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.6f),
                fontWeight = FontWeight.Light
            )
        }
        
        if (!message.isUser) {
            Spacer(modifier = Modifier.weight(0.2f))
        }
    }
}

private fun formatTime(date: Date): String {
    val formatter = SimpleDateFormat("HH:mm", Locale.getDefault())
    return formatter.format(date)
}