package com.xraiassistant

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import com.xraiassistant.ui.screens.MainScreen
import com.xraiassistant.ui.theme.XRAiAssistantTheme
import com.xraiassistant.ui.viewmodels.ChatViewModel
import dagger.hilt.android.AndroidEntryPoint

/**
 * MainActivity - Entry point for XRAiAssistant Android
 * 
 * Equivalent to ContentView.swift in the iOS version
 * Provides dual-pane interface: Chat + 3D Scene Playground
 */
@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        setContent {
            XRAiAssistantTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    val chatViewModel: ChatViewModel = hiltViewModel()
                    MainScreen(chatViewModel = chatViewModel)
                }
            }
        }
    }
}