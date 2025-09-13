import Foundation

// MARK: - AI Provider Protocol

protocol AIProvider {
    var name: String { get }
    var models: [AIModel] { get }
    var requiresAPIKey: Bool { get }
    
    func configure(apiKey: String)
    func generateResponse(
        messages: [AIMessage],
        model: String,
        temperature: Double,
        topP: Double
    ) async throws -> AsyncThrowingStream<String, Error>
}

// MARK: - Supporting Types

struct AIModel {
    let id: String
    let displayName: String
    let description: String
    let pricing: String
    let provider: String
    let isDefault: Bool
    
    init(id: String, displayName: String, description: String, pricing: String = "", provider: String, isDefault: Bool = false) {
        self.id = id
        self.displayName = displayName
        self.description = description
        self.pricing = pricing
        self.provider = provider
        self.isDefault = isDefault
    }
}

struct AIMessage {
    let content: String
    let role: AIMessageRole
}

enum AIMessageRole {
    case system
    case user
    case assistant
}

// MARK: - Provider Configuration

struct ProviderConfiguration {
    let apiKey: String
    let baseURL: String?
    let defaultModel: String
    let supportedParameters: Set<AIParameter>
}

enum AIParameter {
    case temperature
    case topP
    case maxTokens
    case stream
}

// MARK: - Error Handling

enum AIProviderError: Error, LocalizedError {
    case invalidAPIKey
    case modelNotSupported
    case rateLimitExceeded
    case networkError(String)
    case responseEmpty
    case configurationError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid API key provided"
        case .modelNotSupported:
            return "Model not supported by this provider"
        case .rateLimitExceeded:
            return "Rate limit exceeded"
        case .networkError(let message):
            return "Network error: \(message)"
        case .responseEmpty:
            return "Empty response received"
        case .configurationError(let message):
            return "Configuration error: \(message)"
        }
    }
}