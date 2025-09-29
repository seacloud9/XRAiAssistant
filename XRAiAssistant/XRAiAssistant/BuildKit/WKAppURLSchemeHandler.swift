import Foundation
import WebKit

// MARK: - App URL Scheme Handler

public class WKAppURLSchemeHandler: NSObject, WKURLSchemeHandler {
    
    public static let schemeName = "app"
    
    private let vendorMappings: [String: String] = [
        // React 19.x mappings (primary) - both /vendor/ and direct paths
        "/vendor/react-19.1.1.min.js": "react-19.1.1.min.js",
        "/react-19.1.1.min.js": "react-19.1.1.min.js",
        "/vendor/react-dom-19.1.1.min.js": "react-dom-19.1.1.min.js",
        "/react-dom-19.1.1.min.js": "react-dom-19.1.1.min.js",
        
        // React 18.x mappings (legacy support)
        "/vendor/react.production.min.js": "react-18.2.0.min.js",
        "/vendor/react-dom.production.min.js": "react-dom-18.2.0.min.js",
        "/vendor/react-18.2.0.min.js": "react-18.2.0.min.js",
        "/react-18.2.0.min.js": "react-18.2.0.min.js",
        "/vendor/react-dom-18.2.0.min.js": "react-dom-18.2.0.min.js",
        "/react-dom-18.2.0.min.js": "react-dom-18.2.0.min.js",
        
        // Three.js and React Three Fiber - both /vendor/ and direct paths
        "/vendor/three.module.js": "three-r171.module.js",
        "/vendor/three-r160.module.js": "three-r160.module.js",
        "/vendor/three-r171.module.js": "three-r171.module.js", 
        "/three-r160.module.js": "three-r160.module.js",
        "/three-r171.module.js": "three-r171.module.js",
        "/vendor/react-three-fiber.js": "react-three-fiber-esm.js",
        "/vendor/react-three-fiber-8.17.10.js": "react-three-fiber-8.17.10.js",
        "/react-three-fiber-8.17.10.js": "react-three-fiber-8.17.10.js",
        "/vendor/drei.js": "drei-esm.js",
        "/vendor/drei-9.127.3.js": "drei-9.127.3.js",
        "/drei-9.127.3.js": "drei-9.127.3.js",
        
        // Babylon.js - updated to v8
        "/vendor/babylonjs.js": "babylonjs-8.22.3.js",
        "/vendor/babylonjs-8.22.3.js": "babylonjs-8.22.3.js",
        "/babylonjs-8.22.3.js": "babylonjs-8.22.3.js",
        
        // A-Frame - updated to v1.7
        "/vendor/aframe.js": "aframe-1.7.0.min.js",
        "/vendor/aframe-1.7.0.min.js": "aframe-1.7.0.min.js",
        "/aframe-1.7.0.min.js": "aframe-1.7.0.min.js",
        
        // Other libraries
        "/vendor/reactylon.js": "reactylon-1.0.0.js"
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
            "react-19.1.1.min.js",
            "react-dom-19.1.1.min.js", 
            "three-r171.module.js",
            "react-three-fiber-8.17.10.js",
            "drei-9.127.3.js",
            "babylonjs-8.22.3.js",
            "aframe-1.7.0.min.js"
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