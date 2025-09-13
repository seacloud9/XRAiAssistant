import Foundation

class OpenAIProvider: AIProvider {
    let name = "OpenAI"
    let requiresAPIKey = true
    
    private var apiKey: String?
    private let baseURL = "https://api.openai.com/v1"
    
    let models: [AIModel] = [
        AIModel(
            id: "gpt-4o",
            displayName: "GPT-4o",
            description: "Most advanced multimodal model",
            pricing: "$2.50/$10.00 per 1M tokens",
            provider: "OpenAI",
            isDefault: true
        ),
        AIModel(
            id: "gpt-4o-mini",
            displayName: "GPT-4o Mini",
            description: "Fast and affordable smart model",
            pricing: "$0.15/$0.60 per 1M tokens",
            provider: "OpenAI"
        ),
        AIModel(
            id: "gpt-4-turbo",
            displayName: "GPT-4 Turbo",
            description: "Previous flagship model",
            pricing: "$10.00/$30.00 per 1M tokens",
            provider: "OpenAI"
        ),
        AIModel(
            id: "gpt-3.5-turbo",
            displayName: "GPT-3.5 Turbo",
            description: "Fast and cost-effective",
            pricing: "$0.50/$1.50 per 1M tokens",
            provider: "OpenAI"
        )
    ]
    
    func configure(apiKey: String) {
        self.apiKey = apiKey
        print("🔧 OpenAI provider configured with API key: \(String(apiKey.prefix(10)))...")
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
        
        let openAIMessages = messages.map { message in
            [
                "role": mapRole(message.role),
                "content": message.content
            ]
        }
        
        let requestBody: [String: Any] = [
            "model": model,
            "messages": openAIMessages,
            "temperature": temperature,
            "top_p": topP,
            "stream": true
        ]
        
        print("🚀 OpenAI request: model=\(model), temp=\(temperature), top-p=\(topP)")
        
        return AsyncThrowingStream<String, Error> { continuation in
            Task {
                do {
                    guard let url = URL(string: "\(baseURL)/chat/completions") else {
                        throw AIProviderError.configurationError("Invalid URL")
                    }
                    
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
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
                               let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                               let choices = json["choices"] as? [[String: Any]],
                               let delta = choices.first?["delta"] as? [String: Any],
                               let content = delta["content"] as? String {
                                continuation.yield(content)
                            }
                        }
                    }
                    continuation.finish()
                } catch {
                    print("❌ OpenAI error: \(error)")
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    private func mapRole(_ role: AIMessageRole) -> String {
        switch role {
        case .system: return "system"
        case .user: return "user"
        case .assistant: return "assistant"
        }
    }
}