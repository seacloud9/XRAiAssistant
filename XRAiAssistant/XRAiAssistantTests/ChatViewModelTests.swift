import XCTest
@testable import XRAiAssistant

final class ChatViewModelTests: XCTestCase {
    
    var chatViewModel: ChatViewModel!
    
    override func setUpWithError() throws {
        chatViewModel = ChatViewModel()
    }
    
    override func tearDownWithError() throws {
        chatViewModel = nil
    }
    
    // MARK: - Response Validation Tests
    
    func testValidateCompleteResponse() {
        let completeResponse = """
        I'll create a colorful cube scene for you!
        
        [INSERT_CODE]
        ```javascript
        const createScene = () => {
            const scene = new BABYLON.Scene(engine);
            
            // Camera
            const camera = new BABYLON.FreeCamera("camera1", new BABYLON.Vector3(0, 5, -10), scene);
            camera.setTarget(BABYLON.Vector3.Zero());
            
            // Light
            const light = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(0, 1, 0), scene);
            
            // Cube
            const cube = BABYLON.MeshBuilder.CreateBox("cube", {size: 2}, scene);
            
            return scene;
        };
        
        const scene = createScene();
        ```
        [/INSERT_CODE]
        
        [RUN_SCENE]
        
        This creates a basic cube with proper lighting and camera setup.
        """
        
        let validation = ChatViewModelTests.validateResponse(completeResponse, model: "test")
        XCTAssertTrue(validation.isComplete)
        XCTAssertFalse(validation.shouldRetry)
        XCTAssertTrue(validation.issues.isEmpty)
    }
    
    func testValidateIncompleteResponse() {
        let incompleteResponse = """
        I'll create a cube scene for you!
        
        [INSERT_CODE]
        ```javascript
        const createScene = () => {
            const scene = new BABYLON.Scene(engine);
            
            // Camera
            const camera = new BABYLON.FreeCamera("camera1", new BABYLON
        """
        
        let validation = ChatViewModelTests.validateResponse(incompleteResponse, model: "test")
        XCTAssertFalse(validation.isComplete)
        XCTAssertTrue(validation.shouldRetry)
        XCTAssertTrue(validation.issues.contains { $0.contains("Incomplete INSERT_CODE block") })
    }
    
    func testValidateEmptyResponse() {
        let validation = ChatViewModelTests.validateResponse("", model: "test")
        XCTAssertFalse(validation.isComplete)
        XCTAssertTrue(validation.shouldRetry)
        XCTAssertTrue(validation.issues.contains("Empty response"))
    }
    
    func testValidateTooShortResponse() {
        let shortResponse = "Hello!"
        let validation = ChatViewModelTests.validateResponse(shortResponse, model: "test")
        XCTAssertFalse(validation.isComplete)
        XCTAssertTrue(validation.shouldRetry)
        XCTAssertTrue(validation.issues.contains { $0.contains("Response too short") })
    }
    
    func testValidateResponseWithTruncationIndicator() {
        let truncatedResponse = """
        I'll create a cube scene...
        
        [INSERT_CODE]
        ```javascript
        const createScene = () => {
            const scene = new BABYLON.Scene(engine);
            // Code truncated here...
        ```
        [/INSERT_CODE]
        """
        
        let validation = ChatViewModelTests.validateResponse(truncatedResponse, model: "test")
        XCTAssertFalse(validation.isComplete)
        XCTAssertTrue(validation.shouldRetry)
        XCTAssertTrue(validation.issues.contains { $0.contains("truncation indicator") })
    }
    
    // MARK: - Code Extraction Tests
    
    func testQwenFormatExtraction() {
        let qwenResponse = """
        I'll create a rainbow scene!
        
        [INSERT_CODE]
        ```javascript
        const createScene = () => {
            const scene = new BABYLON.Scene(engine);
            const box = BABYLON.MeshBuilder.CreateBox("box", {}, scene);
            return scene;
        };
        const scene = createScene();
        ```
        [/INSERT_CODE]
        
        [RUN_SCENE]
        """
        
        let extractedCode = extractCodeFromResponse(qwenResponse)
        XCTAssertNotNil(extractedCode)
        XCTAssertTrue(extractedCode!.contains("createScene"))
        XCTAssertTrue(extractedCode!.contains("BABYLON.Scene"))
        XCTAssertTrue(extractedCode!.contains("CreateBox"))
        XCTAssertFalse(extractedCode!.contains("[INSERT_CODE]"))
        XCTAssertFalse(extractedCode!.contains("[/INSERT_CODE]"))
    }
    
    func testLlamaFormatExtraction() {
        let llamaResponse = """
        Here's your cube scene:
        
        ```javascript
        const createScene = () => {
            const scene = new BABYLON.Scene(engine);
            const cube = BABYLON.MeshBuilder.CreateBox("cube", {size: 2}, scene);
            return scene;
        };
        const scene = createScene();
        ```
        
        This creates a simple cube scene.
        """
        
        let extractedCode = extractCodeFromResponse(llamaResponse)
        XCTAssertNotNil(extractedCode)
        XCTAssertTrue(extractedCode!.contains("createScene"))
        XCTAssertTrue(extractedCode!.contains("CreateBox"))
    }
    
    // MARK: - Error Handling Tests
    
    func testShouldRetryError() {
        struct TimeoutError: Error {
            var localizedDescription: String { "Request timeout" }
        }
        
        struct NetworkError: Error {
            var localizedDescription: String { "Network connection failed" }
        }
        
        struct AuthError: Error {
            var localizedDescription: String { "Authentication failed" }
        }
        
        XCTAssertTrue(ChatViewModelTests.shouldRetryError(TimeoutError()))
        XCTAssertTrue(ChatViewModelTests.shouldRetryError(NetworkError()))
        XCTAssertFalse(ChatViewModelTests.shouldRetryError(AuthError()))
    }
    
    // MARK: - Model Display Name Tests
    
    func testModelDisplayNames() {
        XCTAssertEqual(chatViewModel.getModelDisplayName("meta-llama/Meta-Llama-3-8B-Instruct-Lite"), "Llama 3 8B Lite")
        XCTAssertEqual(chatViewModel.getModelDisplayName("Qwen/Qwen2.5-7B-Instruct-Turbo"), "Qwen 2.5 7B Turbo")
        XCTAssertEqual(chatViewModel.getModelDisplayName("meta-llama/Llama-3.1-8B-Instruct"), "Llama 3.1 8B")
        XCTAssertEqual(chatViewModel.getModelDisplayName("Qwen/Qwen2.5-Coder-32B-Instruct"), "Qwen 2.5 Coder 32B")
    }
    
    // MARK: - Multi-Provider Tests
    
    func testAllProvidersConfigured() {
        // Test that all expected providers are available
        let providers = chatViewModel.providerManager.providers
        let providerNames = providers.map { $0.name }
        
        XCTAssertTrue(providerNames.contains("Together.ai"))
        XCTAssertTrue(providerNames.contains("OpenAI"))
        XCTAssertTrue(providerNames.contains("Anthropic"))
        XCTAssertEqual(providers.count, 3)
    }
    
    func testProviderAPIKeyManagement() {
        // Test API key setting and retrieval
        chatViewModel.setAPIKey(for: "OpenAI", key: "test-openai-key")
        chatViewModel.setAPIKey(for: "Anthropic", key: "test-anthropic-key")
        
        XCTAssertEqual(chatViewModel.getAPIKey(for: "OpenAI"), "test-openai-key")
        XCTAssertEqual(chatViewModel.getAPIKey(for: "Anthropic"), "test-anthropic-key")
        XCTAssertEqual(chatViewModel.getAPIKey(for: "Together.ai"), "changeMe") // Should be default
    }
    
    func testProviderConfigurationStatus() {
        // Initially no providers should be configured
        XCTAssertFalse(chatViewModel.isProviderConfigured("OpenAI"))
        XCTAssertFalse(chatViewModel.isProviderConfigured("Anthropic"))
        XCTAssertFalse(chatViewModel.isProviderConfigured("Together.ai"))
        
        // Configure OpenAI
        chatViewModel.setAPIKey(for: "OpenAI", key: "sk-test123")
        XCTAssertTrue(chatViewModel.isProviderConfigured("OpenAI"))
        XCTAssertFalse(chatViewModel.isProviderConfigured("Anthropic"))
        
        // Get configured providers
        let configuredProviders = chatViewModel.getConfiguredProviders()
        XCTAssertEqual(configuredProviders.count, 1)
        XCTAssertEqual(configuredProviders.first?.name, "OpenAI")
    }
    
    func testModelsByProvider() {
        let modelsByProvider = chatViewModel.modelsByProvider
        
        // Check that each provider has models
        XCTAssertTrue(modelsByProvider["Together.ai"]?.count ?? 0 > 0)
        XCTAssertTrue(modelsByProvider["OpenAI"]?.count ?? 0 > 0)
        XCTAssertTrue(modelsByProvider["Anthropic"]?.count ?? 0 > 0)
        
        // Check specific models exist
        let togetherModels = modelsByProvider["Together.ai"] ?? []
        let openaiModels = modelsByProvider["OpenAI"] ?? []
        let anthropicModels = modelsByProvider["Anthropic"] ?? []
        
        XCTAssertTrue(togetherModels.contains { $0.id.contains("DeepSeek") })
        XCTAssertTrue(openaiModels.contains { $0.id.contains("gpt-4") })
        XCTAssertTrue(anthropicModels.contains { $0.id.contains("claude") })
    }
    
    func testModelDisplayNameWithNewSystem() {
        // Test new provider system model display names
        let allModels = chatViewModel.allAvailableModels
        
        guard let deepSeekModel = allModels.first(where: { $0.id.contains("DeepSeek") }) else {
            XCTFail("DeepSeek model not found")
            return
        }
        
        let displayName = chatViewModel.getModelDisplayName(deepSeekModel.id)
        XCTAssertFalse(displayName.isEmpty)
        XCTAssertNotEqual(displayName, deepSeekModel.id) // Should be human-readable
    }
    
    func testModelDescriptionWithPricing() {
        let allModels = chatViewModel.allAvailableModels
        
        guard let freeModel = allModels.first(where: { $0.pricing.contains("FREE") }) else {
            XCTFail("Free model not found")
            return
        }
        
        let description = chatViewModel.getModelDescription(freeModel.id)
        XCTAssertTrue(description.contains("FREE") || description.contains("Advanced"))
    }
    
    func testProviderForModel() {
        let allModels = chatViewModel.allAvailableModels
        
        guard let openaiModel = allModels.first(where: { $0.provider == "OpenAI" }) else {
            XCTFail("OpenAI model not found")
            return
        }
        
        let provider = chatViewModel.providerManager.getProvider(for: openaiModel.id)
        XCTAssertNotNil(provider)
        XCTAssertEqual(provider?.name, "OpenAI")
    }
    
    func testLegacyCompatibility() {
        // Test that legacy models still work
        let legacyModels = chatViewModel.availableModels
        XCTAssertFalse(legacyModels.isEmpty)
        
        // Test legacy model display names
        let firstLegacyModel = legacyModels.first!
        let displayName = chatViewModel.getModelDisplayName(firstLegacyModel)
        XCTAssertFalse(displayName.isEmpty)
        
        let description = chatViewModel.getModelDescription(firstLegacyModel)
        XCTAssertFalse(description.isEmpty)
    }
    
    // MARK: - Provider-Specific Model Tests
    
    func testTogetherAIModels() {
        let togetherModels = chatViewModel.modelsByProvider["Together.ai"] ?? []
        
        // Should have the expected models
        let modelIds = togetherModels.map { $0.id }
        XCTAssertTrue(modelIds.contains("deepseek-ai/DeepSeek-R1-Distill-Llama-70B-free"))
        XCTAssertTrue(modelIds.contains("meta-llama/Llama-3.3-70B-Instruct-Turbo-Free"))
        
        // Check pricing information
        let freeModels = togetherModels.filter { $0.pricing.contains("FREE") }
        XCTAssertTrue(freeModels.count >= 2) // Should have at least 2 free models
        
        // Check that default model is set
        let defaultModel = togetherModels.first { $0.isDefault }
        XCTAssertNotNil(defaultModel)
    }
    
    func testOpenAIModels() {
        let openaiModels = chatViewModel.modelsByProvider["OpenAI"] ?? []
        
        // Should have GPT models
        let hasGPT4 = openaiModels.contains { $0.id.contains("gpt-4") }
        let hasGPT35 = openaiModels.contains { $0.id.contains("gpt-3.5") }
        
        XCTAssertTrue(hasGPT4 || hasGPT35, "Should have at least one GPT model")
        
        // Check that all models have pricing information
        for model in openaiModels {
            XCTAssertFalse(model.pricing.isEmpty, "Model \(model.id) should have pricing info")
        }
        
        // Should have a default model
        let defaultModel = openaiModels.first { $0.isDefault }
        XCTAssertNotNil(defaultModel)
    }
    
    func testAnthropicModels() {
        let anthropicModels = chatViewModel.modelsByProvider["Anthropic"] ?? []
        
        // Should have Claude models
        let hasClaudeModels = anthropicModels.contains { $0.id.contains("claude") }
        XCTAssertTrue(hasClaudeModels, "Should have Claude models")
        
        // Check model naming
        for model in anthropicModels {
            XCTAssertTrue(model.displayName.contains("Claude"), "Model display name should contain 'Claude'")
            XCTAssertFalse(model.pricing.isEmpty, "Model \(model.id) should have pricing info")
        }
        
        // Should have a default model
        let defaultModel = anthropicModels.first { $0.isDefault }
        XCTAssertNotNil(defaultModel)
    }
    
    // MARK: - Error Handling for Multi-Provider
    
    func testUnconfiguredProviderError() {
        // Try to use a provider that's not configured
        let openaiModels = chatViewModel.modelsByProvider["OpenAI"] ?? []
        guard let firstModel = openaiModels.first else {
            XCTFail("No OpenAI models available")
            return
        }
        
        // Since OpenAI is not configured, this should fail appropriately
        XCTAssertFalse(chatViewModel.isProviderConfigured("OpenAI"))
        
        // The system should handle this gracefully and fallback to configured providers
        let configuredProviders = chatViewModel.getConfiguredProviders()
        // Initially no providers are configured with real keys
        XCTAssertEqual(configuredProviders.count, 0)
    }
    
    // MARK: - Settings Persistence Tests
    
    func testMultiProviderSettingsPersistence() {
        // Set API keys for multiple providers
        chatViewModel.setAPIKey(for: "OpenAI", key: "sk-openai-test")
        chatViewModel.setAPIKey(for: "Anthropic", key: "sk-ant-test")
        chatViewModel.setAPIKey(for: "Together.ai", key: "together-test")
        
        // Save settings
        chatViewModel.saveSettings()
        
        // Verify the keys were saved (the AIProviderManager handles persistence automatically)
        XCTAssertEqual(chatViewModel.getAPIKey(for: "OpenAI"), "sk-openai-test")
        XCTAssertEqual(chatViewModel.getAPIKey(for: "Anthropic"), "sk-ant-test")
        XCTAssertEqual(chatViewModel.getAPIKey(for: "Together.ai"), "together-test")
    }
    
    // MARK: - Integration Tests
    
    func testCodeExtractionAndValidation() {
        let testCases: [(String, String, Bool)] = [
            // (response, description, shouldSucceed)
            ("""
             [INSERT_CODE]
             ```javascript
             const createScene = () => {
                 const scene = new BABYLON.Scene(engine);
                 return scene;
             };
             const scene = createScene();
             ```
             [/INSERT_CODE]
             """, "Complete Qwen format", true),
            
            ("""
             ```javascript
             const createScene = () => {
                 const scene = new BABYLON.Scene(engine);
                 return scene;
             };
             ```
             """, "Simple code block", true),
            
            ("""
             [INSERT_CODE]
             ```javascript
             const createScene = () => {
                 const scene = new BABYLON
             """, "Truncated response", false),
            
            ("Hello world!", "No code content", false)
        ]
        
        for (response, description, shouldSucceed) in testCases {
            let validation = ChatViewModelTests.validateResponse(response, model: "test")
            if shouldSucceed {
                XCTAssertTrue(validation.isComplete, "Failed for case: \(description)")
            } else {
                XCTAssertFalse(validation.isComplete, "Unexpectedly succeeded for case: \(description)")
            }
        }
    }
    
    // MARK: - Helper Functions for Testing
    
    struct ResponseValidation {
        let isComplete: Bool
        let shouldRetry: Bool
        let issues: [String]
    }
    
    static func validateResponse(_ response: String, model: String) -> ResponseValidation {
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
        
        return ResponseValidation(isComplete: isComplete, shouldRetry: shouldRetry, issues: issues)
    }
    
    static func shouldRetryError(_ error: Error) -> Bool {
        // Define which errors are worth retrying
        let errorString = error.localizedDescription.lowercased()
        
        let retryableErrors = [
            "timeout",
            "network",
            "connection",
            "temporarily unavailable",
            "rate limit",
            "server error",
            "stream",
            "chunk"
        ]
        
        return retryableErrors.contains { errorString.contains($0) }
    }
}

// MARK: - Helper Functions for Testing

private func extractCodeFromResponse(_ response: String) -> String? {
    // Simulate the same extraction logic used in ChatViewModel
    if let insertCodeStart = response.range(of: "[INSERT_CODE]"),
       let insertCodeEnd = response.range(of: "[/INSERT_CODE]") {
        
        let blockRange = insertCodeStart.upperBound..<insertCodeEnd.lowerBound
        let fullBlock = String(response[blockRange])
        
        if let jsStart = fullBlock.range(of: "```javascript") {
            let afterJSStart = jsStart.upperBound
            let extractedCode = String(fullBlock[afterJSStart...]).trimmingCharacters(in: .whitespacesAndNewlines)
            return extractedCode.isEmpty ? nil : extractedCode
        }
    }
    
    // Try regular code block extraction
    let codeBlockRegex = try! NSRegularExpression(pattern: "```(?:javascript|typescript|js|ts)?\\s*\\n?([\\s\\S]+?)\\n?```", options: [.dotMatchesLineSeparators])
    let matches = codeBlockRegex.matches(in: response, options: [], range: NSRange(response.startIndex..., in: response))
    
    for match in matches {
        if let codeRange = Range(match.range(at: 1), in: response) {
            let code = String(response[codeRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            if code.contains("createScene") || code.contains("BABYLON") {
                return code
            }
        }
    }
    
    return nil
}