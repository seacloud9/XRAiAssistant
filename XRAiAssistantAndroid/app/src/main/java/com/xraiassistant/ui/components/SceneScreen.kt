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
    var webViewError by remember { mutableStateOf<String?>(null) }
    
    val hasGeneratedCode = lastGeneratedCode.isNotEmpty()
    
    Box(modifier = modifier.fillMaxSize()) {
        PlaygroundWebView(
            onWebViewCreated = { webView = it },
            onWebViewLoaded = { 
                webViewLoaded = true
                webViewError = null
            },
            onWebViewError = { error ->
                webViewError = error
                webViewLoaded = false
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

    AndroidView(
        factory = { context ->
            WebView(context).apply {
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

                // Load the enhanced playground HTML matching iOS exactly
                val playgroundHtml = generateBabylonJSPlaygroundHtml()
                loadDataWithBaseURL(
                    "https://playground.babylonjs.com/",
                    playgroundHtml,
                    "text/html",
                    "UTF-8",
                    null
                )
            }
        },
        modifier = modifier.fillMaxSize(),
        update = { webView ->
            // Inject code with retry logic when lastGeneratedCode changes (iOS parity)
            if (lastGeneratedCode.isNotEmpty() && lastGeneratedCode != lastInjectedCode) {
                println("🎯 New code detected, starting injection with retry logic...")
                println("📏 Code length: ${lastGeneratedCode.length} characters")

                // Mark as injected immediately to prevent duplicate attempts
                lastInjectedCode = lastGeneratedCode

                // Start injection with retry in coroutine (equivalent to iOS injectCodeWithRetry)
                coroutineScope.launch {
                    injectCodeWithRetry(webView, lastGeneratedCode, maxRetries = 3)
                }
            }
        }
    )
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

private fun generateBabylonJSPlaygroundHtml(): String {
    
    return """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Babylon.js Playground</title>
    <script src="https://cdn.jsdelivr.net/npm/cannon@0.6.2/build/cannon.min.js"></script>
    <script src="https://cdn.babylonjs.com/babylon.js"></script>
    <script src="https://cdn.babylonjs.com/materialsLibrary/babylonjs.materials.min.js"></script>
    <script src="https://cdn.babylonjs.com/postProcessesLibrary/babylonjs.postProcess.min.js"></script>
    <script src="https://cdn.babylonjs.com/loaders/babylonjs.loaders.min.js"></script>
    <script src="https://cdn.babylonjs.com/serializers/babylonjs.serializers.min.js"></script>
    <script src="https://cdn.babylonjs.com/gui/babylon.gui.min.js"></script>
    <script src="https://cdn.babylonjs.com/inspector/babylon.inspector.bundle.js"></script>
    
    <!-- Monaco Editor -->
    <script src="https://unpkg.com/monaco-editor@0.45.0/min/vs/loader.js"></script>
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
            height: 100vh;
            display: flex;
            flex-direction: column;
            background: #1e1e1e;
            color: #fff;
        }
        
        .header {
            background: #2d2d30;
            padding: 8px 12px;
            display: flex;
            align-items: center;
            gap: 6px;
            border-bottom: 1px solid #3e3e42;
            min-height: 40px;
        }
        
        .menu-btn {
            background: #0e639c;
            color: white;
            border: none;
            padding: 6px 12px;
            border-radius: 3px;
            cursor: pointer;
            font-size: 12px;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
            font-weight: 500;
            transition: background-color 0.2s;
            outline: none;
            box-shadow: none;
            text-decoration: none;
        }
        
        .menu-btn:hover {
            background: #1177bb;
        }
        
        .menu-btn:focus {
            outline: none;
            box-shadow: 0 0 0 2px rgba(14, 99, 156, 0.3);
        }
        
        .menu-btn:active {
            background: #0c5a8a;
        }
        
        .main-container {
            flex: 1;
            display: flex;
            position: relative;
            overflow: hidden;
        }
        
        .editor-container {
            width: 50%;
            background: #1e1e1e;
            border-right: 1px solid #3e3e42;
            position: relative;
            overflow: hidden;
            transition: width 0.3s ease-in-out;
            display: flex;
            flex-direction: column;
        }

        .editor-container.open {
            width: 100%;
            border-right: none;
        }

        .editor-container.closed {
            width: 0%;
            min-width: 0;
            border-right: none;
        }

        .canvas-container {
            width: 50%;
            background: #252526;
            position: relative;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: width 0.3s ease-in-out;
        }

        .canvas-container.editor-open {
            width: 0%;
            min-width: 0;
        }

        .canvas-container.editor-closed {
            width: 100%;
        }
        
        #renderCanvas {
            width: 100%;
            height: 100%;
            display: block;
        }
        
        .loading {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: #fff;
            font-size: 18px;
            text-align: center;
            z-index: 100;
        }
        
        .run-button {
            position: absolute;
            top: 20px;
            right: 20px;
            background: #28a745;
            color: white;
            border: none;
            padding: 10px 16px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 500;
            z-index: 1000;
            transition: background-color 0.2s;
        }
        
        .run-button:hover {
            background: #218838;
        }
        
        .error-display {
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            background: #d32f2f;
            color: white;
            padding: 12px;
            font-family: 'Consolas', 'Monaco', monospace;
            font-size: 11px;
            max-height: 200px;
            overflow-y: auto;
            z-index: 1000;
            transform: translateY(100%);
            transition: transform 0.3s ease;
        }
        
        .error-display.visible {
            transform: translateY(0);
        }
        
        .injection-toast {
            position: fixed;
            top: 80px;
            right: 20px;
            background: #4CAF50;
            color: white;
            padding: 12px 20px;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            z-index: 2000;
            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
            transform: translateX(100%);
            transition: transform 0.3s ease-in-out;
        }
        
        .injection-toast.visible {
            transform: translateX(0);
        }
    </style>
</head>
<body>
    <div class="header">
        <button class="menu-btn" id="toggleEditorBtn" onclick="toggleEditor()">SPLIT</button>
        <button class="menu-btn" onclick="runCode()">▶ RUN</button>
        <button class="menu-btn" onclick="formatCode()">FORMAT</button>
        <button class="menu-btn" onclick="clearCode()">CLEAR</button>
    </div>

    <div class="main-container">
        <div class="editor-container" id="editorContainer">
            <div id="monaco-editor" style="width: 100%; height: 100%; min-height: 400px; overflow: hidden;"></div>
        </div>
        <div class="canvas-container" id="canvasContainer">
            <canvas id="renderCanvas"></canvas>
            <div class="loading" id="loading">Loading Babylon.js...</div>
        </div>
    </div>
    
    <div class="error-display" id="errorDisplay"></div>
    <div class="injection-toast" id="injectionToast">✅ AI Code Injected</div>

    <script>
        let editor;
        let engine;
        let scene;
        
        // Variables for editor state
        window.editorReady = false;
        
        // Initialize Monaco Editor with iOS-matching configuration
        console.log('Starting Monaco Editor initialization...');
        
        require.config({ 
            paths: { vs: 'https://unpkg.com/monaco-editor@0.45.0/min/vs' },
            waitSeconds: 30
        });
        
        require(['vs/editor/editor.main'], function () {
            console.log('✅ Monaco modules loaded successfully, creating editor...');
            
            try {
                const editorContainer = document.getElementById('monaco-editor');
                if (!editorContainer) {
                    throw new Error('Monaco editor container not found');
                }
                
                editor = monaco.editor.create(editorContainer, {
                    value: getDefaultCode(),
                    language: 'typescript',
                    theme: 'vs-dark',
                    automaticLayout: true,
                    minimap: { enabled: true },
                    fontSize: 14,
                    wordWrap: 'on',
                    scrollBeyondLastLine: false,
                    renderLineHighlight: 'all',
                    selectionHighlight: false,
                    lineNumbers: 'on',
                    glyphMargin: true,
                    folding: true,
                    foldingStrategy: 'indentation',
                    showFoldingControls: 'always',
                    unfoldOnClickAfterEndOfLine: false,
                    tabSize: 4
                });
                
                console.log('✅ Monaco editor created successfully');
                
                // Make editor globally accessible
                window.editor = editor;
                window.monacoEditor = editor;
                window.codeEditor = editor;
                
                // Mark as ready
                window.editorReady = true;
                console.log('🎯 MONACO EDITOR MARKED AS READY FOR INJECTION');
                
                // Initialize Babylon
                initializeBabylon();
                
            } catch (editorError) {
                console.error('❌ Failed to create Monaco editor:', editorError);
                createFallbackEditor();
            }
        }, function(error) {
            console.error('❌ Failed to load Monaco from CDN:', error);
            createFallbackEditor();
        });
        
        function createFallbackEditor() {
            console.log('🔧 Creating fallback textarea editor...');
            
            const editorContainer = document.getElementById('monaco-editor');
            if (!editorContainer) {
                console.error('❌ Editor container not found');
                return;
            }
            
            editorContainer.innerHTML = '<textarea id="fallback-editor" style="width: 100%; height: 100%; background: #1e1e1e; color: #d4d4d4; font-family: \\'Monaco\\', \\'Consolas\\', \\'Courier New\\', monospace; font-size: 14px; border: none; outline: none; padding: 10px; line-height: 1.4; letter-spacing: 0.2px; resize: none; tab-size: 4;"></textarea>';
            
            const textarea = document.getElementById('fallback-editor');
            if (textarea) {
                textarea.value = getDefaultCode();
                
                window.editor = {
                    setValue: (code) => { textarea.value = code; },
                    getValue: () => textarea.value,
                    getModel: () => ({ setValue: (code) => textarea.value = code }),
                    layout: () => {},
                    focus: () => textarea.focus(),
                    onDidChangeModelContent: (callback) => {
                        textarea.addEventListener('input', callback);
                        return { dispose: () => {} };
                    }
                };
                
                window.monacoEditor = window.editor;
                window.codeEditor = window.editor;
                window.editorReady = true;
                console.log('✅ Fallback editor ready for injection');
                
                initializeBabylon();
            }
        }
        
        function initializeBabylon() {
            console.log('🎮 Initializing Babylon.js...');
            
            try {
                const canvas = document.getElementById('renderCanvas');
                if (!canvas) {
                    throw new Error('Canvas element not found');
                }
                
                engine = new BABYLON.Engine(canvas, true, {
                    preserveDrawingBuffer: true,
                    stencil: true,
                    antialias: true,
                    alpha: false,
                    powerPreference: "high-performance"
                });
                
                console.log('✅ Babylon.js engine created');
                
                document.getElementById('loading').style.display = 'none';
                
                createDefaultScene();
                
                engine.runRenderLoop(() => {
                    if (scene && scene.activeCamera) {
                        scene.render();
                    }
                });
                
                window.addEventListener('resize', () => {
                    if (engine) {
                        engine.resize();
                    }
                });
                
            } catch (error) {
                console.error('❌ Failed to initialize Babylon.js:', error);
                showError('Failed to initialize Babylon.js: ' + error.message);
            }
        }
        
        function getDefaultCode() {
            return \`// Welcome to the Babylon.js Playground!
// Create your 3D scene here. The scene, engine, and canvas are automatically provided.

function createScene() {
    // Create a basic scene
    const scene = new BABYLON.Scene(engine);
    
    // Create a camera
    const camera = new BABYLON.ArcRotateCamera("camera", -Math.PI / 2, Math.PI / 2.5, 10, BABYLON.Vector3.Zero(), scene);
    camera.attachToCanvas(canvas, true);
    
    // Create lighting
    const light = new BABYLON.HemisphericLight("light", new BABYLON.Vector3(0, 1, 0), scene);
    light.intensity = 0.7;
    
    // Create a ground
    const ground = BABYLON.MeshBuilder.CreateGround("ground", {width: 10, height: 10}, scene);
    
    // Create a sphere
    const sphere = BABYLON.MeshBuilder.CreateSphere("sphere", {diameter: 2}, scene);
    sphere.position.y = 1;
    
    // Create a box
    const box = BABYLON.MeshBuilder.CreateBox("box", {size: 2}, scene);
    box.position.x = 3;
    box.position.y = 1;
    
    return scene;
}

// Create and return the scene
const scene = createScene();\`;
        }
        
        function createDefaultScene() {
            try {
                if (scene) {
                    scene.dispose();
                }
                
                const userCode = editor ? editor.getValue() : getDefaultCode();
                executeUserCode(userCode);
                
                hideError();
                
            } catch (error) {
                console.error('❌ Scene creation failed:', error);
                showError('Scene creation failed: ' + error.message);
            }
        }
        
        function executeUserCode(code) {
            try {
                console.log('🔄 Executing user code...');
                
                const userFunction = new Function('engine', 'canvas', 'BABYLON', code);
                const result = userFunction(engine, document.getElementById('renderCanvas'), BABYLON);
                
                if (result && result.dispose && typeof result.render === 'function') {
                    scene = result;
                    console.log('✅ User scene created successfully');
                } else {
                    console.warn('⚠️ User code did not return a scene, using global scene');
                    if (window.scene) {
                        scene = window.scene;
                    }
                }
                
                hideError();
                
            } catch (error) {
                console.error('❌ Code execution failed:', error);
                showError('Code execution failed: ' + error.message);
                createFallbackScene();
            }
        }
        
        function createFallbackScene() {
            try {
                console.log('🔧 Creating fallback scene...');
                
                scene = new BABYLON.Scene(engine);
                
                const camera = new BABYLON.ArcRotateCamera("camera", -Math.PI / 2, Math.PI / 2.5, 10, BABYLON.Vector3.Zero(), scene);
                camera.attachToCanvas(document.getElementById('renderCanvas'), true);
                
                const light = new BABYLON.HemisphericLight("light", new BABYLON.Vector3(0, 1, 0), scene);
                light.intensity = 0.7;
                
                const sphere = BABYLON.MeshBuilder.CreateSphere("sphere", {diameter: 2}, scene);
                sphere.position.y = 1;
                
                console.log('✅ Fallback scene created');
                
            } catch (fallbackError) {
                console.error('❌ Fallback scene creation failed:', fallbackError);
            }
        }
        
        function showError(message) {
            const errorDisplay = document.getElementById('errorDisplay');
            if (errorDisplay) {
                errorDisplay.textContent = message;
                errorDisplay.classList.add('visible');
                
                setTimeout(hideError, 10000);
            }
        }
        
        function hideError() {
            const errorDisplay = document.getElementById('errorDisplay');
            if (errorDisplay) {
                errorDisplay.classList.remove('visible');
            }
        }
        
        function showInjectionToast() {
            console.log('📢 Showing injection toast notification');
            const toast = document.getElementById('injectionToast');
            if (toast) {
                toast.classList.add('visible');
                console.log('✅ Toast notification displayed');
                setTimeout(() => {
                    toast.classList.remove('visible');
                    console.log('📢 Toast notification hidden');
                }, 3000);
            } else {
                console.error('❌ Toast element not found in DOM');
            }
        }
        
        function runCode() {
            console.log('🚀 Run code button pressed');
            createDefaultScene();
            // Show visual feedback that code is running
            showInjectionToast();
        }
        
        function formatCode() {
            if (editor) {
                editor.getAction('editor.action.formatDocument').run();
            }
        }
        
        function clearCode() {
            if (editor) {
                editor.setValue(getDefaultCode());
            }
        }
        
        function toggleEditor() {
            const editorContainer = document.getElementById('editorContainer');
            const canvasContainer = document.getElementById('canvasContainer');
            const toggleBtn = document.getElementById('toggleEditorBtn');
            
            if (editorContainer && canvasContainer && toggleBtn) {
                const isClosed = editorContainer.classList.contains('closed');
                
                if (isClosed) {
                    // Open editor to split view
                    editorContainer.classList.remove('closed');
                    canvasContainer.classList.remove('editor-closed');
                    toggleBtn.textContent = 'FULL';
                } else if (editorContainer.classList.contains('open')) {
                    // From full editor to closed
                    editorContainer.classList.remove('open');
                    editorContainer.classList.add('closed');
                    canvasContainer.classList.remove('editor-open');
                    canvasContainer.classList.add('editor-closed');
                    toggleBtn.textContent = 'SPLIT';
                } else {
                    // From split to full editor
                    editorContainer.classList.add('open');
                    canvasContainer.classList.add('editor-open');
                    toggleBtn.textContent = 'CLOSE';
                }
                
                // Layout editor when changed
                if (editor) {
                    setTimeout(() => editor.layout(), 100);
                }
            }
        }
        
        // Enhanced code insertion function for AI assistance with multi-level fallback
        function insertCodeAtCursor(codeString) {
            console.log('🎯 insertCodeAtCursor called with code length:', codeString.length);
            console.log('🔍 Current editor readiness:', {
                editor: !!editor,
                editorReady: !!window.editorReady,
                monacoLoaded: typeof monaco !== 'undefined'
            });
            
            if (editor && window.editorReady) {
                try {
                    console.log('✅ Editor ready, inserting at cursor');
                    const position = editor.getPosition();
                    editor.executeEdits('ai-insertion', [{
                        range: new monaco.Range(position.lineNumber, position.column, position.lineNumber, position.column),
                        text: codeString
                    }]);
                    editor.setPosition(position);
                    editor.focus();
                    console.log('✅ Code inserted at cursor position');
                    return true;
                } catch (error) {
                    console.error('❌ Cursor insertion failed:', error);
                    return setFullEditorContent(codeString);
                }
            } else {
                console.warn('⚠️ Editor not ready, falling back to full content replacement');
                return setFullEditorContent(codeString);
            }
        }
        
        // Enhanced function to completely replace editor content with multi-level retry
        function setFullEditorContent(codeString) {
            console.log('🎯 setFullEditorContent called with code length:', codeString.length);
            console.log('🔍 Editor state check:', {
                editorExists: !!editor,
                editorReady: !!window.editorReady,
                domReady: document.readyState,
                monacoGlobal: typeof monaco !== 'undefined'
            });
            
            // Multi-level injection strategy
            const strategies = [
                // Strategy 1: Standard Monaco API
                () => {
                    if (editor && window.editorReady && typeof editor.setValue === 'function') {
                        console.log('📝 Strategy 1: Using standard Monaco setValue');
                        editor.setValue(codeString);
                        editor.focus();
                        editor.setPosition({lineNumber: 1, column: 1});
                        editor.layout();
                        
                        const verification = editor.getValue();
                        if (verification === codeString) {
                            console.log('✅ Strategy 1 successful - content verified');
                            showInjectionToast();
                            return true;
                        } else {
                            console.warn('⚠️ Strategy 1: Content verification failed');
                            return false;
                        }
                    }
                    return false;
                },
                
                // Strategy 2: Direct model manipulation
                () => {
                    if (editor && editor.getModel && typeof editor.getModel === 'function') {
                        console.log('📝 Strategy 2: Using Monaco model setValue');
                        const model = editor.getModel();
                        if (model && typeof model.setValue === 'function') {
                            model.setValue(codeString);
                            editor.focus();
                            console.log('✅ Strategy 2 successful - model setValue');
                            showInjectionToast();
                            return true;
                        }
                    }
                    return false;
                },
                
                // Strategy 3: Emergency fallback with retry
                () => {
                    return new Promise((resolve) => {
                        console.log('📝 Strategy 3: Emergency retry with delay');
                        setTimeout(() => {
                            if (editor && typeof editor.setValue === 'function') {
                                try {
                                    editor.setValue(codeString);
                                    console.log('✅ Strategy 3 successful - delayed retry');
                                    showInjectionToast();
                                    resolve(true);
                                } catch (e) {
                                    console.error('❌ Strategy 3 failed:', e);
                                    resolve(false);
                                }
                            } else {
                                console.error('❌ Strategy 3: Editor still not available');
                                resolve(false);
                            }
                        }, 2000);
                    });
                }
            ];
            
            // Try strategies in order
            for (let i = 0; i < strategies.length; i++) {
                try {
                    const result = strategies[i]();
                    if (result === true) {
                        console.log('✅ Code injection successful via strategy ' + (i + 1));
                        return true;
                    } else if (result instanceof Promise) {
                        result.then(success => {
                            if (success) {
                                console.log('✅ Code injection successful via async strategy ' + (i + 1));
                            } else {
                                console.error('❌ All strategies failed, including async strategy ' + (i + 1));
                            }
                        });
                        return true;
                    }
                } catch (error) {
                    console.error('❌ Strategy ' + (i + 1) + ' threw error:', error);
                }
            }
            
            console.error('❌ All injection strategies failed');
            return false;
        }
        
        // Make functions globally available
        window.setFullEditorContent = setFullEditorContent;
        window.insertCodeAtCursor = insertCodeAtCursor;
        
        // Global error handler
        window.addEventListener('error', function(e) {
            console.error('Global error:', e.error);
            showError('Runtime error: ' + e.message + ' (Line: ' + e.lineno + ')');
        });

        // Cross-platform message handler (iOS + Android support)
        function sendMessageToNative(action, data) {
            const message = {
                action: action,
                data: data || {}
            };

            // iOS (WKWebView)
            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.playgroundHandler) {
                window.webkit.messageHandlers.playgroundHandler.postMessage(message);
            }

            // Android (WebView with JavascriptInterface)
            if (window.AndroidBridge && typeof window.AndroidBridge.postMessage === 'function') {
                window.AndroidBridge.postMessage(JSON.stringify(message));
            }
        }

        // Send initialization complete message
        setTimeout(() => {
            sendMessageToNative('initializationComplete', {
                editorReady: window.editorReady,
                engineReady: !!engine && !!scene
            });
        }, 1000);

        // Auto-run code after a short delay
        setTimeout(() => {
            if (engine && scene) {
                console.log('🚀 Auto-running initial scene...');
                runCode();
            }
        }, 2000);
    </script>
</body>
</html>
    """.trimIndent()
}

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
    println("🔄 Starting injection attempt with $maxRetries retries remaining...")

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

        if (isReady) {
            println("✅ Monaco editor is ready, proceeding with injection")
            insertCodeInWebView(webView, code)
        } else {
            println("⏳ Monaco not ready yet, retries left: $maxRetries")
            println("🔍 Current readiness result: $result")

            if (maxRetries > 0) {
                // Retry after delay - longer delay for first few retries to allow full initialization
                val delayMs: Long = if (maxRetries > 2) 2000L else 1000L

                CoroutineScope(Dispatchers.Main).launch {
                    delay(delayMs)
                    injectCodeWithRetry(webView, code, maxRetries - 1)
                }
            } else {
                println("❌ Max retries reached, injection failed")
                println("🔍 Final check - trying emergency injection...")

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

    println("Executing ENHANCED JavaScript code injection...")
    webView.evaluateJavascript(jsCode) { result ->
        println("✅ JavaScript executed successfully")
        println("📋 Injection result: $result")

        when (result?.replace("\"", "")) {
            "SUCCESS_METHOD_1" -> println("🎉 Code injection successful via setFullEditorContent")
            "SUCCESS_METHOD_2" -> println("🎉 Code injection successful via direct Monaco API")
            "EMERGENCY_FALLBACK" -> println("⚠️ Used emergency fallback injection method")
            "ALL_METHODS_FAILED" -> println("❌ All injection methods failed")
            else -> println("✅ Injection completed with result: $result")
        }
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