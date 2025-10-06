import WebKit
import Foundation
import SwiftUI

class CodeSandboxWebViewCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    var parent: CodeSandboxWebView

    init(parent: CodeSandboxWebView) {
        self.parent = parent
        super.init()
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Allow navigation to CodeSandbox Define API
        if let url = navigationAction.request.url {
            print("🌐 CodeSandbox WebView - Navigation request to: \(url.absoluteString)")

            if url.absoluteString.contains("codesandbox.io") {
                print("✅ CodeSandbox WebView - Allowing navigation to CodeSandbox")
                decisionHandler(.allow)
                return
            }
        }

        // Allow form submissions and local content
        if navigationAction.navigationType == .formSubmitted || navigationAction.navigationType == .other {
            print("✅ CodeSandbox WebView - Allowing form submission or local content")
            decisionHandler(.allow)
        } else {
            print("🔍 CodeSandbox WebView - Navigation type: \(navigationAction.navigationType.rawValue)")
            decisionHandler(.allow) // Allow all for now
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("✅ CodeSandbox WebView - Navigation finished")
        parent.onWebViewLoaded?()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("❌ CodeSandbox WebView - Navigation failed: \(error)")
        parent.onWebViewError?(error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("❌ CodeSandbox WebView - Provisional navigation failed: \(error)")
        parent.onWebViewError?(error)
    }

    // MARK: - WKScriptMessageHandler

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "codeSandboxDebug" {
            print("📱 CodeSandbox WebView - JavaScript message: \(message.body)")
        }
    }
}

struct CodeSandboxWebView: UIViewRepresentable {
    @Binding var webView: WKWebView?
    var framework: String = "react-three-fiber"
    var onWebViewLoaded: (() -> Void)?
    var onWebViewError: ((Error) -> Void)?
    var onSandboxCreated: ((String) -> Void)?

    @State private var currentSandboxURL: String?
    @State private var isCreatingSandbox = false

    func makeCoordinator() -> CodeSandboxWebViewCoordinator {
        CodeSandboxWebViewCoordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()

        // Enable debugging
        configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")

        // Enable JavaScript
        if #available(iOS 14.0, *) {
            configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            configuration.preferences.javaScriptEnabled = true
        }

        // Add message handler for debugging
        configuration.userContentController.add(context.coordinator, name: "codeSandboxDebug")

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false

        print("🌐 CodeSandbox WebView - Created with configuration")

        // Load initial placeholder
        loadPlaceholder(webView: webView)

        DispatchQueue.main.async {
            self.webView = webView
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Updates handled by external injection methods
    }

    // MARK: - Public API

    func createAndLoadSandbox(code: String) {
        guard let webView = webView, !isCreatingSandbox else {
            print("⚠️ CodeSandbox WebView - Cannot create sandbox: WebView not ready or already creating")
            return
        }

        isCreatingSandbox = true
        print("🚀 CodeSandbox WebView - Creating secure sandbox for framework: \(framework)")

        // Use secure template-based approach (bypasses CORS issues)
        let sandboxURL = SecureCodeSandboxService.shared.createTemplateBasedSandbox(
            code: code,
            framework: framework
        )

        DispatchQueue.main.async {
            print("🛡️ CodeSandbox WebView - Using secure Define API approach")
            self.currentSandboxURL = "about:blank" // Placeholder since we're using HTML content
            self.loadSandboxHTML(webView: webView, html: sandboxURL) // sandboxURL is actually HTML now
            self.onSandboxCreated?("CodeSandbox Define API") // Placeholder URL
            self.isCreatingSandbox = false
        }
    }

    func isReady() -> Bool {
        return webView != nil && !isCreatingSandbox
    }

    func getCurrentCode() -> String {
        // For CodeSandbox, we don't track code locally - it's in the sandbox
        return ""
    }

    // MARK: - Private Methods

    private func loadPlaceholder(webView: WKWebView) {
        let placeholderHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>XRAiAssistant - CodeSandbox</title>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }

                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    color: white;
                    height: 100vh;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    text-align: center;
                }

                .container {
                    max-width: 400px;
                    padding: 40px 20px;
                }

                .logo {
                    font-size: 48px;
                    margin-bottom: 20px;
                }

                .title {
                    font-size: 24px;
                    font-weight: 600;
                    margin-bottom: 16px;
                }

                .description {
                    font-size: 16px;
                    opacity: 0.9;
                    line-height: 1.5;
                    margin-bottom: 32px;
                }

                .status {
                    display: inline-block;
                    background: rgba(255, 255, 255, 0.2);
                    padding: 8px 16px;
                    border-radius: 20px;
                    font-size: 14px;
                    font-weight: 500;
                }

                .loading {
                    display: inline-block;
                    width: 20px;
                    height: 20px;
                    border: 2px solid rgba(255, 255, 255, 0.3);
                    border-radius: 50%;
                    border-top-color: white;
                    animation: spin 1s ease-in-out infinite;
                    margin-right: 8px;
                    vertical-align: middle;
                }

                @keyframes spin {
                    to { transform: rotate(360deg); }
                }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="logo">🎨</div>
                <div class="title">XRAiAssistant CodeSandbox</div>
                <div class="description">
                    Ready to create live \(framework == "reactThreeFiber" ? "React Three Fiber" : "Reactylon") sandboxes.<br>
                    Generate AI code to see it running in a real development environment!
                </div>
                <div class="status">
                    <span class="loading"></span>
                    Waiting for AI code...
                </div>
            </div>
        </body>
        </html>
        """

        webView.loadHTMLString(placeholderHTML, baseURL: Bundle.main.bundleURL)
    }

    private func loadSandbox(webView: WKWebView, url: String) {
        guard let sandboxURL = URL(string: url) else {
            print("❌ CodeSandbox WebView - Invalid sandbox URL: \(url)")
            return
        }

        print("🌐 CodeSandbox WebView - Loading sandbox: \(url)")
        webView.load(URLRequest(url: sandboxURL))
    }

    private func loadSandboxHTML(webView: WKWebView, html: String) {
        print("🌐 CodeSandbox WebView - Loading HTML form for Define API")
        // Use nil baseURL to avoid navigation conflicts and enable form submission
        webView.loadHTMLString(html, baseURL: nil)
    }
}

// MARK: - API Compatibility Layer

extension CodeSandboxWebView {
    // Compatibility methods for existing injection system
    func setFullEditorContent(_ code: String) async -> Bool {
        createAndLoadSandbox(code: code)
        return true
    }

    func executeJavaScript(_ script: String) async -> String? {
        // For CodeSandbox approach, we don't execute arbitrary JavaScript
        // Instead, we create new sandboxes with updated code
        return nil
    }
}