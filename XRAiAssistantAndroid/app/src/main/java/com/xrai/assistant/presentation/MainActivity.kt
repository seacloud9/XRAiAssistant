package com.xrai.assistant.presentation

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.core.view.WindowCompat
import com.xrai.assistant.presentation.navigation.NavGraph
import com.xrai.assistant.presentation.theme.XRAiAssistantTheme
import dagger.hilt.android.AndroidEntryPoint
import timber.log.Timber

/**
 * Main Activity for XRAiAssistant
 *
 * iOS equivalent: ContentView.swift (main UI entry point)
 *
 * Responsibilities:
 * - Set up Compose UI
 * - Configure edge-to-edge display
 * - Initialize navigation
 * - Manage activity lifecycle
 */
@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        Timber.d("🎨 MainActivity onCreate")

        // Enable edge-to-edge display
        enableEdgeToEdge()

        // Configure window for immersive experience
        WindowCompat.setDecorFitsSystemWindows(window, false)

        setContent {
            XRAiAssistantTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    MainScreen()
                }
            }
        }

        Timber.d("✅ MainActivity setup complete")
    }

    override fun onResume() {
        super.onResume()
        Timber.d("▶️ MainActivity onResume")
    }

    override fun onPause() {
        super.onPause()
        Timber.d("⏸️ MainActivity onPause")
    }

    override fun onDestroy() {
        super.onDestroy()
        Timber.d("🛑 MainActivity onDestroy")
    }
}

/**
 * Main screen composable that sets up navigation
 *
 * iOS equivalent: ContentView body in ContentView.swift (line 630)
 */
@Composable
private fun MainScreen() {
    NavGraph()
}
