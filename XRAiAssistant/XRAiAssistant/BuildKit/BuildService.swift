import Foundation

// MARK: - Framework Types

public enum FrameworkKind: String, CaseIterable {
    case babylon = "babylon"
    case aFrame = "aFrame"
    case reactThreeFiber = "reactThreeFiber"
    case reactylon = "reactylon"
    
    var displayName: String {
        switch self {
        case .babylon: return "Babylon.js"
        case .aFrame: return "A-Frame"
        case .reactThreeFiber: return "React Three Fiber"
        case .reactylon: return "Reactylon"
        }
    }
    
    var requiresBuild: Bool {
        switch self {
        case .babylon, .aFrame: return false
        case .reactThreeFiber, .reactylon: return true
        }
    }
    
    var codeLanguage: String {
        switch self {
        case .babylon, .aFrame: return "javascript"
        case .reactThreeFiber, .reactylon: return "typescript"
        }
    }
    
    var entryFileName: String {
        switch self {
        case .babylon, .aFrame: return "index.js"
        case .reactThreeFiber, .reactylon: return "index.tsx"
        }
    }
}

// MARK: - Build Request/Response Types

public struct BuildRequest {
    public let framework: FrameworkKind
    public let entryCode: String       // Monaco buffer content
    public let extraFiles: [String: String] // path -> content (optional)
    public let jsxRuntime: String?     // "automatic" or "classic"
    public let defines: [String: String] // preprocessor defines
    public let minify: Bool
    
    public init(
        framework: FrameworkKind,
        entryCode: String,
        extraFiles: [String: String] = [:],
        jsxRuntime: String? = "automatic",
        defines: [String: String] = [:],
        minify: Bool = false
    ) {
        self.framework = framework
        self.entryCode = entryCode
        self.extraFiles = extraFiles
        self.jsxRuntime = jsxRuntime
        self.defines = defines
        self.minify = minify
    }
}

public struct BuildResult {
    public let success: Bool
    public let bundleCode: String?
    public let warnings: [String]
    public let errors: [String]
    public let bytes: Int
    public let durationMs: Int
    
    public init(
        success: Bool,
        bundleCode: String? = nil,
        warnings: [String] = [],
        errors: [String] = [],
        bytes: Int = 0,
        durationMs: Int = 0
    ) {
        self.success = success
        self.bundleCode = bundleCode
        self.warnings = warnings
        self.errors = errors
        self.bytes = bytes
        self.durationMs = durationMs
    }
}

// MARK: - Build Service Protocol

public protocol BuildService {
    func isNodeAvailable() -> Bool
    func build(_ request: BuildRequest) async -> BuildResult
}

// MARK: - Build Service Factory

@MainActor
public class BuildServiceFactory: ObservableObject {
    @Published public private(set) var isNodeAvailable: Bool = false
    
    private var _nodeService: NodeBuildService?
    private var _wasmService: WasmBuildService?
    private var nodeAvailabilityChecked: Bool = false
    
    public static let shared = BuildServiceFactory()
    
    private init() {
        // Don't check Node availability in init to avoid main thread deadlock
        print("🏭 BuildServiceFactory initialized")
    }
    
    private func checkNodeAvailabilityIfNeeded() {
        guard !nodeAvailabilityChecked else { return }
        nodeAvailabilityChecked = true
        
        // Phase 2: Check for Node.js Mobile availability asynchronously
        Task {
            let nodeService = NodeBuildService()
            let available = nodeService.isNodeAvailable()

            await MainActor.run {
                self.isNodeAvailable = available
                print("📱 Node.js availability: \(available ? "✅ Available" : "❌ Not available")")
            }
        }
    }
    
    public func createBuildService() -> BuildService {
        // Lazily check Node.js availability on first access
        checkNodeAvailabilityIfNeeded()
        
        if isNodeAvailable {
            if _nodeService == nil {
                _nodeService = NodeBuildService()
            }
            return _nodeService!
        } else {
            if _wasmService == nil {
                _wasmService = WasmBuildService()
            }
            return _wasmService!
        }
    }
    
    public func refreshNodeAvailability() {
        nodeAvailabilityChecked = false
        checkNodeAvailabilityIfNeeded()
    }
}

// MARK: - Build Status Types

public enum BuildStatus {
    case idle
    case building
    case success(bytes: Int, durationMs: Int)
    case error(message: String)
    
    public var isBuilding: Bool {
        if case .building = self { return true }
        return false
    }
    
    public var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
    
    public var isError: Bool {
        if case .error = self { return true }
        return false
    }
    
    public var statusText: String {
        switch self {
        case .idle: return "Ready to build"
        case .building: return "Building..."
        case .success(let bytes, let durationMs): 
            let kb = Double(bytes) / 1024
            let duration = Double(durationMs) / 1000
            return String(format: "Built in %.1fs, %.1f KB", duration, kb)
        case .error(let message): return message
        }
    }
    
    public var statusColor: String {
        switch self {
        case .idle: return "secondary"
        case .building: return "blue"
        case .success: return "green" 
        case .error: return "red"
        }
    }
}