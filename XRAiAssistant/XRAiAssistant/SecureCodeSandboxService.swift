import Foundation

/// Secure CodeSandbox integration service with multiple fallback strategies
class SecureCodeSandboxService {
    static let shared = SecureCodeSandboxService()

    private init() {}

    // MARK: - Primary Strategy: CodeSandbox Parameters (GET-based)

    /// Create a CodeSandbox using GET parameters (bypasses CORS for direct navigation)
    func createSecureCodeSandboxURL(code: String, framework: String) -> String {
        let files = generateSecureFiles(code: code, framework: framework)
        let parameters = createLZStringParameters(files: files)

        // Use GET-based URL that bypasses CORS restrictions
        return "https://codesandbox.io/s/new?\(parameters)"
    }

    // MARK: - Fallback Strategy: CodeSandbox Define with Form Submission

    /// Create CodeSandbox using a secure form-based approach
    func createCodeSandboxViaForm(code: String, framework: String) -> String {
        let files = generateSecureFiles(code: code, framework: framework)

        // Create a temporary HTML page that submits to CodeSandbox
        let formHTML = generateFormSubmissionHTML(files: files)

        // Return a data URL that can be loaded directly
        let encodedHTML = formHTML.data(using: .utf8)?.base64EncodedString() ?? ""
        return "data:text/html;base64,\(encodedHTML)"
    }

    // MARK: - Enhanced Strategy: Template-based URLs

    /// Use CodeSandbox template URLs (most reliable approach)
    func createTemplateBasedSandbox(code: String, framework: String) -> String {
        print("🌐 Creating secure CodeSandbox using direct URL approach for \(framework)")
        print("🔍 Input code preview: \(String(code.prefix(200)))...")

        // Generate files for the specific framework
        let files = generateSecureFiles(code: code, framework: framework)

        print("🔍 Generated \(files.count) files for CodeSandbox")
        for (filename, file) in files {
            print("📄 File: \(filename) - \(file.content.count) characters")
        }

        // Use form submission approach but with simpler HTML to avoid WebKit issues
        let html = generateSimpleFormHTML(files: files)
        print("🔍 Generated HTML length: \(html.count) characters")

        return html
    }

    // MARK: - CodeSandbox Define API Implementation

    // MARK: - Form Submission HTML Generator

    private func generateSimpleFormHTML(files: [String: SecureCodeSandboxFile]) -> String {
        let filesJSON = generateFilesJSON(files: files)
        let parameters = createParametersString(filesJSON: filesJSON)

        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <title>Creating CodeSandbox...</title>
        </head>
        <body>
            <p>Creating your React Three Fiber scene...</p>
            <form id="codeform" action="https://codesandbox.io/api/v1/sandboxes/define" method="POST" target="_self">
                <input type="hidden" name="parameters" value="\(parameters)">
            </form>
            <script>
                document.getElementById('codeform').submit();
            </script>
        </body>
        </html>
        """
    }

    private func generateFormSubmissionHTML(files: [String: SecureCodeSandboxFile]) -> String {
        let filesJSON = generateFilesJSON(files: files)

        return """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Creating CodeSandbox...</title>
            <meta charset="utf-8">
            <style>
                body {
                    font-family: system-ui, -apple-system, sans-serif;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    height: 100vh;
                    margin: 0;
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    color: white;
                }
                .container {
                    text-align: center;
                    padding: 40px;
                }
                .spinner {
                    border: 3px solid rgba(255,255,255,0.3);
                    border-radius: 50%;
                    border-top: 3px solid white;
                    width: 40px;
                    height: 40px;
                    animation: spin 1s linear infinite;
                    margin: 20px auto;
                }
                @keyframes spin {
                    0% { transform: rotate(0deg); }
                    100% { transform: rotate(360deg); }
                }
            </style>
        </head>
        <body>
            <div class="container">
                <h2>🚀 Creating CodeSandbox...</h2>
                <div class="spinner"></div>
                <p>Redirecting to your live React Three Fiber environment...</p>
            </div>

            <form id="sandbox-form" action="https://codesandbox.io/api/v1/sandboxes/define" method="POST" target="_self">
                <input type="hidden" name="parameters" value="\(createParametersString(filesJSON: filesJSON))" />
            </form>

            <script>
                // Debug logging
                function debugLog(message) {
                    console.log('CodeSandbox: ' + message);
                    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.codeSandboxDebug) {
                        window.webkit.messageHandlers.codeSandboxDebug.postMessage(message);
                    }
                }

                debugLog('HTML loaded, preparing form submission');

                // Use a more reliable approach - programmatic form creation and submission
                window.addEventListener('load', function() {
                    debugLog('Window loaded, creating and submitting form programmatically');

                    // Create form programmatically to avoid WebKit navigation issues
                    var form = document.createElement('form');
                    form.method = 'POST';
                    form.action = 'https://codesandbox.io/api/v1/sandboxes/define';
                    form.target = '_self';

                    var input = document.createElement('input');
                    input.type = 'hidden';
                    input.name = 'parameters';
                    input.value = '\(createParametersString(filesJSON: filesJSON))';

                    form.appendChild(input);
                    document.body.appendChild(form);

                    debugLog('Programmatic form created, submitting...');
                    form.submit();
                    debugLog('Form submitted successfully');
                });
            </script>
        </body>
        </html>
        """
    }

    // MARK: - Secure File Generation

    private func generateSecureFiles(code: String, framework: String) -> [String: SecureCodeSandboxFile] {
        let sanitizedCode = sanitizeCode(code)

        switch framework {
        case "reactThreeFiber":
            return generateSecureR3FFiles(userCode: sanitizedCode)
        case "reactylon":
            return generateSecureReactylonFiles(userCode: sanitizedCode)
        default:
            return generateSecureR3FFiles(userCode: sanitizedCode)
        }
    }

    private func sanitizeCode(_ code: String) -> String {
        // Security: Remove potentially dangerous code patterns
        var sanitized = code

        // Remove script tags
        sanitized = sanitized.replacingOccurrences(of: "<script[^>]*>.*?</script>", with: "", options: .regularExpression)

        // Remove dangerous functions
        let dangerousFunctions = ["eval", "innerHTML", "outerHTML", "document.write"]
        for functionName in dangerousFunctions {
            sanitized = sanitized.replacingOccurrences(of: functionName, with: "/* \(functionName) removed for security */")
        }

        // Remove event handlers
        sanitized = sanitized.replacingOccurrences(of: "on[a-zA-Z]+=", with: "", options: .regularExpression)

        return sanitized
    }

    private func generateSecureR3FFiles(userCode: String) -> [String: SecureCodeSandboxFile] {
        let packageJson = """
        {
          "name": "xraiassistant-r3f-scene",
          "version": "1.0.0",
          "description": "XRAiAssistant generated React Three Fiber scene",
          "keywords": ["react", "three", "fiber", "3d", "xr"],
          "main": "src/index.js",
          "dependencies": {
            "@react-three/fiber": "^9.3.0",
            "@react-three/drei": "^9.92.7",
            "react": "^18.2.0",
            "react-dom": "^18.2.0",
            "three": "^0.160.0"
          },
          "devDependencies": {
            "@types/react": "^18.2.0",
            "@types/react-dom": "^18.2.0",
            "typescript": "^5.0.0"
          },
          "scripts": {
            "start": "react-scripts start",
            "build": "react-scripts build"
          },
          "browserslist": [">0.2%", "not dead"]
        }
        """

        // Check if user code contains a complete App component structure
        let containsApp = userCode.contains("function App(") || userCode.contains("const App =") || userCode.contains("export default function App")
        let containsCreateRoot = userCode.contains("createRoot") && userCode.contains("render")

        if containsApp && containsCreateRoot {
            // User provided complete app - use it directly as index.js
            let indexJs = userCode

            return [
                "package.json": SecureCodeSandboxFile(content: packageJson),
                "src/index.js": SecureCodeSandboxFile(content: indexJs),
                "public/index.html": SecureCodeSandboxFile(content: generateSecureIndexHTML())
            ]
        } else {
            // User provided only Scene component - wrap it in our App structure
            let indexJs = """
            import React from 'react';
            import { createRoot } from 'react-dom/client';
            import App from './App';

            const container = document.getElementById('root');
            const root = createRoot(container);
            root.render(<App />);
            """

            let appJs = """
            import React from 'react';
            import { Canvas } from '@react-three/fiber';
            import { OrbitControls } from '@react-three/drei';
            import Scene from './Scene';

            export default function App() {
              return (
                <div style={{ width: '100vw', height: '100vh' }}>
                  <Canvas
                    camera={{ position: [0, 0, 5], fov: 75 }}
                    gl={{ antialias: true }}
                  >
                    <ambientLight intensity={0.5} />
                    <spotLight position={[10, 10, 10]} angle={0.15} penumbra={1} />
                    <pointLight position={[-10, -10, -10]} />
                    <Scene />
                    <OrbitControls />
                  </Canvas>
                </div>
              );
            }
            """

            let sceneJs = """
            import React, { useRef } from 'react';
            import { useFrame } from '@react-three/fiber';

            \(userCode)

            export default Scene;
            """

            return [
                "package.json": SecureCodeSandboxFile(content: packageJson),
                "src/index.js": SecureCodeSandboxFile(content: indexJs),
                "src/App.js": SecureCodeSandboxFile(content: appJs),
                "src/Scene.js": SecureCodeSandboxFile(content: sceneJs),
                "public/index.html": SecureCodeSandboxFile(content: generateSecureIndexHTML())
            ]
        }
    }

    private func generateSecureReactylonFiles(userCode: String) -> [String: SecureCodeSandboxFile] {
        // Similar structure for Reactylon with Babylon.js dependencies
        // Implementation would be similar to R3F but with Babylon.js packages
        return generateSecureR3FFiles(userCode: userCode) // Simplified for now
    }

    private func generateSecureIndexHTML() -> String {
        return """
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="utf-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
            <meta name="theme-color" content="#000000" />
            <title>XRAiAssistant - React Three Fiber Scene</title>
            <style>
              body {
                margin: 0;
                padding: 0;
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto';
                overflow: hidden;
                background: #000;
              }
              #root {
                width: 100vw;
                height: 100vh;
              }
            </style>
          </head>
          <body>
            <noscript>You need to enable JavaScript to run this app.</noscript>
            <div id="root"></div>
          </body>
        </html>
        """
    }

    // MARK: - Parameter Generation Helpers

    private func createLZStringParameters(files: [String: SecureCodeSandboxFile]) -> String {
        // For now, return empty - would implement LZ-string compression
        return ""
    }

    private func createParametersString(filesJSON: String) -> String {
        // Create parameters for CodeSandbox form submission
        let compressed = filesJSON.data(using: .utf8)?.base64EncodedString() ?? ""
        return compressed
    }

    private func generateFilesJSON(files: [String: SecureCodeSandboxFile]) -> String {
        // Convert files to JSON format expected by CodeSandbox
        var jsonDict: [String: [String: Any]] = [:]

        for (path, file) in files {
            jsonDict[path] = [
                "content": file.content,
                "isBinary": file.isBinary
            ]
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ["files": jsonDict])
            return String(data: jsonData, encoding: .utf8) ?? "{}"
        } catch {
            return "{}"
        }
    }
}

// MARK: - Supporting Types

struct SecureCodeSandboxFile {
    let content: String
    let isBinary: Bool

    init(content: String, isBinary: Bool = false) {
        self.content = content
        self.isBinary = isBinary
    }
}

enum SecureCodeSandboxError: Error, LocalizedError {
    case corsRestriction
    case invalidResponse
    case securityViolation
    case templateNotFound

    var errorDescription: String? {
        switch self {
        case .corsRestriction:
            return "Cross-origin request blocked by security policy"
        case .invalidResponse:
            return "Invalid response from CodeSandbox service"
        case .securityViolation:
            return "Code contains potentially unsafe content"
        case .templateNotFound:
            return "CodeSandbox template not available"
        }
    }
}