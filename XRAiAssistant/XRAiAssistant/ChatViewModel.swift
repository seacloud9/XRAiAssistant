import Foundation
import LlamaStackClient
import AIProxy
import Combine

enum APIError: Error {
    case emptyResponse
    case tooManyRetries
    case invalidModel
}

// MARK: - Configuration Constants
private let DEFAULT_API_KEY = "changeMe"

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedModel: String = "deepseek-ai/DeepSeek-R1-Distill-Llama-70B-free"
    @Published var temperature: Double = 0.7
    @Published var topP: Double = 0.9
    @Published var apiKey: String = DEFAULT_API_KEY // Legacy - for backwards compatibility
    @Published var systemPrompt: String = ""
    
    // New AI Provider System
    private let aiProviderManager = AIProviderManager()
    
    // 3D Library Management System
    private let library3DManager = Library3DManager()
    
    // Expose managers for UI and tests
    var providerManager: AIProviderManager {
        return aiProviderManager
    }
    
    var libraryManager: Library3DManager {
        return library3DManager
    }
    
    // Legacy providers - maintained for compatibility
    private var inference: RemoteInference
    private var togetherAIService: TogetherAIService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Configuration Toggle
    /// Controls routing for Llama models:
    /// - `true`: Use local LlamaStack server for meta-llama models (supports max_tokens via server config)
    /// - `false`: Use Together.ai for ALL models (supports max_tokens via API, prevents truncation)
    /// 
    /// **Current Setting: false** = All models use Together.ai (recommended for reliability)
    /// 
    /// To switch back to LlamaStack for Llama models:
    /// 1. Change this to `true`
    /// 2. Ensure LlamaStack server is running on localhost:8321
    /// 3. Configure server with higher token limits if needed
    private let useLlamaStackForLlamaModels: Bool = false
    
    // MARK: - Optimization Configuration
    /// API call optimization settings to prevent multiple redundant calls
    /// 
    /// **BEFORE OPTIMIZATION**: Up to 10 API calls per user message
    /// - Initial call: 1
    /// - Retry attempts: 3
    /// - Validation retries: 3  
    /// - Error retries: 3
    /// **Total**: 1 + 3 + 3 + 3 = 10 calls
    /// 
    /// **AFTER OPTIMIZATION**: Maximum 2 API calls per user message
    /// - Initial call: 1
    /// - Retry attempts: 1 (only for empty/severely truncated responses or network errors)
    /// **Total**: 1 + 1 = 2 calls
    private let maxRetryAttempts: Int = 1
    private let minimumResponseLength: Int = 50 // Chars below this trigger retry
    
    // Available models (ordered by cost - cheapest first) - Legacy, now using aiProviderManager.getAllModels()
    let availableModels = [
        "deepseek-ai/DeepSeek-R1-Distill-Llama-70B-free", // FREE - DeepSeek R1 reasoning model
        "meta-llama/Llama-3.3-70B-Instruct-Turbo-Free", // FREE - Latest Llama 3.3 70B
        "meta-llama/Meta-Llama-3-8B-Instruct-Lite",     // $0.10/1M - CHEAPEST paid
        "meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo",  // $0.18/1M - Good balance
        "Qwen/Qwen2.5-7B-Instruct-Turbo",               // $0.30/1M - Fastest Qwen
        "Qwen/Qwen2.5-Coder-32B-Instruct"               // $0.80/1M - Advanced coding
    ]
    
    // MARK: - New Provider System Properties
    var allAvailableModels: [AIModel] {
        return aiProviderManager.getAllModels()
    }
    
    var modelsByProvider: [String: [AIModel]] {
        return aiProviderManager.getModelsByProvider()
    }
    
    var currentProvider: AIProvider? {
        return aiProviderManager.currentProvider
    }
    
    // Callbacks for WebView interaction
    var onInsertCode: ((String) -> Void)?
    var onRunScene: (() -> Void)?
    var onDescribeScene: ((String) -> Void)?
    
    init() {
        print("🚀 ChatViewModel initialization starting...")
        
        // Initialize LlamaStackClient for meta-llama models
        self.inference = RemoteInference(
            url: URL(string: "https://llama-stack.together.ai")!,
            apiKey: DEFAULT_API_KEY
        )
        
        // Initialize AIProxy for Together.ai (Qwen/DeepSeek models)
        self.togetherAIService = AIProxy.togetherAIDirectService(
            unprotectedAPIKey: DEFAULT_API_KEY
        )
        
        print("📚 Setting up library manager and AI providers...")
        setupInitialMessage()
        setupDefaultSystemPrompt()
        loadSettings()
        
        print("✅ ChatViewModel initialization complete")
        print("🔑 Current Together.ai API key status: \(aiProviderManager.getAPIKey(for: "Together.ai") == "changeMe" ? "NOT_CONFIGURED" : "CONFIGURED")")
    }
    
    private func setupInitialMessage() {
        var welcomeContent = library3DManager.getWelcomeMessage()
        
        // Check if API key is configured
        let currentAPIKey = aiProviderManager.getAPIKey(for: "Together.ai")
        if currentAPIKey == "changeMe" {
            welcomeContent += "\n\n⚠️ **Setup Required**: Please configure your Together.ai API key in Settings (gear icon) to start chatting. Get your free API key at https://api.together.ai/settings/api-keys"
        }
        
        let welcomeMessage = ChatMessage(
            id: UUID().uuidString,
            content: welcomeContent,
            isUser: false,
            timestamp: Date()
        )
        messages.append(welcomeMessage)
    }
    
    private func setupDefaultSystemPrompt() {
        // Use the selected library's system prompt as the default
        systemPrompt = library3DManager.getSystemPrompt()
    }
    
    func updateAPIKey(_ newKey: String) {
        apiKey = newKey
        // Reinitialize both legacy services with new API key
        togetherAIService = AIProxy.togetherAIDirectService(
            unprotectedAPIKey: apiKey
        )
        // Reinitialize LlamaStackClient inference with new API key
        inference = RemoteInference(
            url: URL(string: "https://llama-stack.together.ai")!,
            apiKey: apiKey
        )
        
        // Also update Together.ai provider in the new system (backwards compatibility)
        aiProviderManager.setAPIKey(for: "Together.ai", key: newKey)
    }
    
    // MARK: - New Provider System Methods
    
    func setAPIKey(for provider: String, key: String) {
        aiProviderManager.setAPIKey(for: provider, key: key)
    }
    
    // MARK: - 3D Library System Methods
    
    func selectLibrary(id: String) {
        library3DManager.selectLibrary(id: id)
        
        // Update the welcome message and system prompt when library changes
        setupDefaultSystemPrompt()
        
        // Update the welcome message
        if !messages.isEmpty {
            messages[0] = ChatMessage(
                id: messages[0].id,
                content: library3DManager.getWelcomeMessage(),
                isUser: false,
                timestamp: messages[0].timestamp
            )
        }
        
        print("🎯 Switched to \(library3DManager.selectedLibrary.displayName)")
    }
    
    func selectLibrary(_ library: any Library3D) {
        library3DManager.selectLibrary(library)
        
        // Update the welcome message and system prompt when library changes
        setupDefaultSystemPrompt()
        
        // Update the welcome message
        if !messages.isEmpty {
            messages[0] = ChatMessage(
                id: messages[0].id,
                content: library3DManager.getWelcomeMessage(),
                isUser: false,
                timestamp: messages[0].timestamp
            )
        }
        
        print("🎯 Switched to \(library3DManager.selectedLibrary.displayName)")
    }
    
    func getCurrentLibrary() -> Library3DManager.AnyLibrary3D {
        return library3DManager.selectedLibrary
    }
    
    func getAvailableLibraries() -> [Library3DManager.AnyLibrary3D] {
        return library3DManager.availableLibraries
    }
    
    func getDefaultSceneCode() -> String {
        return library3DManager.getDefaultSceneCode()
    }
    
    func getPlaygroundTemplate() -> String {
        return library3DManager.getPlaygroundTemplate()
    }
    
    func getCodeLanguage() -> CodeLanguage {
        return library3DManager.getCodeLanguage()
    }
    
    func getAPIKey(for provider: String) -> String {
        return aiProviderManager.getAPIKey(for: provider)
    }
    
    func getCurrentProvider() -> AIProvider? {
        return aiProviderManager.currentProvider
    }
    
    func setCurrentProvider(_ provider: AIProvider) {
        aiProviderManager.setCurrentProvider(provider)
    }
    
    func isProviderConfigured(_ provider: String) -> Bool {
        return aiProviderManager.isProviderConfigured(provider)
    }
    
    func getConfiguredProviders() -> [AIProvider] {
        return aiProviderManager.getConfiguredProviders()
    }
    
    
    func sendMessage(_ text: String, currentCode: String? = nil) {
        let userMessage = ChatMessage(
            id: UUID().uuidString,
            content: text,
            isUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)
        
        Task {
            await processUserMessage(text, currentCode: currentCode)
        }
    }
    
    private func processUserMessage(_ text: String, currentCode: String?) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Create system prompt with context
            let fullSystemPrompt = createSystemPrompt(currentCode: currentCode)
            
            // Use simple inference for chat
            let response = try await callLlamaInference(userMessage: text, systemPrompt: fullSystemPrompt)
            
            // Process response for potential actions
            let processedResponse = processResponseForActions(response)
            
            let assistantMessage = ChatMessage(
                id: UUID().uuidString,
                content: processedResponse,
                isUser: false,
                timestamp: Date()
            )
            messages.append(assistantMessage)
            
        } catch {
            // Provide user-friendly error messages for common issues
            if let providerError = error as? AIProviderError {
                switch providerError {
                case .configurationError(let message):
                    if message.contains("API key not configured") {
                        errorMessage = "⚠️ API Key Required: Please configure your Together.ai API key in Settings (gear icon). Get your free API key at https://api.together.ai/settings/api-keys"
                    } else {
                        errorMessage = "Configuration Error: \(message)"
                    }
                default:
                    errorMessage = "Provider Error: \(providerError.localizedDescription)"
                }
            } else if error.localizedDescription.contains("Invalid API key") {
                errorMessage = "⚠️ Invalid API Key: Please check your Together.ai API key in Settings (gear icon). Get your API key at https://api.together.ai/settings/api-keys"
            } else if error.localizedDescription.contains("401") {
                errorMessage = "⚠️ Authentication Failed: Please verify your API key in Settings (gear icon). Make sure you're using a valid Together.ai API key."
            } else {
                errorMessage = "Failed to get response: \(error.localizedDescription)"
            }
            print("Chat error: \(error)")
        }
        
        isLoading = false
    }
    
    private func createSystemPrompt(currentCode: String?) -> String {
        // Use library-specific prompt with context
        let prompt = library3DManager.getLibrarySpecificPrompt(
            for: "", // No specific user message for system prompt
            currentCode: currentCode
        )
        
        print("System Prompt (\(library3DManager.selectedLibrary.displayName)): \(prompt.prefix(200))...")
        return prompt
    }
    
    private func callLlamaInference(userMessage: String, systemPrompt: String) async throws -> String {
        print("🎯 Using selected model: \(selectedModel)")
        
        // Always try new provider system first (it has better error handling)
        if let provider = aiProviderManager.getProvider(for: selectedModel) {
            print("📍 Routing to: New Provider System (\(provider.name))")
            do {
                return try await callNewProviderSystem(userMessage: userMessage, systemPrompt: systemPrompt)
            } catch {
                // If it's a configuration error, don't fall back - show helpful error
                if let providerError = error as? AIProviderError,
                   case .configurationError = providerError {
                    throw error // Re-throw to show user-friendly message
                }
                // For other errors, we can fall back to legacy system
                print("⚠️ New provider system failed, trying legacy: \(error)")
            }
        }
        
        // Fallback to legacy system only for non-configuration errors
        print("🔧 LlamaStack toggle: \(useLlamaStackForLlamaModels ? "ENABLED" : "DISABLED (using Together.ai for all)")")
        
        // Route to appropriate service based on configuration toggle
        if useLlamaStackForLlamaModels && selectedModel.contains("meta-llama") {
            // Use LlamaStackClient for Llama models (when toggle is enabled)
            print("📍 Routing to: LlamaStackClient (local)")
            return try await callLlamaStackModel(userMessage: userMessage, systemPrompt: systemPrompt)
        } else {
            // Use AIProxy + Together.ai for ALL models (default behavior)
            print("📍 Routing to: Together.ai (cloud)")
            return try await callTogetherAIModel(userMessage: userMessage, systemPrompt: systemPrompt)
        }
    }
    
    private func callNewProviderSystem(userMessage: String, systemPrompt: String) async throws -> String {
        print("🔧 New Provider System called with model: \(selectedModel)")
        print("🔑 Current API key status: \(aiProviderManager.getAPIKey(for: "Together.ai") == "changeMe" ? "NOT_CONFIGURED (changeMe)" : "CONFIGURED")")
        
        let messages = [
            AIMessage(content: systemPrompt, role: .system),
            AIMessage(content: userMessage, role: .user)
        ]
        
        print("📤 Sending request to AIProviderManager...")
        let stream = try await aiProviderManager.generateResponse(
            messages: messages,
            modelId: selectedModel,
            temperature: temperature,
            topP: topP
        )
        
        var fullResponse = ""
        print("📥 Receiving streaming response...")
        
        for try await chunk in stream {
            fullResponse += chunk
        }
        
        print("✅ New provider system response complete, length: \(fullResponse.count)")
        return fullResponse
    }
    
    func getModelDisplayName(_ modelId: String) -> String {
        // Try new provider system first
        if let model = aiProviderManager.getModel(id: modelId) {
            return model.displayName
        }
        
        // Fallback to legacy system
        switch modelId {
        case "deepseek-ai/DeepSeek-R1-Distill-Llama-70B-free":
            return "DeepSeek R1 70B (Free)"
        case "meta-llama/Llama-3.3-70B-Instruct-Turbo-Free":
            return "Llama 3.3 70B (Free)"
        case "meta-llama/Meta-Llama-3-8B-Instruct-Lite":
            return "Llama 3 8B Lite"
        case "meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo":
            return "Llama 3.1 8B Turbo"
        case "Qwen/Qwen2.5-7B-Instruct-Turbo":
            return "Qwen 2.5 7B Turbo"
        case "Qwen/Qwen2.5-Coder-32B-Instruct":
            return "Qwen 2.5 Coder 32B"
        default:
            return modelId
        }
    }
    
    func getModelDescription(_ modelId: String) -> String {
        // Try new provider system first
        if let model = aiProviderManager.getModel(id: modelId) {
            let pricing = model.pricing.isEmpty ? "" : " - \(model.pricing)"
            return "\(model.description)\(pricing)"
        }
        
        // Fallback to legacy system
        switch modelId {
        case "deepseek-ai/DeepSeek-R1-Distill-Llama-70B-free":
            return "FREE - Advanced reasoning & coding"
        case "meta-llama/Llama-3.3-70B-Instruct-Turbo-Free":
            return "FREE - Latest large model"
        case "meta-llama/Meta-Llama-3-8B-Instruct-Lite":
            return "CHEAPEST - $0.10/1M tokens"
        case "meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo":
            return "Good balance - $0.18/1M tokens"
        case "Qwen/Qwen2.5-7B-Instruct-Turbo":
            return "Fast coding - $0.30/1M tokens"
        case "Qwen/Qwen2.5-Coder-32B-Instruct":
            return "Advanced coding - $0.80/1M tokens"
        default:
            return "Custom model"
        }
    }
    
    func getParameterDescription() -> String {
        switch (temperature, topP) {
        case (0.0...0.3, 0.1...0.5):
            return "Precise & Focused - Perfect for debugging"
        case (0.4...0.8, 0.6...0.9): 
            return "Balanced Creativity - Ideal for most scenes"
        case (0.9...2.0, 0.9...1.0):
            return "Experimental Mode - Maximum innovation"
        default:
            return "Custom Configuration"
        }
    }
    
    
    private func callLlamaStackModel(userMessage: String, systemPrompt: String) async throws -> String {
        let messages: [Components.Schemas.Message] = [
            .system(Components.Schemas.SystemMessage(
                role: .system,
                content: .case1(systemPrompt)
            )),
            .user(Components.Schemas.UserMessage(
                role: .user,
                content: .case1(userMessage)
            ))
        ]
        
        var fullResponse = ""
        
        print("🚀 Using LlamaStackClient for model: \(selectedModel)")
        print("🔧 LlamaStack config: stream=true (using server default max_tokens)")
        
        let streamingRequest = Components.Schemas.ChatCompletionRequest(
            model_id: selectedModel,
            messages: messages,
            stream: true
        )
        
        let stream = try await inference.chatCompletion(request: streamingRequest)
        print("✅ LlamaStack stream created successfully")
        
        // Standard processing for Llama models with error handling
        do {
            for try await chunk in stream {
                print("📦 Processing chunk from LlamaStack...")
                do {
                    let chunkResult = try processChunk(chunk, modelId: selectedModel)
                    fullResponse += chunkResult
                    if !chunkResult.isEmpty {
                        print("📦 Added chunk content: '\(chunkResult.prefix(20))...' (total: \(fullResponse.count))")
                    }
                } catch {
                    print("⚠️ Error processing individual chunk: \(error)")
                    print("🔍 DEBUG: Problematic chunk: \(chunk)")
                    // Continue processing other chunks
                }
            }
        } catch {
            print("❌ Error in stream processing: \(error)")
            throw error
        }
        
        print("✅ Stream completed, response length: \(fullResponse.count)")
        
        // Check if we hit token limits or other issues
        if fullResponse.isEmpty {
            print("⚠️ WARNING: LlamaStack returned empty response - this might indicate an API issue")
        } else if fullResponse.count < 500 {
            print("⚠️ WARNING: Response seems short (\(fullResponse.count) chars) - might be truncated")
        }
        return fullResponse
    }
    
    private func callTogetherAIModel(userMessage: String, systemPrompt: String) async throws -> String {
        // OPTIMIZATION: Using configurable retry count to minimize multiple API calls
        return try await callTogetherAIModelWithRetry(userMessage: userMessage, systemPrompt: systemPrompt, maxRetries: maxRetryAttempts)
    }
    
    private func callTogetherAIModelWithRetry(userMessage: String, systemPrompt: String, maxRetries: Int) async throws -> String {
        print("🚀 Using AIProxy + Together.ai for model: \(selectedModel) (retry attempts remaining: \(maxRetries))")
        
        // Create messages for AIProxy format
        let messages = [
            TogetherAIMessage(content: systemPrompt, role: .system),
            TogetherAIMessage(content: userMessage, role: .user)
        ]
        
        // Enhanced request body with explicit parameters for better completion
        // Note: Now all models use Together.ai which supports maxTokens parameter
        let requestBody = TogetherAIChatCompletionRequestBody(
            messages: messages,
            model: selectedModel,  // Use model name as-is (NIM endpoint should work)
            stream: true,
            temperature: temperature,
            topP: topP
            // TODO: Add maxTokens parameter when AIProxy supports it
            // maxTokens: 4000
        )
        
        print("✅ Created Together.ai request for model: \(selectedModel)")
        print("🔧 Together.ai config: stream=true, temperature=\(temperature), top-p=\(topP)")
        
        // Use streaming chat completion with enhanced monitoring
        var fullResponse = ""
        var chunkCount = 0
        var lastChunkTime = Date()
        let streamStartTime = Date()
        
        do {
            let streamingResponse = try await togetherAIService.streamingChatCompletionRequest(body: requestBody)
            print("✅ Together.ai stream created successfully")
            
            for try await chunk in streamingResponse {
                chunkCount += 1
                let currentTime = Date()
                let timeSinceLastChunk = currentTime.timeIntervalSince(lastChunkTime)
                lastChunkTime = currentTime
                
                if let content = chunk.choices.first?.delta.content {
                    fullResponse += content
                    print("📦 Chunk \(chunkCount): '\(content.prefix(30))...' (+\(String(format: "%.2f", timeSinceLastChunk))s)")
                }
                
                // Check for completion indicators in chunk
                if let finishReason = chunk.choices.first?.finishReason {
                    print("🏁 Stream finish reason: \(finishReason)")
                    break
                }
                
                // Timeout detection - if no chunks for 30 seconds, something's wrong
                if timeSinceLastChunk > 30.0 {
                    print("⚠️ Chunk timeout detected - stream may be stalled")
                    throw StreamError.chunkTimeout
                }
            }
            
            let totalStreamTime = Date().timeIntervalSince(streamStartTime)
            print("✅ Together.ai stream completed: \(chunkCount) chunks, \(fullResponse.count) chars, \(String(format: "%.2f", totalStreamTime))s")
            
            // OPTIMIZATION: Simplified validation - only reject truly empty or severely truncated responses
            if fullResponse.isEmpty {
                print("❌ Empty response - critical failure")
                if maxRetries > 0 {
                    print("🔄 Retrying due to empty response...")
                    try await Task.sleep(nanoseconds: 2_000_000_000) // 2 second delay for empty responses
                    return try await callTogetherAIModelWithRetry(
                        userMessage: userMessage, 
                        systemPrompt: systemPrompt, 
                        maxRetries: maxRetries - 1
                    )
                } else {
                    throw APIError.emptyResponse
                }
            } else if fullResponse.count < minimumResponseLength {
                print("⚠️ Very short response (\(fullResponse.count) chars) - likely truncated: '\(fullResponse)'")
                if maxRetries > 0 {
                    print("🔄 Retrying due to truncated response...")
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                    return try await callTogetherAIModelWithRetry(
                        userMessage: userMessage, 
                        systemPrompt: systemPrompt, 
                        maxRetries: maxRetries - 1
                    )
                } else {
                    print("⚠️ Using short response (no retries left)")
                    return fullResponse
                }
            } else {
                print("✅ Response validation passed (\(fullResponse.count) chars)")
                return fullResponse
            }
            
        } catch {
            print("❌ Together.ai error: \(error)")
            print("Error details: \(error.localizedDescription)")
            
            // OPTIMIZATION: Only retry on critical network/server errors, not client errors (400, 401, etc.)
            let shouldRetry = shouldRetryError(error)
            if maxRetries > 0 && shouldRetry {
                print("🔄 Retrying request due to retriable error...")
                // Exponential backoff: longer delay for retries
                let delay = Double(2 - maxRetries + 1) * 2.0 // 2s, 4s delays
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                return try await callTogetherAIModelWithRetry(
                    userMessage: userMessage, 
                    systemPrompt: systemPrompt, 
                    maxRetries: maxRetries - 1
                )
            } else {
                print("❌ Not retrying: \(shouldRetry ? "No retries left" : "Error not retriable")")
                throw error
            }
        }
    }
    
    
    private func processChunk(_ chunk: Components.Schemas.ChatCompletionResponseStreamChunk, modelId: String) throws -> String {
        print("🔍 DEBUG: Processing chunk for model: \(modelId)")
        print("🔍 DEBUG: Chunk structure: \(chunk)")
        
        // Check for stop reasons and completion signals
        if let stopReason = chunk.event.stop_reason {
            print("🏁 Stream stop reason: \(stopReason)")
            if case .out_of_tokens = stopReason {
                print("⚠️ WARNING: Response truncated due to token limit - consider increasing max_tokens")
            }
        }
        
        if case .complete = chunk.event.event_type {
            print("🏁 Stream marked as complete")
            
            // Log token usage if available
            if let metrics = chunk.metrics {
                for metric in metrics {
                    if case .case1(let value) = metric.value {
                        print("📊 \(metric.metric): \(value)")
                    }
                }
            }
        }
        
        // Try to access the event field with error handling
        do {
            switch (chunk.event.delta) {
            case .text(let textContent):
                print("✅ Found text content: '\(textContent.text.prefix(50))...'")
                return textContent.text
            case .image(_):
                print("📸 Found image content (skipping)")
                return "" // Handle image content if needed
            case .tool_call(_):
                print("🔧 Found tool call content (skipping)")
                return "" // Handle tool calls if needed
            }
        } catch {
            print("❌ Error accessing chunk.event.delta: \(error)")
            print("🔍 DEBUG: Let's inspect the chunk structure differently...")
            
            // Try alternative approach - maybe the structure is different
            print("🔍 DEBUG: Chunk raw: \(String(describing: chunk))")
            
            // For now, return empty string to prevent crash
            return ""
        }
    }
    
    private func processResponseForActions(_ response: String) -> String {
        var processedResponse = response
        
        print("=== PROCESSING AI RESPONSE (\(selectedModel)) ===")
        print("Full response length: \(response.count)")
        print("FULL RESPONSE: \(response)")
        print("Looking for [INSERT_CODE] tags...")
        
        // Debug: Check if the response contains the tags at all
        if response.contains("[INSERT_CODE]") {
            print("✅ Found [INSERT_CODE] in response")
        } else {
            print("❌ No [INSERT_CODE] found in response")
        }
        
        if response.contains("```javascript") {
            print("✅ Found ```javascript in response")
        } else if response.contains("```typescript") {
            print("✅ Found ```typescript in response")
        } else if response.contains("```js") {
            print("✅ Found ```js in response")
        } else if response.contains("```") {
            print("✅ Found ``` blocks in response")
        } else {
            print("❌ No code blocks found in response")
        }
        
        // ENHANCED STRING EXTRACTION - Handle multiple patterns for [INSERT_CODE]
        print("Using enhanced string extraction...")
        
        // Pattern 1: [INSERT_CODE]```javascript (direct)
        if let startIndex = response.range(of: "[INSERT_CODE]```javascript")?.upperBound {
            print("Found direct [INSERT_CODE]```javascript pattern")
            
            let remainingString = String(response[startIndex...])
            if let endIndex = remainingString.range(of: "```")?.lowerBound {
                let codeRange = startIndex..<response.index(startIndex, offsetBy: remainingString.distance(from: remainingString.startIndex, to: endIndex))
                let extractedCode = String(response[codeRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                
                if !extractedCode.isEmpty {
                    print("✅ Extracted code using direct pattern method")
                    let correctedCode = fixBabylonJSCode(extractedCode)
                    processedResponse = processedResponse.replacingOccurrences(of: "[INSERT_CODE]```javascript", with: "✅ Code extracted!")
                    processedResponse = processedResponse.replacingOccurrences(of: "```", with: "")
                    onInsertCode?(correctedCode)
                    return processedResponse.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        
        // Pattern 2: ACTUAL Qwen format: [INSERT_CODE]\n```javascript\n...code...\n[/INSERT_CODE] (no closing ```)
        if let insertCodeStart = response.range(of: "[INSERT_CODE]"),
           let insertCodeEnd = response.range(of: "[/INSERT_CODE]") {
            print("Found complete [INSERT_CODE]...[/INSERT_CODE] block")
            
            // Extract everything between [INSERT_CODE] and [/INSERT_CODE]
            let blockRange = insertCodeStart.upperBound..<insertCodeEnd.lowerBound
            let fullBlock = String(response[blockRange])
            
            print("🔍 Full INSERT_CODE block:")
            print("'\(fullBlock)'")
            
            // Now find the ```javascript... part within this block (NO closing ``` expected)
            print("🔍 Looking for ```javascript in block...")
            if let jsStart = fullBlock.range(of: "```javascript") {
                print("✅ Found ```javascript at position in block")
                
                // Extract everything after ```javascript until the end of the block
                let afterJSStart = jsStart.upperBound
                let extractedCode = String(fullBlock[afterJSStart...]).trimmingCharacters(in: .whitespacesAndNewlines)
                
                print("🔍 Raw extracted code length: \(extractedCode.count)")
                print("🔍 Raw extracted code preview: '\(extractedCode.prefix(100))...'")
                
                if !extractedCode.isEmpty {
                    print("✅ Extracted code using ACTUAL Qwen pattern method")
                    print("Code length: \(extractedCode.count)")
                    print("Code preview: \(extractedCode.prefix(300))...")
                    
                    let correctedCode = fixBabylonJSCode(extractedCode)
                    processedResponse = processedResponse.replacingOccurrences(of: "[INSERT_CODE]", with: "✅ Code extracted!")
                    processedResponse = processedResponse.replacingOccurrences(of: "[/INSERT_CODE]", with: "")
                    processedResponse = processedResponse.replacingOccurrences(of: "```javascript", with: "")
                    processedResponse = processedResponse.replacingOccurrences(of: "```", with: "")
                    onInsertCode?(correctedCode)
                    return processedResponse.trimmingCharacters(in: .whitespacesAndNewlines)
                } else {
                    print("⚠️ Extracted code is empty after trimming")
                }
            } else {
                print("❌ Could not find ```javascript in block")
                // Print debug info
                print("🔍 Block starts with: '\(fullBlock.prefix(50))...'")
                print("🔍 Block contains 'javascript': \(fullBlock.contains("javascript"))")
                print("🔍 Block contains '```': \(fullBlock.contains("```"))")
            }
        }
        
        // ALWAYS look for regular code blocks as primary method for ALL models
        print("Looking for regular code blocks...")
        
        // DEBUG: Show actual response format around code blocks
        if let jsIndex = response.range(of: "```javascript") {
            let start = max(response.startIndex, response.index(jsIndex.lowerBound, offsetBy: -20))
            let end = min(response.endIndex, response.index(jsIndex.upperBound, offsetBy: 100))
            print("🔍 RESPONSE DEBUG: Context around ```javascript:")
            print("'\(response[start..<end])'")
        }
        
        // More flexible regex that handles text around code blocks
        let codeBlockRegex = try! NSRegularExpression(pattern: "```(?:javascript|typescript|js|ts)?\\s*\\n?([\\s\\S]+?)\\n?```", options: [.dotMatchesLineSeparators])
        let codeMatches = codeBlockRegex.matches(in: response, options: [], range: NSRange(response.startIndex..., in: response))
        
        print("Found \(codeMatches.count) regular code blocks for model: \(selectedModel)")
        
        for (index, match) in codeMatches.enumerated() {
            if let codeRange = Range(match.range(at: 1), in: response) {
                let code = String(response[codeRange])
                print("🔍 QWEN DEBUG: Code block \(index + 1) from \(selectedModel):")
                print("🔍 QWEN DEBUG: Full code content: \(code)")
                print("🔍 QWEN DEBUG: Code length: \(code.count)")
                print("🔍 QWEN DEBUG: Contains createScene: \(code.contains("createScene"))")
                print("🔍 QWEN DEBUG: Contains BABYLON: \(code.contains("BABYLON"))")
                print("🔍 QWEN DEBUG: Contains Scene: \(code.contains("Scene"))")
                print("🔍 QWEN DEBUG: Contains scene: \(code.contains("scene"))")
                print("🔍 QWEN DEBUG: Contains camera: \(code.contains("camera"))")
                print("🔍 QWEN DEBUG: Contains light: \(code.contains("light"))")
                print("🔍 QWEN DEBUG: Contains mesh: \(code.contains("mesh"))")
                print("🔍 QWEN DEBUG: Contains engine: \(code.contains("engine"))")
                print("🔍 QWEN DEBUG: Contains canvas: \(code.contains("canvas"))")
                print("🔍 QWEN DEBUG: Contains const: \(code.contains("const "))")
                print("🔍 QWEN DEBUG: Contains function: \(code.contains("function"))")
                print("🔍 QWEN DEBUG: Contains var: \(code.contains("var "))")
                print("🔍 QWEN DEBUG: Contains let: \(code.contains("let "))")
                
                // Accept ANY code block that looks like Babylon.js code - be very flexible
                let isBabylonCode = code.contains("createScene") || 
                                   code.contains("BABYLON") || 
                                   code.contains("Scene") || 
                                   code.contains("const scene") || 
                                   code.contains("scene") ||
                                   code.contains("camera") ||
                                   code.contains("light") ||
                                   code.contains("mesh") ||
                                   code.contains("engine") ||
                                   code.contains("canvas")
                
                print("🔍 QWEN DEBUG: isBabylonCode = \(isBabylonCode)")
                
                if isBabylonCode {
                    print("✅ Found Babylon.js code in block \(index + 1) from model \(selectedModel)!")
                    print("=== REGULAR CODE BLOCK EXTRACTION ===")
                    print("EXTRACTED CODE (full):")
                    print(code)
                    print("=== END EXTRACTED CODE ===")
                    
                    // Auto-fix common Babylon.js API mistakes
                    let correctedCode = fixBabylonJSCode(code)
                    if correctedCode != code {
                        print("🔧 Code was auto-corrected for common API issues")
                        print("=== CORRECTED CODE (full) ===")
                        print(correctedCode)
                        print("=== END CORRECTED CODE ===")
                    } else {
                        print("ℹ️ No corrections needed - code looks good")
                    }
                    
                    // Clean up the response text for all code block types
                    processedResponse = processedResponse.replacingOccurrences(of: "```javascript", with: "✅ Code extracted and ready!")
                    processedResponse = processedResponse.replacingOccurrences(of: "```typescript", with: "✅ Code extracted and ready!")
                    processedResponse = processedResponse.replacingOccurrences(of: "```js", with: "✅ Code extracted and ready!")
                    processedResponse = processedResponse.replacingOccurrences(of: "```ts", with: "✅ Code extracted and ready!")
                    processedResponse = processedResponse.replacingOccurrences(of: "```", with: "")
                    
                    print("🎯 Calling onInsertCode for model: \(selectedModel)")
                    onInsertCode?(correctedCode)
                    break
                }
            }
        }
        
        // Final check if no code found anywhere
        if codeMatches.isEmpty && !response.contains("[INSERT_CODE]") {
            print("❌ No code blocks found at all in response from model: \(selectedModel)")
        } else if !codeMatches.isEmpty {
            // If we found code blocks but none were injected, let's try a more permissive approach
            print("⚠️ Found \(codeMatches.count) code blocks but none were injected. Trying permissive mode for \(selectedModel)...")
            
            for (index, match) in codeMatches.enumerated() {
                if let codeRange = Range(match.range(at: 1), in: response) {
                    let code = String(response[codeRange])
                    print("🔄 FALLBACK DEBUG: Examining code block \(index + 1)")
                    print("🔄 FALLBACK DEBUG: Code content: \(code)")
                    
                    // VERY permissive - inject any code that looks like JavaScript
                    let isJavaScriptCode = code.contains("const ") || 
                                          code.contains("function") || 
                                          code.contains("var ") || 
                                          code.contains("let ") ||
                                          code.contains("=") ||
                                          code.contains("{") ||
                                          code.contains(";")
                    
                    print("🔄 FALLBACK DEBUG: isJavaScriptCode = \(isJavaScriptCode)")
                    
                    if isJavaScriptCode {
                        print("🔄 FALLBACK: Injecting JavaScript code block \(index + 1) from model \(selectedModel)")
                        print("FALLBACK CODE: \(code)")
                        
                        let correctedCode = fixBabylonJSCode(code)
                        processedResponse = processedResponse.replacingOccurrences(of: "```", with: "✅ Code extracted (fallback mode)!")
                        
                        print("🎯 FALLBACK: Calling onInsertCode for model: \(selectedModel)")
                        onInsertCode?(correctedCode)
                        break
                    } else if selectedModel.contains("Qwen") && code.count > 10 {
                        // ULTRA-AGGRESSIVE for Qwen models - inject ANY non-empty code block
                        print("🚨 ULTRA-FALLBACK for Qwen: Injecting ANY code block \(index + 1)")
                        print("🚨 ULTRA-FALLBACK CODE: \(code)")
                        
                        let correctedCode = fixBabylonJSCode(code)
                        processedResponse = processedResponse.replacingOccurrences(of: "```", with: "✅ Code extracted (ultra-fallback)!")
                        
                        print("🎯 ULTRA-FALLBACK: Calling onInsertCode for Qwen model")
                        onInsertCode?(correctedCode)
                        break
                    }
                }
            }
        }
        
        // Look for run scene commands
        if response.contains("[RUN_SCENE]") {
            print("✅ Found [RUN_SCENE] command from model: \(selectedModel)")
            processedResponse = processedResponse.replacingOccurrences(of: "[RUN_SCENE]", with: "")
            print("🎬 Calling onRunScene for model: \(selectedModel)")
            onRunScene?()
        } else {
            print("ℹ️ No [RUN_SCENE] command found in response from model: \(selectedModel)")
        }
        
        return processedResponse.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func fixBabylonJSCode(_ code: String) -> String {
        var fixedCode = code
        
        // Fix common API mistakes
        print("🔧 Applying Babylon.js API fixes...")
        
        // CRITICAL: Remove RUN_SCENE and INSERT_CODE tags that cause JavaScript errors
        fixedCode = fixedCode.replacingOccurrences(of: "[RUN_SCENE]", with: "")
        fixedCode = fixedCode.replacingOccurrences(of: "[/RUN_SCENE]", with: "")
        fixedCode = fixedCode.replacingOccurrences(of: "[INSERT_CODE]", with: "")
        fixedCode = fixedCode.replacingOccurrences(of: "[/INSERT_CODE]", with: "")
        
        // Fix incorrect MeshBuilder references
        fixedCode = fixedCode.replacingOccurrences(of: "BABYLON.Mesh-Builder", with: "BABYLON.MeshBuilder")
        fixedCode = fixedCode.replacingOccurrences(of: "BABYLON.MeshBuilder.CreateCube", with: "BABYLON.MeshBuilder.CreateBox")
        fixedCode = fixedCode.replacingOccurrences(of: "BABYLON.MeshBuilder.CreateRing", with: "BABYLON.MeshBuilder.CreateTorus") // Ring doesn't exist, use Torus
        
        // Fix deprecated or incorrect methods
        fixedCode = fixedCode.replacingOccurrences(of: ".attachControl(", with: ".attachControls(")
        
        // Fix material issues
        fixedCode = fixedCode.replacingOccurrences(of: "BABYLON.Material", with: "BABYLON.StandardMaterial")
        
        // Fix camera issues
        fixedCode = fixedCode.replacingOccurrences(of: "BABYLON.Camera", with: "BABYLON.FreeCamera")
        
        // Fix light issues  
        fixedCode = fixedCode.replacingOccurrences(of: "BABYLON.Light", with: "BABYLON.HemisphericLight")
        
        // CRITICAL: Remove problematic canvas/engine creation code
        print("🔧 Removing problematic canvas/engine creation...")
        
        // Remove canvas creation
        if fixedCode.contains("document.createElement(\"canvas\")") {
            // Remove the canvas creation line and related code
            fixedCode = fixedCode.replacingOccurrences(of: "const canvas = document.createElement(\"canvas\");", with: "")
            fixedCode = fixedCode.replacingOccurrences(of: "document.body.appendChild(canvas);", with: "")
            print("  - Removed canvas creation (using existing playground canvas)")
        }
        
        // Remove engine creation
        if fixedCode.contains("new BABYLON.Engine(canvas, true)") {
            fixedCode = fixedCode.replacingOccurrences(of: "const engine = new BABYLON.Engine(canvas, true);", with: "")
            print("  - Removed engine creation (using existing playground engine)")
        }
        
        // Remove engine render loop
        if fixedCode.contains("engine.runRenderLoop") {
            let renderLoopPattern = "engine\\.runRenderLoop\\(\\(\\) => \\{[\\s\\S]*?\\}\\);"
            fixedCode = fixedCode.replacingOccurrences(of: renderLoopPattern, 
                                                        with: "", 
                                                        options: .regularExpression)
            print("  - Removed render loop (playground handles rendering)")
        }
        
        // Clean up any empty lines left behind
        fixedCode = fixedCode.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        fixedCode = fixedCode.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Log what was fixed
        if fixedCode != code {
            print("🔧 Applied fixes:")
            if code.contains("[RUN_SCENE]") { print("  - Removed [RUN_SCENE] tags") }
            if code.contains("[INSERT_CODE]") { print("  - Removed [INSERT_CODE] tags") }
            if code.contains("Mesh-Builder") { print("  - Fixed Mesh-Builder → MeshBuilder") }
            if code.contains("CreateCube") { print("  - Fixed CreateCube → CreateBox") }
            if code.contains("CreateRing") { print("  - Fixed CreateRing → CreateTorus") }
            if code.contains("attachControl(") { print("  - Fixed attachControl → attachControls") }
            if code.contains("document.createElement") { print("  - Removed canvas creation") }
            if code.contains("new BABYLON.Engine") { print("  - Removed engine creation") }
            if code.contains("runRenderLoop") { print("  - Removed render loop") }
        }
        
        return fixedCode
    }
    
    // MARK: - Settings Persistence
    
    /// Save current settings to UserDefaults
    func saveSettings() {
        print("💾 Saving settings to UserDefaults...")
        
        // Save legacy API key for backwards compatibility
        UserDefaults.standard.set(apiKey, forKey: "XRAiAssistant_APIKey")
        
        // Save general settings
        UserDefaults.standard.set(systemPrompt, forKey: "XRAiAssistant_SystemPrompt")
        UserDefaults.standard.set(selectedModel, forKey: "XRAiAssistant_SelectedModel")
        UserDefaults.standard.set(temperature, forKey: "XRAiAssistant_Temperature")
        UserDefaults.standard.set(topP, forKey: "XRAiAssistant_TopP")
        
        // Update AI services with new API key if it changed
        updateAPIKey(apiKey)
        
        // The AIProviderManager handles its own persistence automatically
        
        print("✅ Settings saved successfully")
    }
    
    /// Load settings from UserDefaults
    private func loadSettings() {
        print("📂 Loading settings from UserDefaults...")
        
        // Load API key (keep default if not found)
        let savedAPIKey = UserDefaults.standard.string(forKey: "XRAiAssistant_APIKey") ?? DEFAULT_API_KEY
        if savedAPIKey != DEFAULT_API_KEY {
            apiKey = savedAPIKey
            // Migrate legacy API key to new provider system
            aiProviderManager.setAPIKey(for: "Together.ai", key: savedAPIKey)
            print("🔑 Loaded and migrated saved API key: \(String(savedAPIKey.prefix(10)))...")
        } else {
            // Check if the new provider system has a key
            let newProviderKey = aiProviderManager.getAPIKey(for: "Together.ai")
            if newProviderKey != "changeMe" {
                // Use key from new provider system
                apiKey = newProviderKey
                print("🔑 Using API key from new provider system: \(String(newProviderKey.prefix(10)))...")
            } else {
                // Make sure the new provider system knows about the default key
                aiProviderManager.setAPIKey(for: "Together.ai", key: DEFAULT_API_KEY)
                print("🔑 Using default API key")
            }
        }
        
        // Load system prompt (keep default if not found)
        if let savedSystemPrompt = UserDefaults.standard.string(forKey: "XRAiAssistant_SystemPrompt"), !savedSystemPrompt.isEmpty {
            systemPrompt = savedSystemPrompt
            print("📝 Loaded custom system prompt (\(savedSystemPrompt.count) characters)")
        }
        
        // Load model selection
        if let savedModel = UserDefaults.standard.string(forKey: "XRAiAssistant_SelectedModel"), 
           availableModels.contains(savedModel) {
            selectedModel = savedModel
            print("🤖 Loaded saved model: \(getModelDisplayName(savedModel))")
        }
        
        // Load AI parameters
        let savedTemperature = UserDefaults.standard.object(forKey: "XRAiAssistant_Temperature") as? Double
        if let savedTemperature = savedTemperature {
            temperature = savedTemperature
            print("🌡️ Loaded saved temperature: \(savedTemperature)")
        }
        
        let savedTopP = UserDefaults.standard.object(forKey: "XRAiAssistant_TopP") as? Double
        if let savedTopP = savedTopP {
            topP = savedTopP
            print("🎯 Loaded saved top-p: \(savedTopP)")
        }
        
        // Update AI services with loaded API key
        if apiKey != DEFAULT_API_KEY {
            updateAPIKey(apiKey)
        }
        
        print("✅ Settings loaded successfully")
    }
}

// MARK: - Supporting Types and Validation

enum StreamError: Error {
    case chunkTimeout
    case incompleteResponse
    case validationFailed
}

struct ResponseValidation {
    let isComplete: Bool
    let shouldRetry: Bool
    let issues: [String]
}

private func validateResponse(_ response: String, model: String) -> ResponseValidation {
    var issues: [String] = []
    var isComplete = true
    var shouldRetry = false
    
    // Basic completeness checks
    if response.isEmpty {
        issues.append("Empty response")
        isComplete = false
        shouldRetry = true
        return ResponseValidation(isComplete: false, shouldRetry: true, issues: issues)
    }
    
    // Check for minimum expected length (3D code should be substantial)
    if response.count < 100 {
        issues.append("Response too short (\(response.count) chars)")
        isComplete = false
        shouldRetry = true
    }
    
    // Check for expected Babylon.js patterns in response
    let hasBabylonCode = response.contains("BABYLON") || 
                        response.contains("createScene") ||
                        response.contains("```javascript") ||
                        response.contains("[INSERT_CODE]")
    
    if !hasBabylonCode {
        issues.append("Missing expected Babylon.js code patterns")
        isComplete = false
        shouldRetry = true
    }
    
    // Check for proper closure of code blocks
    if response.contains("[INSERT_CODE]") && !response.contains("[/INSERT_CODE]") {
        issues.append("Incomplete INSERT_CODE block")
        isComplete = false
        shouldRetry = true
    }
    
    if response.contains("```javascript") {
        let jsBlocks = response.components(separatedBy: "```javascript").count - 1
        let endBlocks = response.components(separatedBy: "```").count - 1 - jsBlocks
        if jsBlocks > endBlocks {
            issues.append("Unclosed code block")
            isComplete = false
            shouldRetry = true
        }
    }
    
    // Check for truncation indicators
    let truncationIndicators = ["...", "truncated", "incomplete", "cut off"]
    for indicator in truncationIndicators {
        if response.lowercased().contains(indicator.lowercased()) {
            issues.append("Contains truncation indicator: \(indicator)")
            isComplete = false
            shouldRetry = true
            break
        }
    }
    
    // Check if response ends abruptly (no proper sentence ending)
    let lastChars = String(response.suffix(10))
    if !lastChars.contains(".") && !lastChars.contains("!") && !lastChars.contains("?") && 
       !lastChars.contains("}") && !lastChars.contains("]") {
        issues.append("Response appears to end abruptly")
        isComplete = false
        shouldRetry = true
    }
    
    return ResponseValidation(isComplete: isComplete, shouldRetry: shouldRetry, issues: issues)
}

private func shouldRetryError(_ error: Error) -> Bool {
    let errorString = error.localizedDescription.lowercased()
    
    // OPTIMIZATION: More restrictive retry logic - only retry clear network/server issues
    // Don't retry client errors (400, 401, 403, 404) as they won't resolve with retry
    let networkErrors = ["timeout", "network", "connection failed"]
    let serverErrors = ["server error", "temporarily unavailable", "rate limit"]
    
    // Don't retry client errors that indicate API issues
    let clientErrors = ["400", "401", "403", "404", "invalid", "unauthorized", "forbidden"]
    
    // Check for client errors first - never retry these
    for clientError in clientErrors {
        if errorString.contains(clientError) {
            print("🚫 Client error detected, not retrying: \(clientError)")
            return false
        }
    }
    
    // Only retry clear network/server issues
    let shouldRetry = networkErrors.contains { errorString.contains($0) } ||
                     serverErrors.contains { errorString.contains($0) }
    
    print("📊 Retry decision for '\(errorString)': \(shouldRetry ? "RETRY" : "NO_RETRY")")
    return shouldRetry
}

// MARK: - Models

struct ChatMessage: Identifiable, Equatable {
    let id: String
    let content: String
    let isUser: Bool
    let timestamp: Date
}

enum ChatError: Error, LocalizedError {
    case sessionCreationFailed
    case invalidResponse
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .sessionCreationFailed:
            return "Failed to create agent session"
        case .invalidResponse:
            return "Invalid response from server"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}
