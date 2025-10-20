import Foundation

// MARK: - Node Build Service (Phase 2 Implementation)

public class NodeBuildService: NSObject, BuildService {
    private var nodeWorker: NodeBuildWorker?
    private var isInitialized = false
    private var initializationTask: Task<Void, Never>?
    
    public override init() {
        super.init()
        startInitialization()
    }
    
    deinit {
        // Cannot call main actor-isolated method from deinit
        // Cleanup will happen when nodeWorker is deallocated
    }
    
    private func startInitialization() {
        initializationTask = Task {
            await initializeNodeWorker()
        }
    }
    
    private func initializeNodeWorker() async {
        // Node.js Mobile implementation is not yet complete
        print("🚀 Node.js Mobile worker initialization...")
        print("⚠️ Node.js Mobile worker not yet implemented - using WASM fallback")
        isInitialized = false
        nodeWorker = nil
    }
    
    public func isNodeAvailable() -> Bool {
        return isInitialized && nodeWorker != nil
    }
    
    public func build(_ request: BuildRequest) async -> BuildResult {
        // Wait for initialization if needed
        await initializationTask?.value
        
        guard let worker = nodeWorker, isInitialized else {
            print("❌ Node.js worker not available, falling back to WASM")
            return BuildResult(
                success: false,
                bundleCode: nil,
                warnings: [],
                errors: ["Node.js worker not initialized"],
                bytes: 0,
                durationMs: 0
            )
        }
        
        print("🏗️ Building with Node.js worker: \(request.framework.displayName)")
        let startTime = Date()
        
        do {
            let result = try await worker.build(request)
            let durationMs = Int(Date().timeIntervalSince(startTime) * 1000)
            
            print("✅ Node.js build completed in \(durationMs)ms")
            
            return BuildResult(
                success: result.success,
                bundleCode: result.bundleCode,
                warnings: result.warnings,
                errors: result.errors,
                bytes: result.bytes,
                durationMs: durationMs
            )
            
        } catch {
            let durationMs = Int(Date().timeIntervalSince(startTime) * 1000)
            print("❌ Node.js build error: \(error)")
            
            return BuildResult(
                success: false,
                bundleCode: nil,
                warnings: [],
                errors: [error.localizedDescription],
                bytes: 0,
                durationMs: durationMs
            )
        }
    }
    
    // MARK: - Additional Node.js Capabilities
    
    public func clearCache() async {
        await nodeWorker?.clearCache()
    }
    
    public func getWorkerStats() async -> NodeWorkerStats? {
        return await nodeWorker?.getStats()
    }
    
    public func warmupWorker() async {
        // Pre-warm the worker with a simple build to reduce first-build latency
        let warmupRequest = BuildRequest(
            framework: .reactThreeFiber,
            entryCode: "console.log('warmup');",
            minify: false
        )
        
        _ = await build(warmupRequest)
        print("🔥 Node.js worker warmed up")
    }
}

// MARK: - Node Worker Bridge Types

public struct NodeBuildMessage: Codable {
    public let cmd: String
    public let framework: String
    public let entry: String
    public let files: [String: String]
    public let defines: [String: String]
    public let minify: Bool
    
    public init(from request: BuildRequest) {
        self.cmd = "build"
        self.framework = request.framework.rawValue
        self.entry = "/src/\(request.framework.entryFileName)"
        var files: [String: String] = [:]
        files["/src/\(request.framework.entryFileName)"] = request.entryCode
        for (path, content) in request.extraFiles {
            files[path] = content
        }
        self.files = files
        self.defines = request.defines
        self.minify = request.minify
    }
}

public struct NodeBuildResponse: Codable {
    public let status: String
    public let bundleCode: String?
    public let warnings: [String]
    public let errors: [String]
    public let bytes: Int
    public let durationMs: Int
    public let fromCache: Bool?
    public let metafile: String?
    
    public var success: Bool {
        return status == "ok"
    }
}

public struct NodeWorkerStats: Codable {
    public let totalBuilds: Int
    public let cacheHits: Int
    public let averageBuildTime: Double
    public let lastBuildTime: Int
    public let cacheSize: Int
    public let uptime: Double
}

// MARK: - Node Build Worker Implementation

@MainActor
public class NodeBuildWorker {
    private var isRunning = false
    private var messageHandlers: [String: CheckedContinuation<[String: Any], Error>] = [:]
    private let messageQueue = DispatchQueue(label: "NodeWorker.messages", qos: .userInitiated)
    
    public init() throws {
        try initializeNodeJSMobile()
    }
    
    private func initializeNodeJSMobile() throws {
        // Initialize Node.js Mobile runtime
        // This would use NodeJSMobile.start() in a real implementation
        print("🚀 Starting Node.js Mobile runtime...")
        
        // For now, simulate successful initialization
        // In a real implementation, this would:
        // 1. Copy the NodeWorker directory to the app's Documents
        // 2. Start the Node.js runtime with build-worker.js
        // 3. Set up the message bridge
        
        isRunning = true
        print("✅ Node.js Mobile runtime started")
    }
    
    public func shutdown() {
        isRunning = false
        // Clean up Node.js runtime
        print("🛑 Node.js worker shutting down")
    }
    
    public func ping() async -> Bool {
        guard isRunning else { return false }
        
        do {
            let response = try await sendMessage(cmd: "ping", payload: [:])
            return response["status"] as? String == "ok"
        } catch {
            print("❌ Node.js worker ping failed: \(error)")
            return false
        }
    }
    
    public func build(_ request: BuildRequest) async throws -> NodeBuildResponse {
        guard isRunning else {
            throw NodeWorkerError.workerNotRunning
        }
        
        let message = NodeBuildMessage(from: request)
        let messageData = try JSONEncoder().encode(message)
        let messageDict = try JSONSerialization.jsonObject(with: messageData) as! [String: Any]
        
        let response = try await sendMessage(cmd: "build", payload: messageDict)
        let responseData = try JSONSerialization.data(withJSONObject: response)
        return try JSONDecoder().decode(NodeBuildResponse.self, from: responseData)
    }
    
    public func clearCache() async {
        do {
            _ = try await sendMessage(cmd: "clear-cache", payload: [:])
            print("🗑️ Node.js worker cache cleared")
        } catch {
            print("❌ Failed to clear Node.js worker cache: \(error)")
        }
    }
    
    public func getStats() async -> NodeWorkerStats? {
        do {
            let response = try await sendMessage(cmd: "stats", payload: [:])
            if let stats = response["stats"] as? [String: Any] {
                let statsData = try JSONSerialization.data(withJSONObject: stats)
                return try JSONDecoder().decode(NodeWorkerStats.self, from: statsData)
            }
        } catch {
            print("❌ Failed to get Node.js worker stats: \(error)")
        }
        return nil
    }
    
    private func sendMessage(cmd: String, payload: [String: Any]) async throws -> [String: Any] {
        guard isRunning else {
            throw NodeWorkerError.workerNotRunning
        }

        return try await withCheckedThrowingContinuation { continuation in
            let messageId = UUID().uuidString
            var message = payload
            message["cmd"] = cmd
            message["messageId"] = messageId

            // Store continuation for response handling
            // This needs to run on MainActor since messageHandlers is MainActor-isolated
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.messageHandlers[messageId] = continuation

                // Send message to Node.js worker
                // In a real implementation, this would use NodeJSMobile's message sending
                self.simulateNodeJSResponse(for: cmd, messageId: messageId, payload: payload)
            }
        }
    }
    
    // Simulation for development - replace with real Node.js Mobile bridge
    private func simulateNodeJSResponse(for cmd: String, messageId: String, payload: [String: Any]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Simulate processing time
            var response: [String: Any] = [:]
            
            switch cmd {
            case "ping":
                response = ["status": "ok", "message": "pong", "timestamp": Date().timeIntervalSince1970]
                
            case "build":
                // Simulate a successful build response
                response = [
                    "status": "ok",
                    "bundleCode": "/* Mock built bundle */\nconsole.log('Built with Node.js worker');",
                    "warnings": [],
                    "errors": [],
                    "bytes": 1024,
                    "durationMs": 150,
                    "fromCache": false
                ]
                
            case "clear-cache":
                response = ["status": "ok", "message": "Cache cleared"]
                
            case "stats":
                response = [
                    "status": "ok",
                    "stats": [
                        "totalBuilds": 42,
                        "cacheHits": 12,
                        "averageBuildTime": 180.5,
                        "lastBuildTime": 150,
                        "cacheSize": 8,
                        "uptime": 3600.0
                    ]
                ]
                
            default:
                response = ["status": "error", "error": "Unknown command: \(cmd)"]
            }
            
            if let continuation = self.messageHandlers.removeValue(forKey: messageId) {
                continuation.resume(returning: response)
            }
        }
    }
}

// MARK: - Node Worker Errors

public enum NodeWorkerError: Error, LocalizedError {
    case workerNotRunning
    case messageTimeout
    case invalidResponse
    case initializationFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .workerNotRunning:
            return "Node.js worker is not running"
        case .messageTimeout:
            return "Message timeout"
        case .invalidResponse:
            return "Invalid response from worker"
        case .initializationFailed(let reason):
            return "Worker initialization failed: \(reason)"
        }
    }
}