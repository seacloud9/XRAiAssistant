import Foundation
import WebKit

// MARK: - WASM Build Service

public class WasmBuildService: NSObject, BuildService {
    private var webView: WKWebView?
    private var isInitialized = false
    private var pendingBuildContinuation: CheckedContinuation<BuildResult, Never>?
    
    public override init() {
        super.init()
        print("🌐 WasmBuildService initializing...")
        setupWebView()
    }
    
    public func isNodeAvailable() -> Bool {
        return false // WASM service doesn't use Node
    }
    
    public func build(_ request: BuildRequest) async -> BuildResult {
        // Wait for initialization if not ready yet
        if !isInitialized {
            print("⏳ WasmBuildService not ready, waiting for initialization...")
            await waitForInitialization()
        }
        
        guard isInitialized else {
            print("❌ WasmBuildService initialization timeout")
            return BuildResult(
                success: false,
                errors: ["Build service initialization timeout"]
            )
        }
        
        let startTime = Date()
        
        return await withCheckedContinuation { continuation in
            pendingBuildContinuation = continuation
            
            let buildMessage = createBuildMessage(from: request)
            let jsCode = "window.buildWithEsbuild(\(buildMessage)); undefined;"
            
            // Add timeout to prevent hanging
            DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
                if let pendingContinuation = self.pendingBuildContinuation {
                    print("⏰ Build timeout after 30 seconds")
                    let timeoutResult = BuildResult(
                        success: false,
                        errors: ["Build timeout - no response from JavaScript"],
                        durationMs: Int(Date().timeIntervalSince(startTime) * 1000)
                    )
                    pendingContinuation.resume(returning: timeoutResult)
                    self.pendingBuildContinuation = nil
                }
            }
            
            DispatchQueue.main.async {
                self.webView?.evaluateJavaScript(jsCode) { result, error in
                    if let error = error {
                        print("❌ Build execution error: \(error)")
                        let buildResult = BuildResult(
                            success: false,
                            errors: ["Build execution failed: \(error.localizedDescription)"],
                            durationMs: Int(Date().timeIntervalSince(startTime) * 1000)
                        )
                        // Only resume if we still have a pending continuation
                        if let pendingContinuation = self.pendingBuildContinuation {
                            pendingContinuation.resume(returning: buildResult)
                            self.pendingBuildContinuation = nil
                        }
                    }
                    // Success case is handled by the message handler
                }
            }
        }
    }
    
    private func waitForInitialization() async {
        // Wait up to 15 seconds for initialization (esbuild can be slow to load)
        for _ in 0..<75 { // 75 * 200ms = 15 seconds
            if isInitialized {
                return
            }
            try? await Task.sleep(nanoseconds: 200_000_000) // 200ms
        }
        print("⚠️ WasmBuildService initialization timeout after 15 seconds")
    }
    
    private func setupWebView() {
        DispatchQueue.main.async {
            let config = WKWebViewConfiguration()
            config.userContentController.add(self, name: "buildResult")
            
            self.webView = WKWebView(frame: .zero, configuration: config)
            self.loadBuildEnvironment()
        }
    }
    
    private func loadBuildEnvironment() {
        guard let webView = webView else { return }
        
        let html = createBuildEnvironmentHTML()
        webView.loadHTMLString(html, baseURL: nil)
        
        // Poll for initialization more frequently
        checkInitializationStatus()
    }
    
    private func checkInitializationStatus() {
        guard let webView = webView, !isInitialized else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Check if build function is available (even without esbuild)
            webView.evaluateJavaScript("typeof window.buildWithEsbuild === 'function'") { result, error in
                if let result = result as? Bool, result {
                    // Check if esbuild is ready or if we should use fallback
                    webView.evaluateJavaScript("window.esbuildReady === true") { esbuildResult, _ in
                        let esbuildReady = esbuildResult as? Bool ?? false
                        if esbuildReady {
                            self.isInitialized = true
                            print("✅ WasmBuildService initialized with esbuild")
                        } else {
                            // Check for errors but still allow fallback
                            webView.evaluateJavaScript("window.esbuildError") { errorResult, _ in
                                if let errorMessage = errorResult as? String {
                                    print("⚠️ esbuild failed but fallback available: \(errorMessage)")
                                    self.isInitialized = true // Allow fallback to work
                                } else if !self.isInitialized {
                                    // Still loading, try again
                                    self.checkInitializationStatus()
                                }
                            }
                        }
                    }
                } else {
                    // Build function not available yet, try again
                    if !self.isInitialized {
                        self.checkInitializationStatus()
                    }
                }
            }
        }
    }
    
    private func createBuildEnvironmentHTML() -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <title>Build Environment</title>
        </head>
        <body>
            <script>
                console.log('🚀 Build environment starting...');
                let esbuild = null;
                
                // Try to load esbuild from multiple sources with timeout
                async function loadEsbuildWithFallback() {
                    const sources = [
                        {
                            script: 'https://unpkg.com/esbuild-wasm@0.19.11/lib/browser.js',
                            wasm: 'https://unpkg.com/esbuild-wasm@0.19.11/esbuild.wasm'
                        },
                        {
                            script: 'https://cdn.jsdelivr.net/npm/esbuild-wasm@0.19.11/lib/browser.js',
                            wasm: 'https://cdn.jsdelivr.net/npm/esbuild-wasm@0.19.11/esbuild.wasm'
                        }
                    ];
                    
                    for (const source of sources) {
                        try {
                            console.log(`🔧 Trying to load esbuild from: ${source.script}`);
                            
                            // Load script with timeout
                            await loadScriptWithTimeout(source.script, 5000);
                            
                            // Initialize esbuild
                            await esbuild_wasm.initialize({
                                wasmURL: source.wasm
                            });
                            
                            esbuild = esbuild_wasm;
                            console.log('✅ esbuild-wasm initialized successfully');
                            window.esbuildReady = true;
                            return true;
                            
                        } catch (error) {
                            console.warn(`❌ Failed to load from ${source.script}:`, error);
                            continue;
                        }
                    }
                    
                    // All sources failed
                    const errorMsg = 'All esbuild sources failed to load. Network may be restricted.';
                    console.error('❌', errorMsg);
                    window.esbuildError = errorMsg;
                    return false;
                }
                
                function loadScriptWithTimeout(src, timeout = 5000) {
                    return new Promise((resolve, reject) => {
                        const script = document.createElement('script');
                        script.src = src;
                        
                        const timer = setTimeout(() => {
                            script.remove();
                            reject(new Error(`Script loading timeout: ${src}`));
                        }, timeout);
                        
                        script.onload = () => {
                            clearTimeout(timer);
                            resolve();
                        };
                        
                        script.onerror = () => {
                            clearTimeout(timer);
                            script.remove();
                            reject(new Error(`Script loading failed: ${src}`));
                        };
                        
                        document.head.appendChild(script);
                    });
                }
                
                // Start initialization
                loadEsbuildWithFallback();
                
                // Build function
                window.buildWithEsbuild = async (buildRequest) => {
                    const startTime = Date.now();
                    
                    try {
                        if (!esbuild) {
                            console.warn('⚠️ esbuild-wasm not available, using fallback transformation');
                            return await fallbackBuild(buildRequest);
                        }
                        
                        const { framework, entryCode, extraFiles, jsxRuntime, defines, minify } = buildRequest;
                        
                        // Create virtual file system
                        const entryPath = framework === 'reactThreeFiber' || framework === 'reactylon' 
                            ? '/src/index.tsx' : '/src/index.js';
                        
                        const files = {
                            [entryPath]: entryCode,
                            ...extraFiles
                        };
                        
                        // Configure esbuild options
                        const buildOptions = {
                            stdin: {
                                contents: entryCode,
                                loader: framework === 'reactThreeFiber' || framework === 'reactylon' ? 'tsx' : 'js'
                            },
                            bundle: true,
                            platform: 'browser',
                            format: 'iife',
                            globalName: 'App',
                            jsx: jsxRuntime || 'automatic',
                            target: 'es2020',
                            minify: minify || false,
                            sourcemap: 'inline',
                            write: false,
                            define: {
                                'process.env.NODE_ENV': '"production"',
                                ...defines
                            },
                            external: [],
                            alias: {
                                'react': 'app://vendor/react.production.min.js',
                                'react-dom': 'app://vendor/react-dom.production.min.js',
                                'react-dom/client': 'app://vendor/react-dom.production.min.js',
                                'three': 'app://vendor/three.module.js',
                                '@react-three/fiber': 'app://vendor/react-three-fiber.js',
                                '@react-three/drei': 'app://vendor/drei.js'
                            }
                        };
                        
                        // Perform build
                        const result = await esbuild.build(buildOptions);
                        
                        const durationMs = Date.now() - startTime;
                        const bundleCode = result.outputFiles?.[0]?.text || '';
                        const bytes = new TextEncoder().encode(bundleCode).length;
                        
                        const buildResult = {
                            success: true,
                            bundleCode: bundleCode,
                            warnings: result.warnings?.map(w => w.text) || [],
                            errors: result.errors?.map(e => e.text) || [],
                            bytes: bytes,
                            durationMs: durationMs
                        };
                        
                        // Send result back to Swift
                        webkit.messageHandlers.buildResult.postMessage(buildResult);
                        
                    } catch (error) {
                        console.error('Build error:', error);
                        
                        const buildResult = {
                            success: false,
                            bundleCode: null,
                            warnings: [],
                            errors: [error.message || 'Unknown build error'],
                            bytes: 0,
                            durationMs: Date.now() - startTime
                        };
                        
                        webkit.messageHandlers.buildResult.postMessage(buildResult);
                    }
                };
                
                // Fallback build function for when esbuild is not available
                async function fallbackBuild(buildRequest) {
                    const startTime = Date.now();
                    
                    try {
                        const { framework, entryCode } = buildRequest;
                        
                        // Simple fallback: wrap the code in an IIFE and return as-is
                        // This won't do full bundling but allows basic execution
                        let transformedCode = entryCode;
                        
                        // For React Three Fiber, add minimal transformations
                        if (framework === 'reactThreeFiber' || framework === 'reactylon') {
                            // Basic JSX-like transformation (very simple)
                            transformedCode = transformedCode
                                .replace(/import\\s+.*?from\\s+['"][^'"]*['"];?\\s*/g, '') // Remove imports
                                .replace(/export\\s+default\\s+/g, '') // Remove export default
                                .replace(/export\\s+/g, ''); // Remove exports
                            
                            // Wrap in IIFE with globals
                            transformedCode = `
                                (function() {
                                    // Make React globals available
                                    const React = window.React;
                                    const { createRoot } = window.ReactDOM;
                                    const { Canvas, useFrame } = window.ReactThreeFiber;
                                    const { OrbitControls } = window.Drei;
                                    const THREE = window.THREE;
                                    
                                    try {
                                        ${transformedCode}
                                    } catch (error) {
                                        console.error('Fallback execution error:', error);
                                    }
                                })();
                            `;
                        }
                        
                        const durationMs = Date.now() - startTime;
                        const bytes = new TextEncoder().encode(transformedCode).length;
                        
                        const buildResult = {
                            success: true,
                            bundleCode: transformedCode,
                            warnings: ['Using fallback build - limited functionality'],
                            errors: [],
                            bytes: bytes,
                            durationMs: durationMs
                        };
                        
                        webkit.messageHandlers.buildResult.postMessage(buildResult);
                        
                    } catch (error) {
                        console.error('Fallback build error:', error);
                        
                        const buildResult = {
                            success: false,
                            bundleCode: null,
                            warnings: [],
                            errors: ['Fallback build failed: ' + (error.message || 'Unknown error')],
                            bytes: 0,
                            durationMs: Date.now() - startTime
                        };
                        
                        webkit.messageHandlers.buildResult.postMessage(buildResult);
                    }
                }
                
                console.log('Build environment setup complete');
            </script>
        </body>
        </html>
        """
    }
    
    private func createBuildMessage(from request: BuildRequest) -> String {
        let encoder = JSONEncoder()
        
        let buildData: [String: Any] = [
            "framework": request.framework.rawValue,
            "entryCode": request.entryCode,
            "extraFiles": request.extraFiles,
            "jsxRuntime": request.jsxRuntime ?? "automatic",
            "defines": request.defines,
            "minify": request.minify
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: buildData)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
            return jsonString
        } catch {
            print("❌ Failed to encode build request: \(error)")
            return "{}"
        }
    }
}

// MARK: - WKScriptMessageHandler

extension WasmBuildService: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "buildResult",
              let resultData = message.body as? [String: Any] else {
            print("❌ Invalid build result message")
            return
        }
        
        let buildResult = parseBuildResult(from: resultData)
        
        if let continuation = pendingBuildContinuation {
            continuation.resume(returning: buildResult)
            pendingBuildContinuation = nil
        } else {
            print("⚠️ Received build result but no pending continuation")
        }
    }
    
    private func parseBuildResult(from data: [String: Any]) -> BuildResult {
        let success = data["success"] as? Bool ?? false
        let bundleCode = data["bundleCode"] as? String
        let warnings = data["warnings"] as? [String] ?? []
        let errors = data["errors"] as? [String] ?? []
        let bytes = data["bytes"] as? Int ?? 0
        let durationMs = data["durationMs"] as? Int ?? 0
        
        return BuildResult(
            success: success,
            bundleCode: bundleCode,
            warnings: warnings,
            errors: errors,
            bytes: bytes,
            durationMs: durationMs
        )
    }
}