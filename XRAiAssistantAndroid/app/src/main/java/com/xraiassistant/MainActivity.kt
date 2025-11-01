package com.xraiassistant

import android.os.Bundle
import android.util.Log
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
        Log.d("XRAiAssistant", "MainActivity onCreate started")
        
        try {
            super.onCreate(savedInstanceState)
            Log.d("XRAiAssistant", "super.onCreate completed")
            
            setContent {
                Log.d("XRAiAssistant", "setContent started")
                
                XRAiAssistantTheme {
                    Log.d("XRAiAssistant", "XRAiAssistantTheme started")
                    
                    Surface(
                        modifier = Modifier.fillMaxSize(),
                        color = MaterialTheme.colorScheme.background
                    ) {
                        Log.d("XRAiAssistant", "Surface started")
                        
                        val chatViewModel: ChatViewModel = hiltViewModel()
                        Log.d("XRAiAssistant", "ChatViewModel created successfully")
                        
                        MainScreen(chatViewModel = chatViewModel)
                        Log.d("XRAiAssistant", "MainScreen composed successfully")
                    }
                }
            }
            
            Log.d("XRAiAssistant", "MainActivity onCreate completed successfully")
        } catch (e: Exception) {
            Log.e("XRAiAssistant", "Error in MainActivity onCreate", e)
            throw e
        }
    }
}