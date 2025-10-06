import WebKit
import Foundation
import SwiftUI

class SandpackWebViewCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    var parent: SandpackWebView

    init(parent: SandpackWebView) {
        self.parent = parent
        super.init()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("🔧 SANDPACK WEBVIEW - Navigation finished, page loaded")
        parent.onWebViewLoaded?()

        // Test JavaScript execution after page loads
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            webView.evaluateJavaScript("console.log('🧪 TEST - JavaScript execution test from Swift'); 'JS_WORKING'") { result, error in
                if error != nil {
                    print("❌ SANDPACK WEBVIEW - JavaScript test failed: \(String(describing: error))")
                } else {
                    print("✅ SANDPACK WEBVIEW - JavaScript test result: \(String(describing: result))")
                }
            }

            // Test our API functions after longer delay to allow initialization
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                webView.evaluateJavaScript("window.isReady()") { result, error in
                    if error != nil {
                        print("❌ SANDPACK WEBVIEW - isReady test failed: \(String(describing: error))")
                    } else {
                        print("🔍 SANDPACK WEBVIEW - isReady result: \(String(describing: result))")

                        // If ready, test setting some code
                        if let resultValue = result as? NSNumber, resultValue.intValue == 1 {
                            print("✅ SANDPACK WEBVIEW - Ready! Testing code injection...")
                            webView.evaluateJavaScript("window.setFullEditorContent('// Test code from Swift\\nconsole.log(\"Hello from Swift!\");')") { setResult, setError in
                                if setError != nil {
                                    print("❌ SANDPACK WEBVIEW - setFullEditorContent test failed: \(String(describing: setError))")
                                } else {
                                    print("🎉 SANDPACK WEBVIEW - setFullEditorContent test result: \(String(describing: setResult))")
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        parent.onWebViewError?(error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        parent.onWebViewError?(error)
    }

    // Handle messages from JavaScript
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let messageBody = message.body as? [String: Any],
              let action = messageBody["action"] as? String else {
            return
        }

        let data = messageBody["data"] as? [String: Any] ?? [:]

        DispatchQueue.main.async {
            self.parent.handleJavaScriptMessage(action: action, data: data)
        }
    }
}

struct SandpackWebView: UIViewRepresentable {
    @Binding var webView: WKWebView?
    var framework: String = "react-three-fiber"
    var onWebViewLoaded: (() -> Void)?
    var onWebViewError: ((Error) -> Void)?
    var onJavaScriptMessage: ((String, [String: Any]) -> Void)?
    var onSandboxCreated: ((String) -> Void)?

    func makeCoordinator() -> SandpackWebViewCoordinator {
        SandpackWebViewCoordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()

        // Configure message handler
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "sandpackHandler")
        configuration.userContentController = contentController

        // Enable debugging
        configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")

        // Enable JavaScript for iOS 14+ (preferred method)
        if #available(iOS 14.0, *) {
            configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            // Fallback for older iOS versions
            configuration.preferences.javaScriptEnabled = true
        }

        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true

        // Allow arbitrary loads
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = false

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false

        // Debug logging to see if WebView loads
        print("🔧 SANDPACK WEBVIEW - Creating WebView with configuration")
        if #available(iOS 14.0, *) {
            print("🔧 SANDPACK WEBVIEW - JavaScript enabled: \(configuration.defaultWebpagePreferences.allowsContentJavaScript)")
        } else {
            print("🔧 SANDPACK WEBVIEW - JavaScript enabled: \(configuration.preferences.javaScriptEnabled)")
        }

        // Load Sandpack HTML directly with logging
        let sandpackHTML = generateSandpackHTML()
        print("🔧 SANDPACK WEBVIEW - Generated HTML length: \(sandpackHTML.count)")
        print("🔧 SANDPACK WEBVIEW - Loading HTML content...")

        webView.loadHTMLString(sandpackHTML, baseURL: Bundle.main.bundleURL)

        DispatchQueue.main.async {
            self.webView = webView
            print("🔧 SANDPACK WEBVIEW - WebView assigned to binding")
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No updates needed for now
    }

    func handleJavaScriptMessage(action: String, data: [String: Any]) {
        onJavaScriptMessage?(action, data)

        // Handle Sandpack-specific messages
        switch action {
        case "jsLog":
            if let message = data["message"] as? String,
               let level = data["level"] as? String {
                let prefix = level == "error" ? "❌" : level == "warn" ? "⚠️" : "📝"
                print("\(prefix) JS→SWIFT: \(message)")
            }
        case "scriptLoaded":
            print("🎉 SANDPACK WEBVIEW - JavaScript script loaded successfully!")
            if let timestamp = data["timestamp"] as? Double {
                print("🕒 SANDPACK WEBVIEW - Script loaded at: \(Date(timeIntervalSince1970: timestamp / 1000))")
            }
        case "sandboxCreated":
            if let url = data["url"] as? String {
                onSandboxCreated?(url)
            }
        case "codeChanged":
            // Forward to parent
            onJavaScriptMessage?(action, data)
        default:
            print("🔍 SANDPACK WEBVIEW - Received unknown message: \(action)")
            break
        }
    }

    private func generateSandpackHTML() -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <title>XRAiAssistant Sandpack</title>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }

                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    background: #1e1e1e;
                    color: white;
                    height: 100vh;
                    overflow: hidden;
                }

                .header {
                    background: #2d2d2d;
                    padding: 12px 16px;
                    border-bottom: 1px solid #404040;
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                }

                .title {
                    font-size: 16px;
                    font-weight: 600;
                    color: #fff;
                }

                .badge {
                    background: #6366f1;
                    color: white;
                    padding: 4px 8px;
                    border-radius: 4px;
                    font-size: 12px;
                    font-weight: 600;
                }

                .sandpack-container {
                    height: calc(100vh - 60px);
                    display: flex;
                }

                .sandpack-editor, .sandpack-preview {
                    flex: 1;
                    height: 100%;
                }

                .sandpack-editor {
                    border-right: 1px solid #404040;
                }

                .status-indicator {
                    position: absolute;
                    top: 10px;
                    right: 10px;
                    background: #10b981;
                    color: white;
                    padding: 4px 8px;
                    border-radius: 4px;
                    font-size: 11px;
                    font-weight: 600;
                    z-index: 1000;
                }

                .loading {
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    height: 100%;
                    background: #1e1e1e;
                    color: #9ca3af;
                }
            </style>
        </head>
        <body>
            <div class="header">
                <div class="title">XRAiAssistant Sandpack</div>
                <span class="badge">React Three Fiber</span>
                <div class="status-indicator" id="status">Initializing...</div>
            </div>

            <div class="sandpack-container">
                <div class="sandpack-editor">
                    <div class="loading" id="editor-loading">Loading Code Editor...</div>
                    <textarea id="code-editor" style="display: none; width: 100%; height: 100%; border: none; background: #1e1e1e; color: #e5e7eb; font-family: 'Monaco', 'Menlo', monospace; font-size: 14px; padding: 16px; resize: none; outline: none;" placeholder="AI-generated React Three Fiber code will appear here..."></textarea>
                </div>

                <div class="sandpack-preview">
                    <div class="loading" id="preview-loading">Loading Preview...</div>
                    <iframe id="sandpack-preview" style="display: none; width: 100%; height: 100%; border: none;"></iframe>
                </div>
            </div>

            <script>
                console.log('🚀 MINIMAL SANDPACK - Script started');

                // CRITICAL: Define API functions IMMEDIATELY before anything else
                window.isReady = function() {
                    console.log('🔍 isReady called - checking readiness...');
                    return window._sandpackReady ? 1 : 0;
                };

                window.setFullEditorContent = function(code) {
                    console.log('📝 setFullEditorContent called with code length:', code ? code.length : 0);
                    if (code) {
                        window._currentCode = code;
                        if (window._editor) {
                            window._editor.value = code;
                            console.log('✅ Code updated in editor');
                        } else {
                            console.log('⏳ Editor not ready, code stored for later');
                        }
                        return true;
                    }
                    return false;
                };

                window.getCode = function() {
                    const code = window._currentCode || '';
                    console.log('📖 getCode called, returning length:', code.length);
                    return code;
                };

                // Global state - using window properties for better access
                window._sandpackReady = false;
                window._currentCode = '';
                window._editor = null;
                window._preview = null;

                console.log('✅ CRITICAL: API functions defined on window object');

                // IMMEDIATE TEST: Verify the functions work
                try {
                    const testReady = window.isReady();
                    console.log('🧪 IMMEDIATE TEST: window.isReady() =', testReady);

                    const testSet = window.setFullEditorContent('// Test code');
                    console.log('🧪 IMMEDIATE TEST: window.setFullEditorContent() =', testSet);

                    const testGet = window.getCode();
                    console.log('🧪 IMMEDIATE TEST: window.getCode() length =', testGet.length);

                    console.log('🎉 ALL API FUNCTIONS WORK IMMEDIATELY!');
                } catch (testError) {
                    console.error('❌ IMMEDIATE TEST FAILED:', testError.message);
                }

                // Default React Three Fiber template
                const defaultCode = `import React, { useRef } from 'react'
                import { Canvas, useFrame } from '@react-three/fiber'
                import { OrbitControls } from '@react-three/drei'

                function Box(props) {
                  const meshRef = useRef()

                  useFrame((state, delta) => {
                    if (meshRef.current) {
                      meshRef.current.rotation.x += delta
                      meshRef.current.rotation.y += delta * 0.5
                    }
                  })

                  return (
                    <mesh {...props} ref={meshRef}>
                      <boxGeometry args={[1, 1, 1]} />
                      <meshStandardMaterial color="orange" />
                    </mesh>
                  )
                }

                export default function App() {
                  return (
                    <Canvas camera={{ position: [0, 0, 5] }}>
                      <ambientLight intensity={0.5} />
                      <spotLight position={[10, 10, 10]} angle={0.15} penumbra={1} />
                      <pointLight position={[-10, -10, -10]} />
                      <Box position={[0, 0, 0]} />
                      <OrbitControls />
                    </Canvas>
                  )
                }`;

                // Set initial code immediately in window property
                window._currentCode = defaultCode;

                console.log('✅ Initial code set in window._currentCode');

                // Send message to iOS
                function notifyiOS(action, data) {
                    try {
                        if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.sandpackHandler) {
                            window.webkit.messageHandlers.sandpackHandler.postMessage({
                                action: action,
                                data: data || {}
                            });
                            console.log('📱 Sent to iOS:', action);
                            return true;
                        }
                    } catch (error) {
                        console.log('❌ Error sending to iOS:', error.message);
                    }
                    return false;
                }

                // Notify iOS that script loaded
                notifyiOS('scriptLoaded', { timestamp: Date.now() });

                function updateStatus(message, color = '#10b981') {
                    const status = document.getElementById('status');
                    if (status) {
                        status.textContent = message;
                        status.style.background = color;
                    }
                    console.log('📊 STATUS:', message);
                }

                function hideLoading(type) {
                    const loading = document.getElementById(type + '-loading');
                    const content = document.getElementById('sandpack-' + type);
                    if (loading && content) {
                        loading.style.display = 'none';
                        content.style.display = 'block';
                    }
                }

                function generatePreviewHTML(code) {
                    return `<!DOCTYPE html>
                <html>
                <head>
                    <meta charset="utf-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1">
                    <title>React Three Fiber Scene</title>
                    <script src="https://unpkg.com/react@18/umd/react.development.js"></script>
                    <script src="https://unpkg.com/react-dom@18/umd/react-dom.development.js"></script>
                    <script src="https://unpkg.com/three@0.171.0/build/three.min.js"></script>
                    <script src="https://unpkg.com/@react-three/fiber@8/dist/react-three-fiber.umd.js"></script>
                    <script src="https://unpkg.com/@react-three/drei@9/dist/react-three-drei.umd.js"></script>
                    <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
                    <style>
                        body { margin: 0; padding: 0; background: #000; overflow: hidden; }
                        #root { width: 100vw; height: 100vh; }
                        .error { color: red; padding: 20px; font-family: monospace; background: #1a1a1a; }
                    </style>
                </head>
                <body>
                    <div id="root"></div>
                    <script type="text/babel">
                        try {
                            const { Canvas, useFrame } = window.ReactThreeFiber;
                            const { OrbitControls } = window.ReactThreeDrei;

                            ${code}

                            const root = ReactDOM.createRoot(document.getElementById('root'));
                            root.render(React.createElement(App));
                        } catch (error) {
                            document.getElementById('root').innerHTML =
                                '<div class="error">Error: ' + error.message + '</div>';
                            console.error('Preview error:', error);
                        }
                    </script>
                </body>
                </html>`;
                }

                function updatePreview() {
                    if (!preview) return;

                    try {
                        const previewHTML = generatePreviewHTML(currentCode);
                        const blob = new Blob([previewHTML], { type: 'text/html' });
                        const url = URL.createObjectURL(blob);
                        preview.src = url;

                        // Clean up previous URL
                        setTimeout(() => URL.revokeObjectURL(url), 5000);

                        updateStatus('Preview updated', '#10b981');
                    } catch (error) {
                        console.error('❌ SANDPACK LITE - Preview update failed:', error);
                        updateStatus('Preview failed', '#ef4444');
                    }
                }

                function initializeEditor() {
                    console.log('🔧 Starting minimal initialization');
                    notifyiOS('jsLog', { message: '🔧 Starting initialization', level: 'info' });

                    try {
                        updateStatus('Starting...', '#f59e0b');

                        // Find elements and store in window properties
                        window._editor = document.getElementById('code-editor');
                        window._preview = document.getElementById('sandpack-preview');

                        console.log('🔍 Elements found - Editor:', !!window._editor, 'Preview:', !!window._preview);
                        notifyiOS('jsLog', { message: 'Elements found - Editor: ' + !!window._editor + ', Preview: ' + !!window._preview, level: 'info' });

                        if (!window._editor || !window._preview) {
                            console.error('❌ Missing elements');
                            updateStatus('Missing elements', '#ef4444');
                            return;
                        }

                        // Set initial code in editor from window property
                        window._editor.value = window._currentCode;
                        console.log('✅ Initial code set in editor');

                        // Simple change listener - update window property
                        window._editor.addEventListener('input', (e) => {
                            window._currentCode = e.target.value;
                            console.log('📝 Code updated in window._currentCode');
                        });

                        // Hide loading screens
                        hideLoading('editor');
                        hideLoading('preview');

                        // Mark as ready - the API functions are now fully functional
                        window._sandpackReady = true;

                        updateStatus('Ready', '#10b981');
                        console.log('🎉 INITIALIZATION COMPLETE! _sandpackReady:', window._sandpackReady);
                        notifyiOS('jsLog', { message: '🎉 Sandpack fully ready!', level: 'info' });

                    } catch (error) {
                        console.error('❌ Initialization failed:', error.message);
                        notifyiOS('jsLog', { message: 'Initialization failed: ' + error.message, level: 'error' });
                        updateStatus('Failed', '#ef4444');
                    }
                }

                // Initialization will be triggered by DOM ready events below

                // Force immediate initialization
                function forceInit() {
                    console.log('🚀 SANDPACK LITE - Force initialization attempt');
                    console.log('🚀 SANDPACK LITE - Document ready state:', document.readyState);
                    console.log('🚀 SANDPACK LITE - Body present:', !!document.body);

                    initializeEditor();
                }

                // Multiple initialization strategies
                console.log('📚 SANDPACK LITE - Setting up initialization strategies...');

                // Strategy 1: Immediate if ready
                if (document.readyState === 'complete') {
                    console.log('📚 SANDPACK LITE - Document complete, initializing immediately');
                    setTimeout(forceInit, 50);
                } else if (document.readyState === 'interactive') {
                    console.log('📚 SANDPACK LITE - Document interactive, initializing with delay');
                    setTimeout(forceInit, 100);
                } else {
                    console.log('📚 SANDPACK LITE - Document loading, waiting for DOMContentLoaded');
                }

                // Strategy 2: DOMContentLoaded
                document.addEventListener('DOMContentLoaded', () => {
                    console.log('📚 SANDPACK LITE - DOMContentLoaded fired');
                    setTimeout(forceInit, 50);
                });

                // Strategy 3: Window load
                window.addEventListener('load', () => {
                    console.log('📚 SANDPACK LITE - Window load fired');
                    if (!window._sandpackReady) {
                        console.log('📚 SANDPACK LITE - Not ready yet, trying again');
                        setTimeout(forceInit, 50);
                    }
                });

                // Strategy 4: Fallback timer
                setTimeout(() => {
                    if (!window._sandpackReady) {
                        console.log('📚 SANDPACK LITE - Fallback initialization attempt');
                        forceInit();
                    }
                }, 500);

                console.log('🎯 SANDPACK LITE - Script setup complete');
            </script>
        </body>
        </html>
        """
    }
}