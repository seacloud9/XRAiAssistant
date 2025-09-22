import Foundation
import SwiftUI

@MainActor
public class BuildManager: ObservableObject {
    @Published public var buildStatus: BuildStatus = .idle
    @Published public var isBuilding = false
    @Published public var lastAnalysis: BuildAnalysis?
    @Published public var buildTrends: BuildTrends?
    
    private let buildServiceFactory = BuildServiceFactory.shared
    private var buildService: BuildService?
    private let analyzer = BuildAnalyzer.shared
    private let internalHotReloadManager = HotReloadManager.shared
    
    public static let shared = BuildManager()
    
    private init() {
        buildService = buildServiceFactory.createBuildService()
        setupHotReload()
    }
    
    private func setupHotReload() {
        // Establish the connection after initialization to avoid circular dependency
        internalHotReloadManager.setBuildManager(self)
        internalHotReloadManager.onHotReload = { [weak self] result in
            self?.handleHotReloadResult(result)
        }
    }
    
    public func buildCode(
        code: String,
        framework: FrameworkKind,
        onComplete: @escaping (BuildResult) -> Void
    ) async {
        guard !isBuilding else {
            print("⚠️ Build already in progress")
            return
        }
        
        isBuilding = true
        buildStatus = .building
        
        let request = BuildRequest(
            framework: framework,
            entryCode: code,
            extraFiles: [:],
            jsxRuntime: "automatic",
            defines: [
                "process.env.NODE_ENV": "\"production\""
            ],
            minify: false
        )
        
        let result = await buildService?.build(request) ?? BuildResult(
            success: false,
            errors: ["Build service not available"]
        )
        
        isBuilding = false
        
        if result.success {
            buildStatus = .success(bytes: result.bytes, durationMs: result.durationMs)
        } else {
            buildStatus = .error(message: result.errors.first ?? "Build failed")
        }
        
        // Analyze the build
        let analysis = result.analyze(for: framework)
        lastAnalysis = analysis
        buildTrends = analyzer.getBuildTrends()
        
        // Log analysis
        print("📊 Build Analysis: \(analysis.grade.emoji) \(analysis.grade.rawValue)")
        print("   Build Time: \(String(format: "%.1f", analysis.buildTime))s")
        print("   Bundle Size: \(String(format: "%.1f", analysis.bundleSizeKB))KB")
        
        onComplete(result)
    }
    
    private func handleHotReloadResult(_ result: BuildResult) {
        if result.success {
            buildStatus = .success(bytes: result.bytes, durationMs: result.durationMs)
        } else {
            buildStatus = .error(message: result.errors.first ?? "Hot reload failed")
        }
    }
    
    public func shouldAutoBuild(for framework: FrameworkKind) -> Bool {
        return framework.requiresBuild
    }
    
    public func resetBuildStatus() {
        buildStatus = .idle
    }
    
    // MARK: - Phase 2 Enhanced Features
    
    public func enableHotReload(configuration: HotReloadConfiguration = .default) {
        internalHotReloadManager.enable()
        internalHotReloadManager.setReloadDelay(configuration.debounceDelay)
        print("🔥 Hot reload enabled with \(configuration.debounceDelay)s delay")
    }
    
    public func disableHotReload() {
        internalHotReloadManager.disable()
    }
    
    public func codeDidChange(_ code: String, framework: FrameworkKind) {
        internalHotReloadManager.codeDidChange(code, framework: framework)
    }
    
    public func getOptimizationRecommendations() -> [String] {
        return analyzer.getOptimizationRecommendations()
    }
    
    public func clearBuildCache() async {
        if let nodeService = buildService as? NodeBuildService {
            await nodeService.clearCache()
            print("🗑️ Build cache cleared")
        }
    }
    
    public func getWorkerStats() async -> NodeWorkerStats? {
        if let nodeService = buildService as? NodeBuildService {
            return await nodeService.getWorkerStats()
        }
        return nil
    }
    
    public func warmupWorker() async {
        if let nodeService = buildService as? NodeBuildService {
            await nodeService.warmupWorker()
        }
    }
    
    public var isUsingNodeJS: Bool {
        return buildServiceFactory.isNodeAvailable && buildService is NodeBuildService
    }
    
    public var isHotReloadEnabled: Bool {
        return internalHotReloadManager.isEnabled
    }
}

// MARK: - Build Integration Helper

public struct BuildIntegration {
    
    internal static func getFrameworkKind(from library3D: any Library3D) -> FrameworkKind? {
        switch library3D.id {
        case "babylonjs": return .babylon
        case "threejs": return nil // Three.js uses direct injection
        case "aframe": return .aFrame
        case "reactThreeFiber": return .reactThreeFiber
        case "reactylon": return .reactylon
        default: return nil
        }
    }
    
    internal static func shouldShowBuildButton(for library3D: any Library3D) -> Bool {
        guard let framework = getFrameworkKind(from: library3D) else { return false }
        return framework.requiresBuild
    }
    
    public static func getCodeLanguage(for framework: FrameworkKind) -> String {
        return framework.codeLanguage
    }
}