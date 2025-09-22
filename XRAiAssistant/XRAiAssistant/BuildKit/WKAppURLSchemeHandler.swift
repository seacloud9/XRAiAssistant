import Foundation
import WebKit

// MARK: - App URL Scheme Handler

public class WKAppURLSchemeHandler: NSObject, WKURLSchemeHandler {
    
    public static let schemeName = "app"
    
    private let vendorMappings: [String: String] = [
        "/vendor/react.production.min.js": "react-18.2.0.min.js",
        "/vendor/react-dom.production.min.js": "react-dom-18.2.0.min.js",
        "/vendor/three.module.js": "three-r160.module.js",
        "/vendor/react-three-fiber.js": "react-three-fiber-esm.js",
        "/vendor/drei.js": "drei-esm.js",
        "/vendor/reactylon.js": "reactylon-1.0.0.js",
        "/vendor/babylonjs.js": "babylonjs-6.0.0.js"
    ]
    
    public func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url,
              url.scheme == Self.schemeName else {
            urlSchemeTask.didFailWithError(URLError(.badURL))
            return
        }
        
        let path = url.path
        print("📦 Serving vendor asset: \(path)")
        
        // Check if this is a vendor asset request
        if let assetFileName = vendorMappings[path] {
            serveVendorAsset(assetFileName: assetFileName, for: urlSchemeTask)
        } else {
            // Handle other app:// URLs if needed
            print("⚠️ Unknown app:// URL: \(url)")
            urlSchemeTask.didFailWithError(URLError(.fileDoesNotExist))
        }
    }
    
    public func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        // Clean up if needed
    }
    
    private func serveVendorAsset(assetFileName: String, for task: WKURLSchemeTask) {
        guard let assetPath = Bundle.main.path(forResource: assetFileName.replacingOccurrences(of: ".js", with: ""), 
                                              ofType: "js", 
                                              inDirectory: "Vendor") else {
            print("❌ Vendor asset not found: \(assetFileName)")
            task.didFailWithError(URLError(.fileDoesNotExist))
            return
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: assetPath))
            let response = HTTPURLResponse(
                url: task.request.url!,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: [
                    "Content-Type": "application/javascript",
                    "Content-Length": "\(data.count)",
                    "Cache-Control": "public, max-age=31536000" // Cache for 1 year
                ]
            )!
            
            task.didReceive(response)
            task.didReceive(data)
            task.didFinish()
            
            print("✅ Served vendor asset: \(assetFileName) (\(data.count) bytes)")
            
        } catch {
            print("❌ Failed to load vendor asset \(assetFileName): \(error)")
            task.didFailWithError(error)
        }
    }
}

// MARK: - Vendor Asset Manager

public class VendorAssetManager {
    
    public static let shared = VendorAssetManager()
    
    private init() {}
    
    public func checkVendorAssets() -> [String: Bool] {
        var assetStatus: [String: Bool] = [:]
        
        let requiredAssets = [
            "react-18.2.0.min.js",
            "react-dom-18.2.0.min.js", 
            "three-r160.module.js",
            "react-three-fiber-8.15.12.js",
            "drei-9.88.13.js"
        ]
        
        for asset in requiredAssets {
            let exists = Bundle.main.path(forResource: asset.replacingOccurrences(of: ".js", with: ""), 
                                         ofType: "js", 
                                         inDirectory: "Vendor") != nil
            assetStatus[asset] = exists
            
            if exists {
                print("✅ Vendor asset found: \(asset)")
            } else {
                print("❌ Vendor asset missing: \(asset)")
            }
        }
        
        return assetStatus
    }
    
    public func areAllAssetsAvailable() -> Bool {
        let status = checkVendorAssets()
        return status.values.allSatisfy { $0 }
    }
    
    public func getMissingAssets() -> [String] {
        let status = checkVendorAssets()
        return status.compactMap { key, value in value ? nil : key }
    }
}

// MARK: - WebView Configuration Extension

extension WKWebViewConfiguration {
    
    public static func createWithAppScheme() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        config.setURLSchemeHandler(WKAppURLSchemeHandler(), forURLScheme: WKAppURLSchemeHandler.schemeName)
        return config
    }
}