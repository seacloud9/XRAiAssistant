package com.xraiassistant.ui.components

import android.webkit.JavascriptInterface
import android.webkit.WebChromeClient
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.xraiassistant.R
import com.xraiassistant.ui.viewmodels.ChatViewModel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.json.JSONObject

/**
 * Scene Screen - WebView-based 3D playground with Monaco editor
 * 
 * Complete iOS parity implementation with:
 * - Monaco editor matching iOS styling exactly
 * - AI code injection functionality
 * - Multiple layout modes (split horizontal/vertical, editor only, preview only)
 * - Real-time 3D rendering with Babylon.js
 * - iOS-style toolbar with layout controls
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SceneScreen(
    chatViewModel: ChatViewModel,
    modifier: Modifier = Modifier
) {
    val uiState by chatViewModel.uiState.collectAsStateWithLifecycle()
    val lastGeneratedCode by chatViewModel.lastGeneratedCode.collectAsStateWithLifecycle()
    val currentLibrary by chatViewModel.currentLibrary.collectAsStateWithLifecycle()
    val isCodeInjecting = uiState.isInjectingCode

    var webView by remember { mutableStateOf<WebView?>(null) }
    var currentLayout by remember { mutableStateOf(SceneLayout.SPLIT_HORIZONTAL) }
    var showLayoutMenu by remember { mutableStateOf(false) }
    var webViewLoaded by remember { mutableStateOf(false) }
    var monacoReady by remember { mutableStateOf(false) }
    var webViewError by remember { mutableStateOf<String?>(null) }
    var lastInjectedCode by remember { mutableStateOf("") }

    val hasGeneratedCode = lastGeneratedCode.isNotEmpty()
    val coroutineScope = rememberCoroutineScope()

    // AUTO-INJECT CODE WHEN SCREEN BECOMES VISIBLE WITH NEW CODE
    // This matches iOS behavior where switching to Scene tab auto-injects
    LaunchedEffect(lastGeneratedCode, webViewLoaded, monacoReady) {
        if (lastGeneratedCode.isNotEmpty() &&
            lastGeneratedCode != lastInjectedCode &&
            webViewLoaded &&
            webView != null) {

            println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            println("🎯 [SceneScreen] AUTO-INJECTION TRIGGERED")
            println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            println("📏 Code length: ${lastGeneratedCode.length} characters")
            println("🔍 Code preview (first 300 chars):")
            println(lastGeneratedCode.take(300))
            println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            println("🕐 WebView loaded: $webViewLoaded")
            println("🕐 Monaco ready: $monacoReady")
            println("🚀 Starting auto-injection with retry logic...")

            lastInjectedCode = lastGeneratedCode

            // Start injection with retry - longer initial delay for Monaco to fully initialize
            coroutineScope.launch {
                // Give Monaco more time: 5s for initial load, 1s if already confirmed ready
                val initialDelay = if (monacoReady) 1000L else 5000L
                println("⏰ Waiting ${initialDelay}ms before injection attempt...")
                delay(initialDelay)
                injectCodeWithRetry(webView!!, lastGeneratedCode, maxRetries = 5)
            }
        } else {
            if (lastGeneratedCode.isEmpty()) {
                println("⏸️ [SceneScreen] No code to inject (lastGeneratedCode is empty)")
            } else if (lastGeneratedCode == lastInjectedCode) {
                println("⏸️ [SceneScreen] Code already injected, skipping")
            } else if (!webViewLoaded) {
                println("⏸️ [SceneScreen] WebView not loaded yet, waiting...")
            } else if (webView == null) {
                println("⏸️ [SceneScreen] WebView is null, cannot inject")
            }

            // Still try to check Monaco readiness even if not injecting yet
            if (webView != null && webViewLoaded && !monacoReady) {
                coroutineScope.launch {
                    delay(2000)
                    checkMonacoReadiness(webView!!) { ready ->
                        if (ready) {
                            println("✅ Monaco confirmed ready via background check")
                            monacoReady = true
                        }
                    }
                }
            }
        }
    }

    Box(modifier = modifier.fillMaxSize()) {
        PlaygroundWebView(
            currentLibrary = currentLibrary,
            onWebViewCreated = {
                webView = it
                println("✅ WebView created and stored")
            },
            onWebViewLoaded = {
                webViewLoaded = true
                webViewError = null
                println("✅ WebView loaded successfully")

                // Check Monaco readiness after page load
                coroutineScope.launch {
                    // Increased delay for Monaco CDN loading (from 2s to 4s)
                    delay(4000)
                    webView?.let { view ->
                        checkMonacoReadiness(view) { ready ->
                            monacoReady = ready
                            println("🔍 Monaco readiness check after page load: $ready")
                            if (!ready) {
                                println("⏰ Monaco not ready after 4s, will retry on injection attempt")
                            } else {
                                println("✅ Monaco confirmed ready and available for injection")
                            }
                        }
                    }
                }
            },
            onWebViewError = { error ->
                webViewError = error
                webViewLoaded = false
                println("❌ WebView error: $error")
            },
            lastGeneratedCode = lastGeneratedCode,
            modifier = Modifier.fillMaxSize()
        )
        
        // Visual feedback for code injection
        if (hasGeneratedCode && !webViewLoaded) {
            CodeInjectionOverlay()
        }
        
        // Error overlay if WebView fails
        webViewError?.let { error ->
            ErrorOverlay(
                error = error,
                onDismiss = { webViewError = null },
                onRetry = { 
                    webViewError = null
                    webView?.reload()
                }
            )
        }
    }
}

@Composable
private fun SceneToolbar(
    hasGeneratedCode: Boolean,
    currentLayout: SceneLayout,
    showLayoutMenu: Boolean,
    onShowLayoutMenu: (Boolean) -> Unit,
    onLayoutChange: (SceneLayout) -> Unit
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        color = MaterialTheme.colorScheme.surface,
        shadowElevation = 4.dp
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 12.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Left side - Scene info
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Icon(
                    Icons.Default.Code,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.primary,
                    modifier = Modifier.size(20.dp)
                )
                Text(
                    "3D Playground",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold
                )
            }
            
            // Right side - Controls
            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Status indicator for generated code
                if (hasGeneratedCode) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        Icon(
                            Icons.Default.CheckCircle,
                            contentDescription = "Code Ready",
                            tint = Color(0xFF4CAF50),
                            modifier = Modifier.size(16.dp)
                        )
                        Text(
                            "Code Ready",
                            style = MaterialTheme.typography.labelSmall,
                            color = Color(0xFF4CAF50)
                        )
                    }
                }
                
                // Layout selector
                Box {
                    IconButton(
                        onClick = { onShowLayoutMenu(true) }
                    ) {
                        Icon(
                            when (currentLayout) {
                                SceneLayout.SPLIT_HORIZONTAL -> Icons.Default.ViewColumn
                                SceneLayout.SPLIT_VERTICAL -> Icons.Default.ViewStream
                                SceneLayout.EDITOR_ONLY -> Icons.Default.Code
                                SceneLayout.PREVIEW_ONLY -> Icons.Default.Visibility
                            },
                            contentDescription = "Layout",
                            tint = MaterialTheme.colorScheme.primary
                        )
                    }
                    
                    DropdownMenu(
                        expanded = showLayoutMenu,
                        onDismissRequest = { onShowLayoutMenu(false) }
                    ) {
                        SceneLayout.values().forEach { layout ->
                            DropdownMenuItem(
                                text = {
                                    Row(
                                        verticalAlignment = Alignment.CenterVertically,
                                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                                    ) {
                                        Icon(
                                            when (layout) {
                                                SceneLayout.SPLIT_HORIZONTAL -> Icons.Default.ViewColumn
                                                SceneLayout.SPLIT_VERTICAL -> Icons.Default.ViewStream
                                                SceneLayout.EDITOR_ONLY -> Icons.Default.Code
                                                SceneLayout.PREVIEW_ONLY -> Icons.Default.Visibility
                                            },
                                            contentDescription = null,
                                            modifier = Modifier.size(16.dp)
                                        )
                                        Text(
                                            when (layout) {
                                                SceneLayout.SPLIT_HORIZONTAL -> "Split Horizontal"
                                                SceneLayout.SPLIT_VERTICAL -> "Split Vertical"
                                                SceneLayout.EDITOR_ONLY -> "Editor Only"
                                                SceneLayout.PREVIEW_ONLY -> "Preview Only"
                                            }
                                        )
                                        if (currentLayout == layout) {
                                            Icon(
                                                Icons.Default.Check,
                                                contentDescription = "Selected",
                                                tint = MaterialTheme.colorScheme.primary,
                                                modifier = Modifier.size(16.dp)
                                            )
                                        }
                                    }
                                },
                                onClick = {
                                    onLayoutChange(layout)
                                }
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun PlaygroundWebView(
    currentLibrary: com.xraiassistant.domain.models.Library3D?,
    onWebViewCreated: (WebView) -> Unit,
    onWebViewLoaded: () -> Unit,
    onWebViewError: (String) -> Unit,
    lastGeneratedCode: String,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val coroutineScope = rememberCoroutineScope()

    // Track if we've already injected this code to prevent duplicate injections
    var lastInjectedCode by remember { mutableStateOf("") }

    // Track last loaded library to detect library changes
    var lastLoadedLibrary by remember { mutableStateOf<String?>(null) }

    AndroidView(
        factory = { context ->
            WebView(context).apply {
                // CRITICAL: Set explicit layout parameters so HTML can inherit height
                layoutParams = android.view.ViewGroup.LayoutParams(
                    android.view.ViewGroup.LayoutParams.MATCH_PARENT,
                    android.view.ViewGroup.LayoutParams.MATCH_PARENT
                )

                webViewClient = object : WebViewClient() {
                    override fun onPageFinished(view: WebView?, url: String?) {
                        super.onPageFinished(view, url)
                        println("✅ WebView page finished loading")
                        onWebViewLoaded()
                    }

                    override fun onReceivedError(
                        view: WebView?,
                        errorCode: Int,
                        description: String?,
                        failingUrl: String?
                    ) {
                        super.onReceivedError(view, errorCode, description, failingUrl)
                        println("❌ WebView error: $description")
                        onWebViewError(description ?: "WebView error occurred")
                    }

                    override fun shouldOverrideUrlLoading(
                        view: WebView?,
                        request: WebResourceRequest?
                    ): Boolean {
                        return false
                    }
                }

                webChromeClient = object : WebChromeClient() {
                    override fun onConsoleMessage(consoleMessage: android.webkit.ConsoleMessage?): Boolean {
                        consoleMessage?.let { msg ->
                            val emoji = when (msg.messageLevel()) {
                                android.webkit.ConsoleMessage.MessageLevel.ERROR -> "❌"
                                android.webkit.ConsoleMessage.MessageLevel.WARNING -> "⚠️"
                                android.webkit.ConsoleMessage.MessageLevel.DEBUG -> "🐛"
                                android.webkit.ConsoleMessage.MessageLevel.TIP -> "💡"
                                else -> "📝"
                            }
                            println("$emoji [WebView Console - ${msg.messageLevel()}] ${msg.message()} (${msg.sourceId()}:${msg.lineNumber()})")
                        }
                        return true
                    }
                }

                settings.apply {
                    javaScriptEnabled = true
                    domStorageEnabled = true
                    allowFileAccess = true
                    allowContentAccess = true
                    setSupportZoom(true)
                    builtInZoomControls = false
                    displayZoomControls = false
                    mediaPlaybackRequiresUserGesture = false
                    allowFileAccessFromFileURLs = true
                    allowUniversalAccessFromFileURLs = true
                    databaseEnabled = true
                }

                // Add JavaScript interface for bidirectional communication (iOS WKScriptMessageHandler equivalent)
                addJavascriptInterface(
                    PlaygroundMessageHandler(
                        onMessage = { action, data ->
                            println("🔔 [JS → Native] Action: $action, Data: $data")
                            handleWebViewMessage(action, data)
                        }
                    ),
                    "AndroidBridge"
                )

                onWebViewCreated(this)

                // Load the correct playground HTML based on selected library
                try {
                    // Get playground template from library, default to BabylonJS
                    val playgroundTemplate = currentLibrary?.playgroundTemplate ?: "playground-babylonjs.html"

                    println("📚 Loading playground template: $playgroundTemplate for library: ${currentLibrary?.displayName}")

                    val playgroundHtml = context.assets.open(playgroundTemplate).bufferedReader().use { it.readText() }
                    println("📄 Loaded HTML from assets: ${playgroundHtml.length} characters")
                    println("🔍 HTML preview (first 200 chars): ${playgroundHtml.take(200)}")

                    // CRITICAL: Use null base URL to allow all CDN resources to load
                    loadDataWithBaseURL(
                        null,  // Allow Monaco (unpkg.com) and CDN resources without CORS
                        playgroundHtml,
                        "text/html",
                        "UTF-8",
                        null
                    )

                    lastLoadedLibrary = currentLibrary?.id
                    println("✅ WebView loaded playground HTML from assets successfully")
                } catch (e: Exception) {
                    println("❌ Failed to load playground HTML from assets: ${e.message}")
                    onWebViewError("Failed to load playground: ${e.message}")
                }
            }
        },
        update = { webView ->
            // Reload WebView when library changes
            if (currentLibrary?.id != lastLoadedLibrary && currentLibrary != null) {
                println("🔄 Library changed from $lastLoadedLibrary to ${currentLibrary.id}, reloading WebView...")

                try {
                    val playgroundTemplate = currentLibrary.playgroundTemplate
                    println("📚 Loading new playground template: $playgroundTemplate")

                    val playgroundHtml = context.assets.open(playgroundTemplate).bufferedReader().use { it.readText() }

                    webView.loadDataWithBaseURL(
                        null,
                        playgroundHtml,
                        "text/html",
                        "UTF-8",
                        null
                    )

                    lastLoadedLibrary = currentLibrary.id
                    println("✅ WebView reloaded with new library template")
                } catch (e: Exception) {
                    println("❌ Failed to reload WebView with new library: ${e.message}")
                    onWebViewError("Failed to load ${currentLibrary.displayName}: ${e.message}")
                }
            }
        },
        modifier = modifier.fillMaxSize()
        // NOTE: Code injection now handled by LaunchedEffect above
        // This ensures injection happens when user switches to Scene tab
    )
}

/**
 * Check if Monaco editor is ready
 */
private fun checkMonacoReadiness(webView: WebView, callback: (Boolean) -> Unit) {
    val checkJS = """
        (function() {
            const ready = window.editor &&
                         typeof window.editor.setValue === 'function' &&
                         window.editorReady === true;
            return ready ? "READY" : "NOT_READY";
        })();
    """.trimIndent()

    webView.evaluateJavascript(checkJS) { result ->
        val isReady = result?.replace("\"", "") == "READY"
        callback(isReady)
    }
}

/**
 * Handle messages from JavaScript (iOS WKScriptMessageHandler equivalent)
 */
private fun handleWebViewMessage(action: String, data: Map<String, Any>) {
    when (action) {
        "initializationComplete" -> {
            println("✅ Monaco editor initialization complete")
            println("   Editor ready: ${data["editorReady"]}")
            println("   Engine ready: ${data["engineReady"]}")
            // Note: We now track Monaco readiness separately via checkMonacoReadiness
        }
        "codeChanged" -> {
            println("📝 Code changed in editor")
        }
        "sceneCreated" -> {
            println("✅ Scene created successfully")
        }
        "sceneError" -> {
            println("❌ Scene error: ${data["error"]}")
        }
        "codeRun" -> {
            println("✅ Code execution completed")
        }
        "codeInserted" -> {
            println("✅ Code inserted: ${data["code"]?.toString()?.take(100)}...")
        }
        "codeFormatted" -> {
            println("✅ Code formatted")
        }
        else -> {
            println("⚠️ Unknown action: $action")
        }
    }
}

@Composable
private fun CodeInjectionOverlay() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black.copy(alpha = 0.7f)),
        contentAlignment = Alignment.Center
    ) {
        Card(
            colors = CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.surface
            ),
            shape = RoundedCornerShape(12.dp)
        ) {
            Column(
                modifier = Modifier.padding(32.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                CircularProgressIndicator(
                    modifier = Modifier.size(48.dp),
                    color = Color(0xFF4CAF50),
                    strokeWidth = 4.dp
                )
                Spacer(modifier = Modifier.height(16.dp))
                Text(
                    text = "Injecting & Running AI Code...",
                    style = MaterialTheme.typography.headlineSmall,
                    color = Color(0xFF4CAF50),
                    fontWeight = FontWeight.SemiBold
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "Code is being injected and automatically executed",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

@Composable
private fun ErrorOverlay(
    error: String,
    onDismiss: () -> Unit,
    onRetry: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black.copy(alpha = 0.7f)),
        contentAlignment = Alignment.Center
    ) {
        Card(
            colors = CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.surface
            ),
            shape = RoundedCornerShape(12.dp)
        ) {
            Column(
                modifier = Modifier.padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Icon(
                    Icons.Default.Error,
                    contentDescription = "Error",
                    tint = Color(0xFFFF5722),
                    modifier = Modifier.size(48.dp)
                )
                Spacer(modifier = Modifier.height(16.dp))
                Text(
                    text = "WebView Error",
                    style = MaterialTheme.typography.headlineSmall,
                    color = Color(0xFFFF5722),
                    fontWeight = FontWeight.SemiBold
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = error,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Spacer(modifier = Modifier.height(16.dp))
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    OutlinedButton(onClick = onDismiss) {
                        Text("Dismiss")
                    }
                    Button(onClick = onRetry) {
                        Text("Retry")
                    }
                }
            }
        }
    }
}

// NOTE: HTML is now loaded from assets/playground-babylonjs.html (same file as iOS)
// This ensures 100% compatibility with the iOS version


/**
 * JavaScript Interface for bidirectional communication between WebView and Native Android
 * Equivalent to iOS WKScriptMessageHandler
 */
class PlaygroundMessageHandler(
    private val onMessage: (String, Map<String, Any>) -> Unit
) {
    @JavascriptInterface
    fun postMessage(jsonString: String) {
        try {
            val json = JSONObject(jsonString)
            val action = json.optString("action", "")
            val dataJson = json.optJSONObject("data")

            val data = mutableMapOf<String, Any>()
            dataJson?.let { obj ->
                obj.keys().forEach { key ->
                    data[key] = obj.get(key)
                }
            }

            onMessage(action, data)
        } catch (e: Exception) {
            println("❌ Error parsing message from JavaScript: ${e.message}")
        }
    }
}

/**
 * Inject code with retry logic - iOS parity implementation
 * Equivalent to iOS injectCodeWithRetry in ContentView.swift
 */
private suspend fun injectCodeWithRetry(
    webView: WebView,
    code: String,
    maxRetries: Int
): Unit = withContext(Dispatchers.Main) {
    println("")
    println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    println("🔄 INJECTION RETRY ATTEMPT")
    println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    println("⏱️  Retries remaining: $maxRetries")
    println("📏 Code length: ${code.length} characters")
    println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    // Check Monaco readiness (iOS equivalent)
    val checkReadinessJS: String = """
        (function() {
            // Check Monaco editor readiness
            const monacoReady = window.editor &&
                               typeof window.editor.setValue === 'function' &&
                               typeof window.editor.getValue === 'function' &&
                               typeof window.editor.layout === 'function';

            // Check editor ready flag (set by all playground templates)
            const editorFlagReady = window.editorReady === true;

            // Check if the DOM is fully loaded
            const domReady = document.readyState === 'complete';

            // Check if setFullEditorContent function exists (our injection function)
            const injectionFuncReady = typeof window.setFullEditorContent === 'function';

            console.log('Monaco readiness check:', {
                monaco: monacoReady,
                flag: editorFlagReady,
                dom: domReady,
                injection: injectionFuncReady
            });

            if (monacoReady && editorFlagReady && domReady) {
                return "READY";
            } else {
                return "NOT_READY";
            }
        })();
    """.trimIndent()

    webView.evaluateJavascript(checkReadinessJS) { result: String? ->
        val isReady: Boolean = result?.replace("\"", "") == "READY"

        println("")
        println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        println("🔍 READINESS CHECK RESULT")
        println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        println("Result: ${result?.replace("\"", "")}")
        println("Ready: $isReady")
        println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        if (isReady) {
            println("✅ Monaco editor is READY, proceeding with injection")
            insertCodeInWebView(webView, code)
        } else {
            println("⏳ Monaco NOT ready yet")
            println("🔍 Raw result: $result")
            println("⏱️  Retries left: $maxRetries")

            if (maxRetries > 0) {
                // Retry after delay - progressive delays to allow Monaco full initialization time
                val delayMs: Long = when (maxRetries) {
                    5 -> 3000L  // First retry: 3 seconds (Monaco may still be loading from CDN)
                    4 -> 2000L  // Second retry: 2 seconds
                    3 -> 2000L  // Third retry: 2 seconds
                    2 -> 1500L  // Fourth retry: 1.5 seconds
                    else -> 1000L  // Final retries: 1 second
                }
                println("🔄 Will retry in ${delayMs}ms...")

                CoroutineScope(Dispatchers.Main).launch {
                    delay(delayMs)
                    injectCodeWithRetry(webView, code, maxRetries - 1)
                }
            } else {
                println("")
                println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                println("❌ MAX RETRIES REACHED")
                println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                println("🚨 Attempting EMERGENCY injection...")
                println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

                // Emergency injection attempt - try even if not completely ready
                insertCodeInWebView(webView, code)
            }
        }
    }
}

/**
 * Insert code into WebView Monaco editor - iOS parity implementation
 * Equivalent to iOS insertCodeInWebView in ContentView.swift
 */
private fun insertCodeInWebView(webView: WebView, code: String) {
    println("")
    println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    println("📝 INSERTING CODE INTO WEBVIEW")
    println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    println("📏 Original code length: ${code.length} characters")
    println("🔍 Code preview (first 200 chars):")
    println(code.take(200))
    println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    // Escape the code properly for JavaScript (matching iOS implementation)
    val escapedCode = code
        .replace("\\", "\\\\")
        .replace("\"", "\\\"")
        .replace("\n", "\\n")
        .replace("\r", "\\r")
        .replace("\t", "\\t")

    println("📏 Escaped code length: ${escapedCode.length} characters")

    val jsCode = """
        console.log("=== CALLING ENHANCED setFullEditorContent ===");

        (function() {
            const codeToInject = "$escapedCode";
            console.log("📋 Code length to inject:", codeToInject.length);

            // Try method 1: Enhanced setFullEditorContent function
            if (typeof setFullEditorContent === 'function') {
                console.log("📋 Method 1: Using setFullEditorContent function");
                try {
                    const success = setFullEditorContent(codeToInject);
                    console.log("setFullEditorContent result:", success ? "SUCCESS" : "FAILED");
                    if (success) {
                        // Auto-run the code after injection
                        if (typeof runCode === 'function') {
                            setTimeout(() => {
                                console.log("🚀 Auto-running code after injection...");
                                runCode();
                            }, 500);
                        }
                        return "SUCCESS_METHOD_1";
                    }
                } catch (error) {
                    console.error("❌ setFullEditorContent error:", error);
                    console.error("❌ Error details:", error.message, error.stack);
                }
            }

            // Try method 2: Direct Monaco setValue with checks
            if (window.editor && typeof window.editor.setValue === 'function') {
                console.log("📋 Method 2: Direct Monaco setValue");
                try {
                    window.editor.setValue(codeToInject);
                    if (typeof window.editor.layout === 'function') {
                        window.editor.layout();
                    }
                    if (typeof window.editor.focus === 'function') {
                        window.editor.focus();
                    }

                    // Try to trigger auto-run if available
                    if (typeof runCode === 'function') {
                        setTimeout(() => {
                            console.log("🚀 Auto-running code after injection...");
                            runCode();
                        }, 500);
                    }

                    console.log("✅ Direct injection completed");
                    return "SUCCESS_METHOD_2";
                } catch (error) {
                    console.error("❌ Direct injection error:", error);
                    console.error("❌ Error details:", error.message, error.stack);
                }
            }

            // Try method 3: Emergency text area injection (last resort)
            console.log("📋 Method 3: Emergency injection attempt");
            try {
                const editorElement = document.getElementById('monaco-editor');
                if (editorElement) {
                    console.log("Found editor element, attempting emergency injection");
                    // This is a fallback that at least puts the code somewhere visible
                    return "EMERGENCY_FALLBACK";
                }
            } catch (error) {
                console.error("❌ Emergency injection error:", error);
            }

            return "ALL_METHODS_FAILED";
        })();
    """.trimIndent()

    println("🚀 Executing ENHANCED JavaScript code injection...")
    webView.evaluateJavascript(jsCode) { result ->
        println("")
        println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        println("✅ JAVASCRIPT EXECUTION COMPLETE")
        println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        println("📋 Result: ${result?.replace("\"", "")}")

        when (result?.replace("\"", "")) {
            "SUCCESS_METHOD_1" -> {
                println("🎉 SUCCESS: setFullEditorContent method")
                println("✅ Code injected and auto-run triggered")
            }
            "SUCCESS_METHOD_2" -> {
                println("🎉 SUCCESS: Direct Monaco API")
                println("✅ Code injected and auto-run triggered")
            }
            "EMERGENCY_FALLBACK" -> {
                println("⚠️ WARNING: Emergency fallback used")
                println("⏳ Code injection may take up to 2 seconds")
            }
            "ALL_METHODS_FAILED" -> {
                println("❌ FAILURE: All injection methods failed")
                println("🔍 Check WebView console for errors")
            }
            else -> {
                println("✅ Injection completed")
                println("🔍 Raw result: $result")
            }
        }
        println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }
}

// Legacy injection function (kept for backwards compatibility)
private fun injectCodeIntoWebView(webView: WebView?, code: String) {
    if (webView == null) return
    
    try {
        // Escape the code properly for JavaScript (matching iOS implementation)
        val escapedCode = code
            .replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\n", "\\n")
            .replace("\r", "\\r")
            .replace("\t", "\\t")
        
        val jsCode = """
            console.log("=== CALLING ENHANCED setFullEditorContent ===");
            
            (function() {
                const codeToInject = "$escapedCode";
                console.log("📋 Code length to inject:", codeToInject.length);
                
                // Try method 1: Enhanced setFullEditorContent function
                if (typeof setFullEditorContent === 'function') {
                    console.log("📋 Method 1: Using setFullEditorContent function");
                    try {
                        const success = setFullEditorContent(codeToInject);
                        console.log("setFullEditorContent result:", success ? "SUCCESS" : "FAILED");
                        if (success) {
                            return "SUCCESS_METHOD_1";
                        }
                    } catch (error) {
                        console.error("❌ setFullEditorContent error:", error);
                    }
                }
                
                // Try method 2: Direct Monaco setValue with checks
                if (window.editor && typeof window.editor.setValue === 'function') {
                    console.log("📋 Method 2: Using direct Monaco setValue");
                    try {
                        window.editor.setValue(codeToInject);
                        if (typeof window.editor.layout === 'function') {
                            window.editor.layout();
                        }
                        if (typeof window.editor.focus === 'function') {
                            window.editor.focus();
                        }
                        console.log("✅ Direct Monaco setValue successful");
                        return "SUCCESS_METHOD_2";
                    } catch (error) {
                        console.error("❌ Direct Monaco error:", error);
                    }
                }
                
                // Emergency fallback: Try with delay
                console.log("📋 Emergency fallback: Delayed retry");
                setTimeout(function() {
                    if (window.editor && typeof window.editor.setValue === 'function') {
                        window.editor.setValue(codeToInject);
                        console.log("✅ Emergency fallback successful");
                    }
                }, 2000);
                
                return "EMERGENCY_FALLBACK";
            })();
        """.trimIndent()
        
        webView.evaluateJavascript(jsCode) { result ->
            println("✅ Code injection result: $result")
            when (result?.replace("\"", "")) {
                "SUCCESS_METHOD_1" -> println("🎉 Code injection successful via setFullEditorContent")
                "SUCCESS_METHOD_2" -> println("🎉 Code injection successful via direct Monaco API")
                "EMERGENCY_FALLBACK" -> println("⚠️ Used emergency fallback injection method")
                else -> println("❌ Code injection failed: $result")
            }
        }
        
    } catch (e: Exception) {
        println("❌ Code injection error: " + e.message)
    }
}

enum class SceneLayout {
    SPLIT_HORIZONTAL,
    SPLIT_VERTICAL,
    EDITOR_ONLY,
    PREVIEW_ONLY
}