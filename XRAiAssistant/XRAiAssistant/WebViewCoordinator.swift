import WebKit
import Foundation
import SwiftUI

class WebViewCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    var parent: PlaygroundWebView
    
    init(parent: PlaygroundWebView) {
        self.parent = parent
        super.init()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        parent.onWebViewLoaded?()
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

struct PlaygroundWebView: UIViewRepresentable {
    @Binding var webView: WKWebView?
    var playgroundTemplate: String = "playground"
    var onWebViewLoaded: (() -> Void)?
    var onWebViewError: ((Error) -> Void)?
    var onJavaScriptMessage: ((String, [String: Any]) -> Void)?
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        
        // Configure message handler
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "playgroundHandler")
        configuration.userContentController = contentController
        
        // Enable debugging (if needed)
        configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        
        // Allow arbitrary loads for CDN resources
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false
        
        // Load local HTML file - enhanced template loading with multiple fallback strategies
        var htmlLoaded = false
        
        print("🔍 Attempting to load playground template: \(playgroundTemplate)")
        
        // Strategy 1: Try direct bundle path with specific resource lookup
        if let htmlPath = Bundle.main.path(forResource: playgroundTemplate, ofType: "html") {
            do {
                let htmlContent = try String(contentsOfFile: htmlPath)
                if let baseURL = Bundle.main.resourceURL {
                    print("✅ Loading HTML from main bundle: \(htmlPath)")
                    print("🔗 Base URL: \(baseURL)")
                    webView.loadHTMLString(htmlContent, baseURL: baseURL)
                    htmlLoaded = true
                } else {
                    // Fallback to file URL if no base URL
                    let fileURL = URL(fileURLWithPath: htmlPath)
                    print("✅ Loading HTML with file URL: \(fileURL)")
                    webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
                    htmlLoaded = true
                }
            } catch {
                print("❌ Failed to read HTML content from \(htmlPath): \(error)")
            }
        }
        
        // Strategy 2: Try looking in Resources subdirectory specifically
        else if let resourcePath = Bundle.main.resourcePath {
            let resourcesHtmlPath = (resourcePath as NSString).appendingPathComponent("Resources/\(playgroundTemplate).html")
            if FileManager.default.fileExists(atPath: resourcesHtmlPath) {
                do {
                    let htmlContent = try String(contentsOfFile: resourcesHtmlPath)
                    if let baseURL = Bundle.main.resourceURL {
                        print("✅ Loading HTML from Resources subdirectory: \(resourcesHtmlPath)")
                        webView.loadHTMLString(htmlContent, baseURL: baseURL)
                        htmlLoaded = true
                    }
                } catch {
                    print("❌ Failed to read HTML from Resources: \(error)")
                }
            }
        }
        
        // Strategy 3: Fallback to default playground if specific template failed
        if !htmlLoaded && playgroundTemplate != "playground" {
            print("⚠️ Template \(playgroundTemplate) not found, falling back to default playground")
            if let htmlPath = Bundle.main.path(forResource: "playground", ofType: "html") {
                do {
                    let htmlContent = try String(contentsOfFile: htmlPath)
                    if let baseURL = Bundle.main.resourceURL {
                        print("✅ Loading fallback HTML: \(htmlPath)")
                        webView.loadHTMLString(htmlContent, baseURL: baseURL)
                        htmlLoaded = true
                    }
                } catch {
                    print("❌ Failed to load fallback HTML: \(error)")
                }
            }
        }
        
        // Strategy 4: Emergency fallback - create minimal HTML
        if !htmlLoaded {
            print("❌ All template loading strategies failed - creating emergency fallback")
            let emergencyHTML = """
            <!DOCTYPE html>
            <html><head><title>Template Loading Error</title></head>
            <body style="background:#1e1e1e;color:#fff;padding:20px;font-family:system-ui;">
            <h1>Template Loading Error</h1>
            <p>Failed to load playground template: \(playgroundTemplate)</p>
            <p>Please check that the template file exists in the app bundle.</p>
            </body></html>
            """
            webView.loadHTMLString(emergencyHTML, baseURL: nil)
            htmlLoaded = true
            
            // Debug bundle contents for troubleshooting
            if let resourcePath = Bundle.main.resourcePath {
                print("🔍 Bundle resource path: \(resourcePath)")
                do {
                    let bundleContents = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                    print("📁 Bundle contents: \(bundleContents)")
                    
                    let resourcesPath = (resourcePath as NSString).appendingPathComponent("Resources")
                    if FileManager.default.fileExists(atPath: resourcesPath) {
                        let resourcesContents = try FileManager.default.contentsOfDirectory(atPath: resourcesPath)
                        print("📁 Resources directory contents: \(resourcesContents)")
                    }
                } catch {
                    print("❌ Error listing bundle contents: \(error)")
                }
            }
        }
        
        DispatchQueue.main.async {
            self.webView = webView
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No updates needed for now
    }
    
    func handleJavaScriptMessage(action: String, data: [String: Any]) {
        onJavaScriptMessage?(action, data)
    }
}