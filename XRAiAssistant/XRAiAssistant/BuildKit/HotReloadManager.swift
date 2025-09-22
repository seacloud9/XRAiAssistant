import Foundation
import Combine

// MARK: - Hot Reload Manager

@MainActor
public class HotReloadManager: ObservableObject {
    @Published public var isEnabled = false
    @Published public var isReloading = false
    @Published public var lastReloadTime: Date?
    
    private var codeChangeTimer: Timer?
    private var lastCode = ""
    private var reloadDelay: TimeInterval = 1.5 // Debounce delay
    private weak var buildManager: BuildManager?
    
    // Callbacks
    public var onCodeChange: ((String) -> Void)?
    public var onHotReload: ((BuildResult) -> Void)?
    
    public static let shared = HotReloadManager()
    
    private init() {
        print("🔥 Hot Reload Manager initialized")
    }
    
    // MARK: - Public API
    
    public func enable() {
        isEnabled = true
        print("🔥 Hot reload enabled")
    }
    
    public func disable() {
        isEnabled = false
        codeChangeTimer?.invalidate()
        codeChangeTimer = nil
        print("🔥 Hot reload disabled")
    }
    
    public func codeDidChange(_ newCode: String, framework: FrameworkKind) {
        guard isEnabled else { return }
        guard framework.requiresBuild else { return }
        guard newCode != lastCode else { return }
        
        lastCode = newCode
        
        // Debounce rapid changes
        codeChangeTimer?.invalidate()
        codeChangeTimer = Timer.scheduledTimer(withTimeInterval: reloadDelay, repeats: false) { _ in
            Task {
                await self.performHotReload(code: newCode, framework: framework)
            }
        }
        
        onCodeChange?(newCode)
    }
    
    private func performHotReload(code: String, framework: FrameworkKind) async {
        guard isEnabled else { return }
        
        // Get BuildManager safely (avoid circular dependency during init)
        let manager = buildManager ?? BuildManager.shared
        if buildManager == nil {
            buildManager = manager
        }
        
        print("🔥 Performing hot reload for \(framework.displayName)")
        isReloading = true
        
        await manager.buildCode(
            code: code,
            framework: framework
        ) { result in
            DispatchQueue.main.async {
                self.isReloading = false
                self.lastReloadTime = Date()
                
                if result.success {
                    print("🔥 Hot reload successful in \(result.durationMs)ms")
                } else {
                    print("🔥 Hot reload failed: \(result.errors)")
                }
                
                self.onHotReload?(result)
            }
        }
    }
    
    public func setReloadDelay(_ delay: TimeInterval) {
        reloadDelay = delay
        print("🔥 Hot reload delay set to \(delay)s")
    }
    
    // MARK: - Internal API for BuildManager
    
    internal func setBuildManager(_ manager: BuildManager) {
        self.buildManager = manager
    }
}

// MARK: - Hot Reload Configuration

public struct HotReloadConfiguration {
    public let enabled: Bool
    public let debounceDelay: TimeInterval
    public let minCodeLength: Int
    public let excludePatterns: [String]
    
    public static let `default` = HotReloadConfiguration(
        enabled: true,
        debounceDelay: 1.5,
        minCodeLength: 10,
        excludePatterns: [
            "console.log",
            "// TODO",
            "/* test */"
        ]
    )
    
    public static let fast = HotReloadConfiguration(
        enabled: true,
        debounceDelay: 0.8,
        minCodeLength: 5,
        excludePatterns: []
    )
    
    public static let conservative = HotReloadConfiguration(
        enabled: true,
        debounceDelay: 3.0,
        minCodeLength: 50,
        excludePatterns: [
            "console.log",
            "console.warn",
            "console.error",
            "// TODO",
            "/* test */",
            "debugger"
        ]
    )
}

// MARK: - Hot Reload Extensions for Build System

extension BuildManager {
    public var hotReloadManager: HotReloadManager {
        return HotReloadManager.shared
    }
}