package com.xrai.assistant.presentation.navigation

/**
 * Navigation destinations for XRAiAssistant
 *
 * iOS equivalent: AppView enum and tab bar navigation in ContentView.swift (line 6-8, 1068-1216)
 *
 * Defines all screens and navigation routes in the app
 */
sealed class NavigationDestination(val route: String) {

    /**
     * Chat screen - AI conversation and code generation
     *
     * iOS equivalent: .chat case in AppView enum
     */
    data object Chat : NavigationDestination("chat")

    /**
     * Scene screen - 3D rendering and preview
     *
     * iOS equivalent: .scene case in AppView enum
     */
    data object Scene : NavigationDestination("scene")

    /**
     * Settings screen - Configure API keys and parameters
     *
     * iOS equivalent: showingSettings sheet in ContentView.swift (line 54)
     */
    data object Settings : NavigationDestination("settings")

    /**
     * Examples screen - Browse code examples
     *
     * iOS equivalent: showingExamples sheet in ContentView.swift (line 56)
     */
    data object Examples : NavigationDestination("examples")

    /**
     * Conversation history screen - View past conversations
     *
     * New feature for Android (not in iOS yet)
     */
    data object History : NavigationDestination("history")

    companion object {
        /**
         * All bottom navigation destinations
         *
         * iOS equivalent: Bottom tab bar buttons in ContentView.swift (line 1069-1178)
         */
        val bottomNavDestinations = listOf(
            Chat,
            Scene
        )

        /**
         * All menu destinations (accessed via overflow menu)
         */
        val menuDestinations = listOf(
            Examples,
            History,
            Settings
        )
    }
}

/**
 * Bottom navigation items with display properties
 *
 * iOS equivalent: Bottom tab bar UI in ContentView.swift (line 1068-1216)
 */
enum class BottomNavItem(
    val destination: NavigationDestination,
    val label: String,
    val icon: String,
    val selectedIcon: String
) {
    CHAT(
        destination = NavigationDestination.Chat,
        label = "Code",
        icon = "chat_bubble_outline",
        selectedIcon = "chat_bubble"
    ),
    SCENE(
        destination = NavigationDestination.Scene,
        label = "Run Scene",
        icon = "play_circle_outline",
        selectedIcon = "play_circle_filled"
    )
}
