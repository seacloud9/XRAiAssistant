import Foundation
import AIProxy

class TogetherAIProvider: AIProvider {
    let name = "Together.ai"
    let requiresAPIKey = true
    
    private var togetherAIService: TogetherAIService?
    private var apiKey: String?
    
    let models: [AIModel] = [
        AIModel(
            id: "deepseek-ai/DeepSeek-R1-Distill-Llama-70B-free",
            displayName: "DeepSeek R1 70B",
            description: "Advanced reasoning & coding",
            pricing: "FREE",
            provider: "Together.ai",
            isDefault: true
        ),
        AIModel(
            id: "meta-llama/Llama-3.3-70B-Instruct-Turbo-Free",
            displayName: "Llama 3.3 70B",
            description: "Latest large model",
            pricing: "FREE",
            provider: "Together.ai"
        ),
        AIModel(
            id: "meta-llama/Meta-Llama-3-8B-Instruct-Lite",
            displayName: "Llama 3 8B Lite",
            description: "Cost-effective option",
            pricing: "$0.10/1M tokens",
            provider: "Together.ai"
        ),
        AIModel(
            id: "meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo",
            displayName: "Llama 3.1 8B Turbo",
            description: "Good balance",
            pricing: "$0.18/1M tokens",
            provider: "Together.ai"
        ),
        AIModel(
            id: "Qwen/Qwen2.5-7B-Instruct-Turbo",
            displayName: "Qwen 2.5 7B Turbo",
            description: "Fast coding specialist",
            pricing: "$0.30/1M tokens",
            provider: "Together.ai"
        ),
        AIModel(
            id: "Qwen/Qwen2.5-Coder-32B-Instruct",
            displayName: "Qwen 2.5 Coder 32B",
            description: "Advanced coding & XR",
            pricing: "$0.80/1M tokens",
            provider: "Together.ai"
        )
    ]
    
    func configure(apiKey: String) {
        self.apiKey = apiKey
        self.togetherAIService = AIProxy.togetherAIDirectService(
            unprotectedAPIKey: apiKey
        )
        print("🔧 Together.ai provider configured with API key: \(String(apiKey.prefix(10)))...")
    }
    
    func generateResponse(
        messages: [AIMessage],
        model: String,
        temperature: Double,
        topP: Double
    ) async throws -> AsyncThrowingStream<String, Error> {
        
        guard let service = togetherAIService else {
            throw AIProviderError.configurationError("Provider not configured with API key")
        }
        
        // Convert messages to Together.ai format - using the same pattern as ChatViewModel
        let togetherMessages = messages.map { message in
            switch message.role {
            case .system:
                return TogetherAIMessage(content: message.content, role: .system)
            case .user:
                return TogetherAIMessage(content: message.content, role: .user)
            case .assistant:
                return TogetherAIMessage(content: message.content, role: .assistant)
            }
        }
        
        let requestBody = TogetherAIChatCompletionRequestBody(
            messages: togetherMessages,
            model: model,
            stream: true,
            temperature: temperature,
            topP: topP
        )
        
        print("🚀 Together.ai request: model=\(model), temp=\(temperature), top-p=\(topP)")
        
        return AsyncThrowingStream<String, Error> { continuation in
            Task {
                do {
                    let streamingResponse = try await service.streamingChatCompletionRequest(body: requestBody)
                    
                    for try await chunk in streamingResponse {
                        if let content = chunk.choices.first?.delta.content {
                            continuation.yield(content)
                        }
                        
                        if let finishReason = chunk.choices.first?.finishReason {
                            print("🏁 Together.ai stream finished: \(finishReason)")
                            break
                        }
                    }
                    continuation.finish()
                } catch {
                    print("❌ Together.ai error: \(error)")
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}