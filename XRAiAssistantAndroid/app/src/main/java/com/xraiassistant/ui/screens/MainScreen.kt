package com.xraiassistant.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.outlined.Code
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.xraiassistant.R
import com.xraiassistant.ui.components.ChatScreen
import com.xraiassistant.ui.components.SceneScreen
import com.xraiassistant.ui.components.SettingsScreen
import com.xraiassistant.ui.viewmodels.AppView
import com.xraiassistant.ui.viewmodels.ChatViewModel

/**
 * MainScreen - Primary UI container
 * 
 * Equivalent to ContentView.swift in iOS
 * Provides dual-pane interface with bottom navigation
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen(
    chatViewModel: ChatViewModel
) {
    val uiState by chatViewModel.uiState.collectAsStateWithLifecycle()
    val lastGeneratedCode by chatViewModel.lastGeneratedCode.collectAsStateWithLifecycle()
    
    // Settings bottom sheet
    val settingsBottomSheetState = rememberModalBottomSheetState()
    
    Scaffold(
        bottomBar = {
            MainBottomNavigation(
                currentView = uiState.currentView,
                hasGeneratedCode = lastGeneratedCode.isNotEmpty(),
                onViewChange = { view ->
                    chatViewModel.updateCurrentView(view)
                },
                onSettingsClick = {
                    chatViewModel.showSettings()
                }
            )
        }
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            when (uiState.currentView) {
                AppView.CHAT -> {
                    ChatScreen(
                        chatViewModel = chatViewModel,
                        modifier = Modifier.fillMaxSize()
                    )
                }
                AppView.SCENE -> {
                    SceneScreen(
                        chatViewModel = chatViewModel,
                        modifier = Modifier.fillMaxSize()
                    )
                }
            }
            
            // Code injection loading overlay
            if (uiState.isInjectingCode) {
                CodeInjectionOverlay()
            }
        }
    }
    
    // Settings bottom sheet
    if (uiState.showSettings) {
        ModalBottomSheet(
            onDismissRequest = { chatViewModel.hideSettings() },
            sheetState = settingsBottomSheetState,
            modifier = Modifier.fillMaxHeight(0.9f)
        ) {
            SettingsScreen(
                chatViewModel = chatViewModel,
                onDismiss = { chatViewModel.hideSettings() }
            )
        }
    }
}

/**
 * Bottom Navigation Bar
 */
@Composable
private fun MainBottomNavigation(
    currentView: AppView,
    hasGeneratedCode: Boolean,
    onViewChange: (AppView) -> Unit,
    onSettingsClick: () -> Unit
) {
    NavigationBar {
        // Code Tab (Chat)
        NavigationBarItem(
            icon = { 
                Icon(
                    Icons.Outlined.Code, 
                    contentDescription = stringResource(R.string.nav_chat)
                ) 
            },
            label = { Text(stringResource(R.string.nav_chat)) },
            selected = currentView == AppView.CHAT,
            onClick = { onViewChange(AppView.CHAT) }
        )
        
        // Run Scene Tab
        NavigationBarItem(
            icon = { 
                Box {
                    Icon(
                        Icons.Filled.PlayArrow, 
                        contentDescription = stringResource(R.string.nav_scene)
                    )
                    
                    // Notification dot for generated code
                    if (hasGeneratedCode && currentView != AppView.SCENE) {
                        Box(
                            modifier = Modifier
                                .size(8.dp)
                                .background(
                                    MaterialTheme.colorScheme.error,
                                    CircleShape
                                )
                                .offset(x = 8.dp, y = (-8).dp)
                        )
                    }
                }
            },
            label = { Text(stringResource(R.string.nav_scene)) },
            selected = currentView == AppView.SCENE,
            onClick = { onViewChange(AppView.SCENE) }
        )
        
        // Settings Tab
        NavigationBarItem(
            icon = { 
                Icon(
                    Icons.Filled.Settings, 
                    contentDescription = stringResource(R.string.nav_settings)
                ) 
            },
            label = { Text(stringResource(R.string.nav_settings)) },
            selected = false, // Settings is a modal, not a view
            onClick = onSettingsClick
        )
    }
}

/**
 * Code injection loading overlay
 */
@Composable
private fun CodeInjectionOverlay() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black.copy(alpha = 0.7f)),
        contentAlignment = Alignment.Center
    ) {
        Card(
            modifier = Modifier.padding(32.dp)
        ) {
            Column(
                modifier = Modifier.padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                CircularProgressIndicator()
                Spacer(modifier = Modifier.height(16.dp))
                Text(
                    text = stringResource(R.string.code_injection),
                    style = MaterialTheme.typography.headlineSmall,
                    color = MaterialTheme.colorScheme.primary
                )
            }
        }
    }
}