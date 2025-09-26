import Foundation

class AnthropicProvider: AIProvider {
    let name = "Anthropic"
    let requiresAPIKey = true
    
    private var apiKey: String?
    private let baseURL = "https://api.anthropic.com/v1"
    
    let models: [AIModel] = [
        AIModel(
            id: "claude-sonnet-4-20250514",
            displayName: "Claude Sonnet 4",
            description: "Latest high-performance model with exceptional reasoning and efficiency",
            pricing: "$3.00/$15.00 per 1M tokens",
            provider: "Anthropic",
            isDefault: true
        ),
        AIModel(
            id: "claude-opus-4-20250514",
            displayName: "Claude Opus 4",
            description: "Most advanced Claude model - world's best coding model (SWE-bench: 72.5%)",
            pricing: "$15.00/$75.00 per 1M tokens",
            provider: "Anthropic"
        ),
        AIModel(
            id: "claude-3-5-sonnet-20241022",
            displayName: "Claude 3.5 Sonnet (Legacy)",
            description: "⚠️ DEPRECATED - Will be retired Oct 22, 2025. Upgrade to Claude Sonnet 4",
            pricing: "$3.00/$15.00 per 1M tokens",
            provider: "Anthropic"
        ),
        AIModel(
            id: "claude-3-5-haiku-20241022",
            displayName: "Claude 3.5 Haiku",
            description: "Fast and affordable model with excellent performance",
            pricing: "$0.25/$1.25 per 1M tokens",
            provider: "Anthropic"
        ),
        AIModel(
            id: "claude-3-opus-20240229",
            displayName: "Claude 3 Opus",
            description: "Previous generation powerful model for complex reasoning",
            pricing: "$15.00/$75.00 per 1M tokens",
            provider: "Anthropic"
        ),
        AIModel(
            id: "claude-3-sonnet-20240229",
            displayName: "Claude 3 Sonnet",
            description: "Previous generation balanced model",
            pricing: "$3.00/$15.00 per 1M tokens",
            provider: "Anthropic"
        ),
        AIModel(
            id: "claude-3-haiku-20240307",
            displayName: "Claude 3 Haiku",
            description: "Previous generation fast model",
            pricing: "$0.25/$1.25 per 1M tokens",
            provider: "Anthropic"
        )
    ]
    
    func configure(apiKey: String) {
        self.apiKey = apiKey
        print("🔧 Anthropic provider configured with API key: \(String(apiKey.prefix(10)))...")
    }
    
    func generateResponse(
        messages: [AIMessage],
        model: String,
        temperature: Double,
        topP: Double
    ) async throws -> AsyncThrowingStream<String, Error> {
        
        guard let apiKey = apiKey else {
            throw AIProviderError.configurationError("Provider not configured with API key")
        }
        
        // Anthropic API requires system message to be separate
        var systemMessage: String = ""
        var conversationMessages: [[String: Any]] = []
        
        for message in messages {
            if message.role == .system {
                systemMessage = message.content
            } else {
                conversationMessages.append([
                    "role": mapRole(message.role),
                    "content": message.content
                ])
            }
        }
        
        var requestBody: [String: Any] = [
            "model": model,
            "messages": conversationMessages,
            "temperature": temperature,
            "top_p": topP,
            "stream": true,
            "max_tokens": 4000
        ]
        
        if !systemMessage.isEmpty {
            requestBody["system"] = systemMessage
        }
        
        print("🚀 Anthropic request: model=\(model), temp=\(temperature), top-p=\(topP)")
        
        return AsyncThrowingStream<String, Error> { continuation in
            Task {
                do {
                    guard let url = URL(string: "\(baseURL)/messages") else {
                        throw AIProviderError.configurationError("Invalid URL")
                    }
                    
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
                    request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
                    
                    let (data, response) = try await URLSession.shared.data(for: request)
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        guard httpResponse.statusCode == 200 else {
                            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                            throw AIProviderError.networkError("HTTP \(httpResponse.statusCode): \(errorMessage)")
                        }
                    }
                    
                    let lines = String(data: data, encoding: .utf8)?.components(separatedBy: "\n") ?? []
                    
                    for line in lines {
                        if line.hasPrefix("data: ") {
                            let jsonString = String(line.dropFirst(6))
                            
                            if jsonString.trimmingCharacters(in: .whitespaces) == "[DONE]" {
                                continuation.finish()
                                return
                            }
                            
                            if let jsonData = jsonString.data(using: .utf8),
                               let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                                
                                if let type = json["type"] as? String {
                                    switch type {
                                    case "content_block_delta":
                                        if let delta = json["delta"] as? [String: Any],
                                           let text = delta["text"] as? String {
                                            continuation.yield(text)
                                        }
                                    case "message_stop":
                                        continuation.finish()
                                        return
                                    default:
                                        break
                                    }
                                }
                            }
                        }
                    }
                    continuation.finish()
                } catch {
                    print("❌ Anthropic error: \(error)")
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    private func mapRole(_ role: AIMessageRole) -> String {
        switch role {
        case .system: return "system" // Handled separately
        case .user: return "user"
        case .assistant: return "assistant"
        }
    }
}