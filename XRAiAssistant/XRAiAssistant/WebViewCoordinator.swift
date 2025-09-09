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
        
        // Load local HTML file - try multiple approaches
        var htmlLoaded = false
        
        // First try: look in Resources subdirectory
        if let htmlPath = Bundle.main.path(forResource: "playground", ofType: "html", inDirectory: "Resources"),
           let htmlContent = try? String(contentsOfFile: htmlPath),
           let baseURL = Bundle.main.resourceURL?.appendingPathComponent("Resources") {
            print("Loading HTML from Resources directory: \(htmlPath)")
            print("Base URL: \(baseURL)")
            webView.loadHTMLString(htmlContent, baseURL: baseURL)
            htmlLoaded = true
        }
        
        // Second try: look in main bundle
        if !htmlLoaded, let htmlPath = Bundle.main.path(forResource: "playground", ofType: "html"),
           let htmlContent = try? String(contentsOfFile: htmlPath),
           let baseURL = Bundle.main.resourceURL {
            print("Loading HTML from main bundle: \(htmlPath)")
            print("Base URL: \(baseURL)")
            webView.loadHTMLString(htmlContent, baseURL: baseURL)
            htmlLoaded = true
        }
        
        // Third try: load with file URL
        if !htmlLoaded, let htmlPath = Bundle.main.path(forResource: "playground", ofType: "html", inDirectory: "Resources") {
            let fileURL = URL(fileURLWithPath: htmlPath)
            print("Loading HTML with file URL: \(fileURL)")
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
            htmlLoaded = true
        }
        
        if !htmlLoaded {
            print("Failed to load HTML file - debugging bundle contents")
            if let resourcePath = Bundle.main.resourcePath {
                print("Resource path: \(resourcePath)")
                let resourcesPath = (resourcePath as NSString).appendingPathComponent("Resources")
                print("Resources directory exists: \(FileManager.default.fileExists(atPath: resourcesPath))")
                
                // List bundle contents
                do {
                    let bundleContents = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                    print("Bundle contents: \(bundleContents)")
                } catch {
                    print("Error listing bundle contents: \(error)")
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