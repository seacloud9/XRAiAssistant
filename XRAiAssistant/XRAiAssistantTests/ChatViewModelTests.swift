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