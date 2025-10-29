package com.xrai.assistant.presentation.navigation

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import timber.log.Timber

/**
 * Navigation graph for XRAiAssistant
 *
 * iOS equivalent: ContentView body with tab bar navigation in ContentView.swift (line 630-1217)
 *
 * Manages navigation between Chat, Scene, Examples, Settings screens
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NavGraph(
    navController: NavHostController = rememberNavController()
) {
    val currentBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = currentBackStackEntry?.destination?.route

    var showSettings by remember { mutableStateOf(false) }
    var showExamples by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = when (currentRoute) {
                            NavigationDestination.Chat.route -> "AI Assistant"
                            NavigationDestination.Scene.route -> "3D Scene"
                            NavigationDestination.Settings.route -> "Settings"
                            NavigationDestination.Examples.route -> "Examples"
                            NavigationDestination.History.route -> "History"
                            else -> "XRAiAssistant"
                        }
                    )
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer,
                    titleContentColor = MaterialTheme.colorScheme.onPrimaryContainer
                ),
                actions = {
                    // Examples button
                    IconButton(onClick = { showExamples = true }) {
                        Icon(
                            imageVector = Icons.Default.MenuBook,
                            contentDescription = "Examples"
                        )
                    }

                    // Settings button
                    IconButton(onClick = { showSettings = true }) {
                        Icon(
                            imageVector = Icons.Default.Settings,
                            contentDescription = "Settings"
                        )
                    }
                }
            )
        },
        bottomBar = {
            NavigationBar {
                BottomNavItem.values().forEach { item ->
                    val selected = currentRoute == item.destination.route

                    NavigationBarItem(
                        selected = selected,
                        onClick = {
                            Timber.d("🔘 Bottom nav clicked: ${item.label}")
                            if (currentRoute != item.destination.route) {
                                navController.navigate(item.destination.route) {
                                    // Pop up to start destination to avoid stack buildup
                                    popUpTo(NavigationDestination.Chat.route) {
                                        saveState = true
                                    }
                                    launchSingleTop = true
                                    restoreState = true
                                }
                            }
                        },
                        icon = {
                            Icon(
                                imageVector = if (selected) {
                                    when (item) {
                                        BottomNavItem.CHAT -> Icons.Default.ChatBubble
                                        BottomNavItem.SCENE -> Icons.Default.PlayCircleFilled
                                    }
                                } else {
                                    when (item) {
                                        BottomNavItem.CHAT -> Icons.Default.ChatBubbleOutline
                                        BottomNavItem.SCENE -> Icons.Default.PlayCircleOutline
                                    }
                                },
                                contentDescription = item.label
                            )
                        },
                        label = { Text(item.label) },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = MaterialTheme.colorScheme.primary,
                            selectedTextColor = MaterialTheme.colorScheme.primary,
                            indicatorColor = MaterialTheme.colorScheme.primaryContainer,
                            unselectedIconColor = MaterialTheme.colorScheme.onSurfaceVariant,
                            unselectedTextColor = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    )
                }
            }
        }
    ) { paddingValues ->
        NavHost(
            navController = navController,
            startDestination = NavigationDestination.Chat.route,
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            // Chat screen
            composable(NavigationDestination.Chat.route) {
                ChatScreenPlaceholder()
            }

            // Scene screen
            composable(NavigationDestination.Scene.route) {
                SceneScreenPlaceholder()
            }

            // Settings screen
            composable(NavigationDestination.Settings.route) {
                SettingsScreenPlaceholder()
            }

            // Examples screen
            composable(NavigationDestination.Examples.route) {
                ExamplesScreenPlaceholder()
            }

            // History screen
            composable(NavigationDestination.History.route) {
                HistoryScreenPlaceholder()
            }
        }
    }

    // Settings sheet
    if (showSettings) {
        ModalBottomSheet(
            onDismissRequest = { showSettings = false },
            modifier = Modifier.fillMaxHeight(0.9f)
        ) {
            SettingsScreenPlaceholder()
        }
    }

    // Examples sheet
    if (showExamples) {
        ModalBottomSheet(
            onDismissRequest = { showExamples = false },
            modifier = Modifier.fillMaxHeight(0.9f)
        ) {
            ExamplesScreenPlaceholder()
        }
    }
}

/**
 * Placeholder composables (will be replaced with actual implementations)
 */
@Composable
private fun ChatScreenPlaceholder() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Column {
            Text(
                text = "💬 Chat Screen",
                style = MaterialTheme.typography.headlineMedium
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = "AI conversation interface will be implemented here",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
private fun SceneScreenPlaceholder() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Column {
            Text(
                text = "🎮 Scene Screen",
                style = MaterialTheme.typography.headlineMedium
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = "3D scene rendering with WebView will be implemented here",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
private fun SettingsScreenPlaceholder() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Column {
            Text(
                text = "⚙️ Settings Screen",
                style = MaterialTheme.typography.headlineMedium
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = "API keys, model selection, parameters will be configured here",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
private fun ExamplesScreenPlaceholder() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Column {
            Text(
                text = "📚 Examples Screen",
                style = MaterialTheme.typography.headlineMedium
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = "Browse code examples by category will be implemented here",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
private fun HistoryScreenPlaceholder() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Column {
            Text(
                text = "📜 History Screen",
                style = MaterialTheme.typography.headlineMedium
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = "Conversation history will be displayed here",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}
