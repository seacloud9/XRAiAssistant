package com.xrai.assistant.presentation.theme

import androidx.compose.ui.graphics.Color

/**
 * Color definitions for XRAiAssistant
 *
 * iOS equivalent: Uses system colors from SwiftUI (Color.blue, Color.green, etc.)
 *
 * Defines Material 3 color scheme for both light and dark themes
 */

// Primary colors - Blue theme (matches iOS accent colors)
val BluePrimary = Color(0xFF0066CC)
val BlueSecondary = Color(0xFF007AFF)  // iOS system blue
val BlueTertiary = Color(0xFF34C759)   // iOS system green

// Light theme colors
val LightPrimary = BluePrimary
val LightOnPrimary = Color.White
val LightPrimaryContainer = Color(0xFFD6E3FF)
val LightOnPrimaryContainer = Color(0xFF001C3B)

val LightSecondary = Color(0xFF535E6E)
val LightOnSecondary = Color.White
val LightSecondaryContainer = Color(0xFFD8E2F5)
val LightOnSecondaryContainer = Color(0xFF101C28)

val LightTertiary = Color(0xFF6A5778)
val LightOnTertiary = Color.White
val LightTertiaryContainer = Color(0xFFF2DAFF)
val LightOnTertiaryContainer = Color(0xFF251431)

val LightError = Color(0xFFBA1A1A)
val LightErrorContainer = Color(0xFFFFDAD6)
val LightOnError = Color.White
val LightOnErrorContainer = Color(0xFF410002)

val LightBackground = Color(0xFFFDFBFF)
val LightOnBackground = Color(0xFF1A1C1E)
val LightSurface = Color(0xFFFDFBFF)
val LightOnSurface = Color(0xFF1A1C1E)
val LightSurfaceVariant = Color(0xFFE0E2EC)
val LightOnSurfaceVariant = Color(0xFF44464F)

val LightOutline = Color(0xFF74777F)
val LightOutlineVariant = Color(0xFFC4C6D0)

// Dark theme colors
val DarkPrimary = Color(0xFFAAC7FF)
val DarkOnPrimary = Color(0xFF00315F)
val DarkPrimaryContainer = Color(0xFF004787)
val DarkOnPrimaryContainer = Color(0xFFD6E3FF)

val DarkSecondary = Color(0xFFBCC7D9)
val DarkOnSecondary = Color(0xFF26313E)
val DarkSecondaryContainer = Color(0xFF3C4755)
val DarkOnSecondaryContainer = Color(0xFFD8E2F5)

val DarkTertiary = Color(0xFFD6BEE4)
val DarkOnTertiary = Color(0xFF3B2947)
val DarkTertiaryContainer = Color(0xFF523F5F)
val DarkOnTertiaryContainer = Color(0xFFF2DAFF)

val DarkError = Color(0xFFFFB4AB)
val DarkErrorContainer = Color(0xFF93000A)
val DarkOnError = Color(0xFF690005)
val DarkOnErrorContainer = Color(0xFFFFDAD6)

val DarkBackground = Color(0xFF1A1C1E)
val DarkOnBackground = Color(0xFFE3E2E6)
val DarkSurface = Color(0xFF1A1C1E)
val DarkOnSurface = Color(0xFFE3E2E6)
val DarkSurfaceVariant = Color(0xFF44464F)
val DarkOnSurfaceVariant = Color(0xFFC4C6D0)

val DarkOutline = Color(0xFF8E9099)
val DarkOutlineVariant = Color(0xFF44464F)

// Semantic colors for specific UI elements
val Success = Color(0xFF34C759)      // iOS system green
val Warning = Color(0xFFFF9500)      // iOS system orange
val Info = Color(0xFF007AFF)         // iOS system blue
val CodeBackground = Color(0xFFF5F5F5)
val CodeBackgroundDark = Color(0xFF2D2D2D)

// Chat message colors
val UserMessageBackground = BluePrimary
val UserMessageText = Color.White
val AssistantMessageBackground = Color(0xFFF0F0F0)
val AssistantMessageBackgroundDark = Color(0xFF2D2D2D)
val AssistantMessageText = Color(0xFF1A1C1E)
val AssistantMessageTextDark = Color(0xFFE3E2E6)
