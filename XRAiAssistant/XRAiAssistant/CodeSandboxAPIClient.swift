import Foundation

/// Native Swift client for CodeSandbox Define API
/// This bypasses WKWebView CORS/form submission issues by making direct HTTP requests
class CodeSandboxAPIClient {
    static let shared = CodeSandboxAPIClient()
    
    private let apiBaseURL = "https://codesandbox.io/api/v1"
    private var apiKey: String? {
        return UserDefaults.standard.string(forKey: "XRAiAssistant_CodeSandboxAPIKey")
    }
    
    private init() {}
    
    // MARK: - Public API
    
    /// Create a CodeSandbox and return the sandbox URL
    func createSandbox(code: String, framework: String) async throws -> String {
        print("🌐 CodeSandboxAPIClient - Creating sandbox for framework: \(framework)")
        print("🔑 API Key available: \(apiKey != nil ? "YES" : "NO")")
        
        // Generate files structure
        let files = generateFiles(code: code, framework: framework)
        print("📦 Generated \(files.keys.count) files: \(files.keys.sorted())")
        
        // Create JSON parameters
        let parameters = try createParameters(files: files)
        print("📄 Parameters JSON length: \(parameters.count) bytes")
        
        // Make API request
        let sandboxURL = try await postToDefineAPI(parameters: parameters)
        print("✅ CodeSandbox created: \(sandboxURL)")
        
        return sandboxURL
    }
    
    // MARK: - Private Implementation
    
    private func postToDefineAPI(parameters: Data) async throws -> String {
        let url = URL(string: "\(apiBaseURL)/sandboxes/define")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // IMPORTANT: Don't follow redirects automatically - we need to capture the Location header
        // URLSession doesn't follow redirects for cross-origin POST requests by default, which is what we want
        
        // Add API key if available (optional for public sandboxes)
        if let apiKey = apiKey, !apiKey.isEmpty {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            print("🔑 Using CodeSandbox API key for authenticated request")
        } else {
            print("ℹ️  Creating public sandbox (no API key)")
        }
        
        request.httpBody = parameters
        
        print("📤 Sending POST request to: \(url)")
        print("📦 Body size: \(parameters.count) bytes")
        
        // Use a custom URLSession to handle redirects
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CodeSandboxAPIError.invalidResponse
        }
        
        print("📥 Response status: \(httpResponse.statusCode)")
        
        // Log response headers for debugging
        if let headers = httpResponse.allHeaderFields as? [String: Any] {
            print("📋 Response headers: \(headers)")
        }
        
        // Handle redirect responses (302 Found)
        if httpResponse.statusCode == 302 || httpResponse.statusCode == 301 {
            // Extract the sandbox URL from Location header
            if let locationHeader = httpResponse.allHeaderFields["Location"] as? String {
                print("🎯 Redirect location: \(locationHeader)")
                
                // Location header is typically just "/s/sandbox_id"
                if locationHeader.hasPrefix("/s/") {
                    let sandboxURL = "https://codesandbox.io\(locationHeader)"
                    print("✅ Extracted sandbox URL from redirect: \(sandboxURL)")
                    return sandboxURL
                } else if locationHeader.contains("codesandbox.io") {
                    print("✅ Full sandbox URL from redirect: \(locationHeader)")
                    return locationHeader
                } else {
                    print("⚠️ Unexpected Location header format: \(locationHeader)")
                    return "https://codesandbox.io\(locationHeader)"
                }
            } else {
                // Try to parse HTML redirect
                let responseString = String(data: data, encoding: .utf8) ?? ""
                print("📄 HTML response: \(responseString)")
                
                if let sandboxID = extractSandboxIDFromHTML(responseString) {
                    let sandboxURL = "https://codesandbox.io/s/\(sandboxID)"
                    print("✅ Extracted sandbox ID from HTML: \(sandboxID)")
                    return sandboxURL
                } else {
                    print("❌ Could not extract sandbox URL from redirect")
                    throw CodeSandboxAPIError.invalidResponse
                }
            }
        }
        
        // Handle successful response (200-299)
        if (200...299).contains(httpResponse.statusCode) {
            let responseString = String(data: data, encoding: .utf8) ?? ""
            print("📥 Response body: \(String(responseString.prefix(500)))...")
            
            // Check if response is JSON or HTML
            if responseString.starts(with: "{") {
                // JSON response
                struct SandboxResponse: Codable {
                    let sandbox_id: String
                }
                
                let decoder = JSONDecoder()
                let sandboxResponse = try decoder.decode(SandboxResponse.self, from: data)
                
                return "https://codesandbox.io/s/\(sandboxResponse.sandbox_id)"
            } else {
                // HTML response - extract sandbox ID from the HTML
                print("📄 Received HTML response, extracting sandbox ID...")
                if let sandboxID = extractSandboxIDFromHTML(responseString) {
                    let sandboxURL = "https://codesandbox.io/s/\(sandboxID)"
                    print("✅ Extracted sandbox ID from HTML: \(sandboxID)")
                    return sandboxURL
                } else {
                    print("❌ Could not extract sandbox ID from HTML response")
                    throw CodeSandboxAPIError.invalidResponse
                }
            }
        }
        
        // Handle error responses
        let errorBody = String(data: data, encoding: .utf8) ?? "No error body"
        print("❌ API Error (\(httpResponse.statusCode)): \(errorBody)")
        throw CodeSandboxAPIError.apiError(statusCode: httpResponse.statusCode, message: errorBody)
    }
    
    private func extractSandboxIDFromHTML(_ html: String) -> String? {
        // Try multiple patterns to extract sandbox ID from HTML
        
        // Pattern 1: og:url meta tag like: content="https://codesandbox.io/s/j66yxn"
        if let range = html.range(of: #"og:url"[^>]+content="https://codesandbox\.io/s/([a-zA-Z0-9-]+)"#, options: .regularExpression) {
            let match = String(html[range])
            // Extract just the ID after /s/
            if let idRange = match.range(of: #"(?<=codesandbox\.io/s/)[a-zA-Z0-9-]+"#, options: .regularExpression) {
                let sandboxID = String(match[idRange])
                print("✅ Found sandbox ID in og:url: \(sandboxID)")
                return sandboxID
            }
        }
        
        // Pattern 2: canonical link like: <link rel="canonical" href="https://codesandbox.io/s/j66yxn" />
        if let range = html.range(of: #"rel="canonical" href="https://codesandbox\.io/s/([a-zA-Z0-9-]+)"#, options: .regularExpression) {
            let match = String(html[range])
            // Extract just the ID after /s/
            if let idRange = match.range(of: #"(?<=codesandbox\.io/s/)[a-zA-Z0-9-]+"#, options: .regularExpression) {
                let sandboxID = String(match[idRange])
                print("✅ Found sandbox ID in canonical link: \(sandboxID)")
                return sandboxID
            }
        }
        
        // Pattern 3: Simple href="/s/ID" pattern
        if let range = html.range(of: #"href="/s/([a-zA-Z0-9-]+)"#, options: .regularExpression) {
            let match = String(html[range])
            if let idRange = match.range(of: #"(?<=/s/)[a-zA-Z0-9-]+"#, options: .regularExpression) {
                let sandboxID = String(match[idRange])
                print("✅ Found sandbox ID in href: \(sandboxID)")
                return sandboxID
            }
        }
        
        print("❌ No sandbox ID pattern matched in HTML")
        return nil
    }
    
    private func createParameters(files: [String: CodeSandboxAPIFile]) throws -> Data {
        var filesDict: [String: [String: Any]] = [:]
        
        for (path, file) in files {
            filesDict[path] = [
                "content": file.content,
                "isBinary": file.isBinary
            ]
        }
        
        let parameters: [String: Any] = [
            "files": filesDict
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        
        // Validate we can parse it back
        if let _ = try? JSONSerialization.jsonObject(with: jsonData) {
            print("✅ Parameters JSON validated successfully")
        } else {
            print("❌ Parameters JSON validation failed")
            throw CodeSandboxAPIError.jsonSerializationFailed
        }
        
        return jsonData
    }
    
    private func generateFiles(code: String, framework: String) -> [String: CodeSandboxAPIFile] {
        switch framework {
        case "reactThreeFiber":
            return generateReactThreeFiberFiles(code: code)
        case "reactylon":
            return generateReactylonFiles(code: code)
        case "babylonjs":
            return generateBabylonJSFiles(code: code)
        default:
            return generateThreeJSFiles(code: code)
        }
    }
    
    // MARK: - File Generators
    
    private func cleanReactThreeFiberCode(_ code: String) -> String {
        var cleanedCode = code

        print("🧹 Cleaning React Three Fiber code (original length: \(code.count))")

        // Remove ALL rendering-related code that should be in index.js
        let patternsToRemove = [
            // Remove entire lines with createRoot imports
            #"import\s+\{\s*createRoot\s*\}\s+from\s+['"]react-dom/client['"][\s\S]*?\n"#,
            // Remove createRoot calls (multiline with any content)
            #"const\s+root\s*=\s*createRoot\s*\([^)]*\)!?\s*\n?"#,
            // Remove root.render calls (multiline)
            #"root\.render\s*\([\s\S]*?\)\s*\n?"#,
            // Remove document.getElementById with non-null assertion
            #"const\s+rootElement\s*=\s*document\.getElementById\s*\([^)]*\)!?\s*\n?"#,
            // Remove ReactDOM.render (old React 17 pattern)
            #"ReactDOM\.render\s*\([\s\S]*?\)\s*\n?"#,
            // Remove StrictMode imports
            #"import\s+\{\s*StrictMode\s*\}\s+from\s+['"]react['"][\s\S]*?\n"#,
            // Remove StrictMode wrapper
            #"<StrictMode>[\s\S]*?</StrictMode>"#
        ]

        for pattern in patternsToRemove {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) {
                let range = NSRange(cleanedCode.startIndex..., in: cleanedCode)
                let before = cleanedCode
                cleanedCode = regex.stringByReplacingMatches(in: cleanedCode, options: [], range: range, withTemplate: "")
                if before != cleanedCode {
                    print("✂️ Pattern matched and removed: \(pattern)")
                }
            }
        }

        // STEP 1: Remove rendering code that should be in index.js (already done above)

        // STEP 2: AGGRESSIVE TypeScript syntax removal
        print("🔧 Step 2: Removing TypeScript syntax...")

        // Remove ! after any closing parenthesis (function calls)
        let beforeNonNull = cleanedCode
        cleanedCode = cleanedCode.replacingOccurrences(of: #"\)!"#, with: ")", options: .regularExpression)
        if cleanedCode != beforeNonNull {
            print("  ✂️ Removed non-null assertions after function calls")
        }

        // Remove ! after any property access
        cleanedCode = cleanedCode.replacingOccurrences(of: #"([a-zA-Z0-9_\])\"\'])\s*!"#, with: "$1", options: .regularExpression)

        // Remove ALL generic type parameters from any identifier
        // This handles: useRef<THREE.Group>, useState<number>, useRef<Array<Type>>
        // The pattern must handle nested generics like Array<Type>
        let beforeGenerics = cleanedCode

        // First pass: Remove simple generics like useRef<Type>
        cleanedCode = cleanedCode.replacingOccurrences(of: #"([a-zA-Z_][a-zA-Z0-9_]*)<[^<>]+>"#, with: "$1", options: .regularExpression)

        // Second pass: Remove nested generics like useRef<Array<Type>>
        // Keep removing until no more patterns match (handles any nesting depth)
        var previousCode = ""
        while previousCode != cleanedCode {
            previousCode = cleanedCode
            cleanedCode = cleanedCode.replacingOccurrences(of: #"([a-zA-Z_][a-zA-Z0-9_]*)<[^<>]*>"#, with: "$1", options: .regularExpression)
        }

        if cleanedCode != beforeGenerics {
            print("  ✂️ Removed generic type parameters (e.g., useRef<Type>)")
        }

        // Remove type annotations from variable declarations
        // const foo: Type = ... → const foo = ...
        let beforeVarTypes = cleanedCode
        cleanedCode = cleanedCode.replacingOccurrences(of: #"(const|let|var)\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*:\s*[^=]+=\s*"#, with: "$1 $2 = ", options: .regularExpression)
        if cleanedCode != beforeVarTypes {
            print("  ✂️ Removed type annotations from variable declarations")
        }

        // Remove type annotations from function parameters
        // This handles ALL patterns including object literal types
        let beforeParamTypes = cleanedCode

        // Pattern 1: Remove object literal type annotations like: { prop: type, prop2: type }
        // Example: ({ position, color }: { position: [number, number, number], color: string })
        cleanedCode = cleanedCode.replacingOccurrences(of: #":\s*\{[^}]+\}"#, with: "", options: .regularExpression)

        // Pattern 2: Remove capital-letter types (React.FC, THREE.Mesh, etc.)
        cleanedCode = cleanedCode.replacingOccurrences(of: #":\s*[A-Z][a-zA-Z0-9<>\.\[\]|&\s]*([,)])"#, with: "$1", options: .regularExpression)

        // Pattern 3: Remove any remaining type annotation
        cleanedCode = cleanedCode.replacingOccurrences(of: #":\s*any([,)])"#, with: "$1", options: .regularExpression)

        // Pattern 4: Remove primitive types (number, string, boolean, any, void, etc.)
        cleanedCode = cleanedCode.replacingOccurrences(of: #":\s*(number|string|boolean|any|void|null|undefined|symbol|bigint)([,)])"#, with: "$2", options: .regularExpression)

        // Pattern 5: Remove array types like string[], number[]
        cleanedCode = cleanedCode.replacingOccurrences(of: #":\s*(number|string|boolean|any)\[\]([,)])"#, with: "$2", options: .regularExpression)

        // Pattern 6: Remove return type annotations from arrow functions (: Type => becomes =>)
        cleanedCode = cleanedCode.replacingOccurrences(of: #"\)\s*:\s*[A-Za-z][a-zA-Z0-9<>\.\[\]|&\s]*\s*=>"#, with: ") =>", options: .regularExpression)

        // Pattern 7: Remove return type annotations from regular functions (: Type { becomes {)
        cleanedCode = cleanedCode.replacingOccurrences(of: #"\)\s*:\s*[A-Za-z][a-zA-Z0-9<>\.\[\]|&\s]*\s*\{"#, with: ") {", options: .regularExpression)

        if cleanedCode != beforeParamTypes {
            print("  ✂️ Removed type annotations from function parameters (including object literals)")
        }

        // Remove React.FC type annotations
        cleanedCode = cleanedCode.replacingOccurrences(of: ": React.FC", with: "")
        cleanedCode = cleanedCode.replacingOccurrences(of: ": React.FC<", with: "")

        // Remove THREE imports
        cleanedCode = cleanedCode.replacingOccurrences(of: "import * as THREE from 'three'\n", with: "")
        cleanedCode = cleanedCode.replacingOccurrences(of: "import * as THREE from \"three\"\n", with: "")

        // Remove unused React imports (useRef, useState, useEffect, etc.) if they're not used
        // This prevents React bundler confusion
        if !cleanedCode.contains("useRef(") {
            cleanedCode = cleanedCode.replacingOccurrences(of: #", useRef"#, with: "")
            cleanedCode = cleanedCode.replacingOccurrences(of: #"useRef, "#, with: "")
            cleanedCode = cleanedCode.replacingOccurrences(of: #"\{ useRef \}"#, with: "{}", options: .regularExpression)
        }
        if !cleanedCode.contains("useState(") {
            cleanedCode = cleanedCode.replacingOccurrences(of: #", useState"#, with: "")
            cleanedCode = cleanedCode.replacingOccurrences(of: #"useState, "#, with: "")
            cleanedCode = cleanedCode.replacingOccurrences(of: #"\{ useState \}"#, with: "{}", options: .regularExpression)
        }

        print("✅ TypeScript syntax cleaning complete")

        // Clean up multiple blank lines
        while cleanedCode.contains("\n\n\n") {
            cleanedCode = cleanedCode.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        }

        // Ensure we have necessary imports
        let hasReactImport = cleanedCode.contains("import React")
        let hasCanvasImport = cleanedCode.contains("from '@react-three/fiber'")

        var finalCode = ""

        // Add React import if missing
        if !hasReactImport {
            finalCode += "import React from 'react';\n"
            print("➕ Added missing React import")
        }

        // Add Canvas import if missing (but only if Canvas is used)
        if !hasCanvasImport && cleanedCode.contains("<Canvas") {
            finalCode += "import { Canvas } from '@react-three/fiber';\n"
            print("➕ Added missing Canvas import")
        }

        // Add the cleaned user code
        finalCode += cleanedCode.trimmingCharacters(in: .whitespacesAndNewlines)

        // Clean up any orphaned closing parentheses or brackets at the end
        // These can come from the AI's response structure
        var trimmedFinalCode = finalCode.trimmingCharacters(in: .whitespacesAndNewlines)
        while trimmedFinalCode.hasSuffix(")") || trimmedFinalCode.hasSuffix("]") || trimmedFinalCode.hasSuffix("}") {
            let lastChar = trimmedFinalCode.last!

            // Count opening and closing brackets to see if this is orphaned
            let openCount = trimmedFinalCode.filter { $0 == Character(String(lastChar).replacingOccurrences(of: ")", with: "(").replacingOccurrences(of: "]", with: "[").replacingOccurrences(of: "}", with: "{")) }.count
            let closeCount = trimmedFinalCode.filter { $0 == lastChar }.count

            if closeCount > openCount {
                // Orphaned closing bracket - remove it
                trimmedFinalCode = String(trimmedFinalCode.dropLast()).trimmingCharacters(in: .whitespacesAndNewlines)
                print("  🧹 Removed orphaned closing bracket: \(lastChar)")
            } else {
                break
            }
        }

        finalCode = trimmedFinalCode

        // Ensure we export default App
        if !finalCode.contains("export default") {
            // ALWAYS export App for React Three Fiber scenes
            // The App component must contain the Canvas, so we can't export inner components
            if finalCode.contains("function App()") {
                finalCode += "\n\nexport default App;"
                print("➕ Added default export: App")
            } else {
                // If no App function, try to find any Canvas-containing component
                if let funcMatch = finalCode.range(of: #"function\s+([A-Z][a-zA-Z0-9]*)\(\)[^{]*\{[^}]*<Canvas"#, options: .regularExpression) {
                    let funcName = String(finalCode[funcMatch])
                        .replacingOccurrences(of: #"function\s+"#, with: "", options: .regularExpression)
                        .replacingOccurrences(of: #"\(\).*"#, with: "", options: .regularExpression)
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    finalCode += "\n\nexport default \(funcName);"
                    print("➕ Added default export: \(funcName) (contains Canvas)")
                } else {
                    // Fallback: export App
                    finalCode += "\n\nexport default App;"
                    print("➕ Added default export: App (fallback)")
                }
            }
        }

        print("✅ Code cleaning complete (final length: \(finalCode.count))")
        print("📝 First 500 chars of cleaned code:")
        print(String(finalCode.prefix(500)))
        print("...")

        // Log the entire cleaned code for debugging
        print("================================================================================")
        print("COMPLETE CLEANED CODE (src/App.js):")
        print("================================================================================")
        print(finalCode)
        print("================================================================================")

        return finalCode
    }

    private func generateReactThreeFiberFiles(code: String) -> [String: CodeSandboxAPIFile] {
        // Clean the AI-generated code
        let cleanedCode = cleanReactThreeFiberCode(code)

        let packageJson = """
        {
          "name": "r3f-xraiassistant-scene",
          "version": "1.0.0",
          "description": "React Three Fiber scene generated by XRAiAssistant",
          "keywords": ["react", "three", "3d", "react-three-fiber"],
          "main": "src/index.js",
          "dependencies": {
            "react": "^18.3.1",
            "react-dom": "^18.3.1",
            "react-scripts": "5.0.1",
            "@react-three/fiber": "^8.17.10",
            "@react-three/drei": "^9.114.3",
            "@react-three/postprocessing": "^2.16.3",
            "three": "^0.171.0"
          },
          "scripts": {
            "start": "react-scripts start",
            "build": "react-scripts build",
            "test": "react-scripts test",
            "eject": "react-scripts eject"
          },
          "eslintConfig": {
            "extends": ["react-app"]
          },
          "browserslist": {
            "production": [">0.2%", "not dead", "not op_mini all"],
            "development": ["last 1 chrome version", "last 1 firefox version", "last 1 safari version"]
          }
        }
        """
        
        let indexHtml = """
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="utf-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
            <meta name="theme-color" content="#000000" />
            <title>XRAiAssistant - React Three Fiber</title>
          </head>
          <body>
            <noscript>You need to enable JavaScript to run this app.</noscript>
            <div id="root"></div>
          </body>
        </html>
        """
        
        let indexJs = """
        import React, { StrictMode } from 'react';
        import { createRoot } from 'react-dom/client';
        import './index.css';
        import App from './App';

        const rootElement = document.getElementById('root');
        if (!rootElement) throw new Error('Root element not found');

        const root = createRoot(rootElement);
        root.render(
          <StrictMode>
            <App />
          </StrictMode>
        );
        """
        
        let gitignore = """
        # dependencies
        /node_modules
        /.pnp
        .pnp.js

        # testing
        /coverage

        # production
        /build

        # misc
        .DS_Store
        .env.local
        .env.development.local
        .env.test.local
        .env.production.local

        npm-debug.log*
        yarn-debug.log*
        yarn-error.log*
        """

        let css = """
        * {
          margin: 0;
          padding: 0;
          box-sizing: border-box;
        }

        html,
        body,
        #root {
          width: 100%;
          height: 100%;
          overflow: hidden;
        }

        body {
          background: #000;
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
            'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
            sans-serif;
          -webkit-font-smoothing: antialiased;
          -moz-osx-font-smoothing: grayscale;
        }

        canvas {
          display: block;
        }
        """

        return [
            "package.json": CodeSandboxAPIFile(content: packageJson),
            "public/index.html": CodeSandboxAPIFile(content: indexHtml),
            "src/index.js": CodeSandboxAPIFile(content: indexJs),
            "src/App.js": CodeSandboxAPIFile(content: cleanedCode),
            "src/index.css": CodeSandboxAPIFile(content: css),
            ".gitignore": CodeSandboxAPIFile(content: gitignore)
        ]
    }
    
    private func generateThreeJSFiles(code: String) -> [String: CodeSandboxAPIFile] {
        let packageJson = """
        {
          "name": "threejs-xraiassistant-scene",
          "version": "1.0.0",
          "description": "Three.js scene generated by XRAiAssistant",
          "keywords": ["threejs", "3d", "webgl"],
          "main": "src/index.js",
          "dependencies": {
            "three": "^0.158.0"
          }
        }
        """
        
        let indexHtml = """
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="utf-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1" />
            <title>XRAiAssistant - Three.js</title>
            <style>
              * { margin: 0; padding: 0; }
              body { overflow: hidden; background: #000; }
              canvas { display: block; }
            </style>
          </head>
          <body>
            <script src="./index.js" type="module"></script>
          </body>
        </html>
        """
        
        return [
            "package.json": CodeSandboxAPIFile(content: packageJson),
            "public/index.html": CodeSandboxAPIFile(content: indexHtml),
            "src/index.js": CodeSandboxAPIFile(content: code)
        ]
    }
    
    private func generateBabylonJSFiles(code: String) -> [String: CodeSandboxAPIFile] {
        let packageJson = """
        {
          "name": "babylonjs-xraiassistant-scene",
          "version": "1.0.0",
          "description": "Babylon.js scene generated by XRAiAssistant",
          "keywords": ["babylonjs", "3d", "webgl"],
          "main": "src/index.js",
          "dependencies": {
            "@babylonjs/core": "^6.0.0",
            "@babylonjs/loaders": "^6.0.0"
          }
        }
        """
        
        let indexHtml = """
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="utf-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1" />
            <title>XRAiAssistant - Babylon.js</title>
            <style>
              * { margin: 0; padding: 0; }
              body { overflow: hidden; background: #000; }
              #renderCanvas { width: 100%; height: 100%; touch-action: none; }
            </style>
          </head>
          <body>
            <canvas id="renderCanvas"></canvas>
            <script src="./index.js" type="module"></script>
          </body>
        </html>
        """
        
        return [
            "package.json": CodeSandboxAPIFile(content: packageJson),
            "public/index.html": CodeSandboxAPIFile(content: indexHtml),
            "src/index.js": CodeSandboxAPIFile(content: code)
        ]
    }
    
    private func cleanReactylonCode(_ code: String) -> String {
        var cleanedCode = code

        print("🧹 Cleaning Reactylon code (original length: \(code.count))")

        // Remove ALL rendering-related code that should be in index.js
        let patternsToRemove = [
            // Remove entire lines with createRoot imports
            #"import\s+\{\s*createRoot\s*\}\s+from\s+['"]react-dom/client['"][\s\S]*?\n"#,
            // Remove createRoot calls (multiline with any content)
            #"const\s+root\s*=\s*createRoot\s*\([^)]*\)!?\s*\n?"#,
            // Remove root.render calls (multiline)
            #"root\.render\s*\([\s\S]*?\)\s*\n?"#,
            // Remove document.getElementById with non-null assertion
            #"const\s+rootElement\s*=\s*document\.getElementById\s*\([^)]*\)!?\s*\n?"#,
            // Remove ReactDOM.render (old React 17 pattern)
            #"ReactDOM\.render\s*\([\s\S]*?\)\s*\n?"#,
            // Remove StrictMode imports
            #"import\s+\{\s*StrictMode\s*\}\s+from\s+['"]react['"][\s\S]*?\n"#,
            // Remove StrictMode wrapper
            #"<StrictMode>[\s\S]*?</StrictMode>"#
        ]

        for pattern in patternsToRemove {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) {
                let range = NSRange(cleanedCode.startIndex..., in: cleanedCode)
                let before = cleanedCode
                cleanedCode = regex.stringByReplacingMatches(in: cleanedCode, options: [], range: range, withTemplate: "")
                if before != cleanedCode {
                    print("✂️ Pattern matched and removed: \(pattern)")
                }
            }
        }

        // STEP 2: AGGRESSIVE TypeScript syntax removal
        print("🔧 Step 2: Removing TypeScript syntax...")

        // Remove ! after any closing parenthesis (function calls)
        let beforeNonNull = cleanedCode
        cleanedCode = cleanedCode.replacingOccurrences(of: #"\)!"#, with: ")", options: .regularExpression)
        if cleanedCode != beforeNonNull {
            print("  ✂️ Removed non-null assertions after function calls")
        }

        // Remove ! after any property access
        cleanedCode = cleanedCode.replacingOccurrences(of: #"([a-zA-Z0-9_\])\"\'])\s*!"#, with: "$1", options: .regularExpression)

        // Remove ALL generic type parameters from any identifier
        let beforeGenerics = cleanedCode

        // First pass: Remove simple generics like useRef<Type>
        cleanedCode = cleanedCode.replacingOccurrences(of: #"([a-zA-Z_][a-zA-Z0-9_]*)<[^<>]+>"#, with: "$1", options: .regularExpression)

        // Second pass: Remove nested generics like useRef<Array<Type>>
        // Keep removing until no more patterns match (handles any nesting depth)
        var previousCode = ""
        while previousCode != cleanedCode {
            previousCode = cleanedCode
            cleanedCode = cleanedCode.replacingOccurrences(of: #"([a-zA-Z_][a-zA-Z0-9_]*)<[^<>]*>"#, with: "$1", options: .regularExpression)
        }

        if cleanedCode != beforeGenerics {
            print("  ✂️ Removed generic type parameters (e.g., useRef<Type>)")
        }

        // Remove type annotations from variable declarations
        let beforeVarTypes = cleanedCode
        cleanedCode = cleanedCode.replacingOccurrences(of: #"(const|let|var)\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*:\s*[^=]+=\s*"#, with: "$1 $2 = ", options: .regularExpression)
        if cleanedCode != beforeVarTypes {
            print("  ✂️ Removed type annotations from variable declarations")
        }

        // Remove type annotations from function parameters (ALL types including primitives)
        let beforeParamTypes = cleanedCode
        // Pattern 1: Remove capital-letter types (React.FC, THREE.Mesh, etc.)
        cleanedCode = cleanedCode.replacingOccurrences(of: #":\s*[A-Z][a-zA-Z0-9<>\.\[\]|&\s]*([,)])"#, with: "$1", options: .regularExpression)
        // Pattern 2: Remove primitive types (number, string, boolean, any, void, etc.)
        cleanedCode = cleanedCode.replacingOccurrences(of: #":\s*(number|string|boolean|any|void|null|undefined|symbol|bigint)([,)])"#, with: "$2", options: .regularExpression)
        // Pattern 3: Remove array types like string[], number[]
        cleanedCode = cleanedCode.replacingOccurrences(of: #":\s*(number|string|boolean|any)\[\]([,)])"#, with: "$2", options: .regularExpression)
        // Pattern 4: Remove return type annotations from arrow functions (: Type => becomes =>)
        cleanedCode = cleanedCode.replacingOccurrences(of: #"\)\s*:\s*[A-Za-z][a-zA-Z0-9<>\.\[\]|&\s]*\s*=>"#, with: ") =>", options: .regularExpression)
        // Pattern 5: Remove return type annotations from regular functions (: Type { becomes {)
        cleanedCode = cleanedCode.replacingOccurrences(of: #"\)\s*:\s*[A-Za-z][a-zA-Z0-9<>\.\[\]|&\s]*\s*\{"#, with: ") {", options: .regularExpression)
        if cleanedCode != beforeParamTypes {
            print("  ✂️ Removed type annotations from function parameters")
        }

        // Remove React.FC type annotations
        cleanedCode = cleanedCode.replacingOccurrences(of: ": React.FC", with: "")
        cleanedCode = cleanedCode.replacingOccurrences(of: ": React.FC<", with: "")

        // Remove JSX.Element type annotations
        cleanedCode = cleanedCode.replacingOccurrences(of: ": JSX.Element", with: "")
        cleanedCode = cleanedCode.replacingOccurrences(of: ": React.ReactNode", with: "")
        cleanedCode = cleanedCode.replacingOccurrences(of: ": React.ReactElement", with: "")

        // Remove Babylon.js namespace imports (if any)
        cleanedCode = cleanedCode.replacingOccurrences(of: "import * as BABYLON from '@babylonjs/core'\n", with: "")
        cleanedCode = cleanedCode.replacingOccurrences(of: "import * as BABYLON from \"@babylonjs/core\"\n", with: "")

        // Replace 'reactylon' with 'react-babylonjs' (AI sometimes uses wrong package name)
        if cleanedCode.contains("from 'reactylon'") || cleanedCode.contains("from \"reactylon\"") {
            cleanedCode = cleanedCode.replacingOccurrences(of: "from 'reactylon'", with: "from 'react-babylonjs'")
            cleanedCode = cleanedCode.replacingOccurrences(of: "from \"reactylon\"", with: "from 'react-babylonjs'")
            print("  🔄 Replaced 'reactylon' imports with 'react-babylonjs'")
        }

        // Remove unused React imports (useRef, useState, useEffect, etc.) if they're not used
        // This prevents React bundler confusion
        if !cleanedCode.contains("useRef(") {
            cleanedCode = cleanedCode.replacingOccurrences(of: #", useRef"#, with: "")
            cleanedCode = cleanedCode.replacingOccurrences(of: #"useRef, "#, with: "")
        }
        if !cleanedCode.contains("useState(") {
            cleanedCode = cleanedCode.replacingOccurrences(of: #", useState"#, with: "")
            cleanedCode = cleanedCode.replacingOccurrences(of: #"useState, "#, with: "")
        }

        // Fix empty import braces: import React, {} from 'react' -> import React from 'react'
        cleanedCode = cleanedCode.replacingOccurrences(of: #", \{\}"#, with: "")
        cleanedCode = cleanedCode.replacingOccurrences(of: #", \{ \}"#, with: "")

        // Remove Ground from imports (it doesn't exist in react-babylonjs)
        cleanedCode = cleanedCode.replacingOccurrences(of: #", Ground"#, with: "")
        cleanedCode = cleanedCode.replacingOccurrences(of: #"Ground, "#, with: "")

        // Remove undefined components that don't exist in react-babylonjs
        // Ground component doesn't exist - remove it from JSX including comments and nested props
        // Use [\s\S]*? instead of [^>]* to properly handle multi-line JSX with nested components
        print("  🧹 Removing Ground component (with multi-line support)...")

        // First, remove JSX comments about Ground
        cleanedCode = cleanedCode.replacingOccurrences(of: #"\{/\*\s*Ground\s*\*/\}[\s\n]*"#, with: "", options: .regularExpression)

        // Remove self-closing Ground tags with multi-line props: <Ground ... />
        cleanedCode = cleanedCode.replacingOccurrences(of: #"<Ground[\s\S]*?/>[\s\n]*"#, with: "", options: .regularExpression)

        // Remove Ground tags with children: <Ground ...>...</Ground>
        cleanedCode = cleanedCode.replacingOccurrences(of: #"<Ground[\s\S]*?>[\s\S]*?</Ground>[\s\n]*"#, with: "", options: .regularExpression)

        print("  ✅ Ground component removal complete")

        print("✅ TypeScript syntax cleaning complete")

        // Clean up multiple blank lines
        while cleanedCode.contains("\n\n\n") {
            cleanedCode = cleanedCode.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        }

        // Ensure we have necessary imports
        let hasReactImport = cleanedCode.contains("import React")
        // Check for imports from EITHER react-babylonjs OR reactylon (AI may use either name)
        let hasEngineImport = cleanedCode.contains("from 'react-babylonjs'") ||
                              cleanedCode.contains("from \"react-babylonjs\"") ||
                              cleanedCode.contains("from 'reactylon'") ||
                              cleanedCode.contains("from \"reactylon\"")

        var finalCode = ""

        // Add React import if missing
        if !hasReactImport {
            finalCode += "import React from 'react';\n"
            print("➕ Added missing React import")
        }

        // Add Engine import if missing (but only if Engine is used AND no imports exist)
        if !hasEngineImport && cleanedCode.contains("<Engine") {
            finalCode += "import { Engine, Scene } from 'react-babylonjs';\n"
            print("➕ Added missing Engine import")
        }

        // Add the cleaned user code
        finalCode += cleanedCode.trimmingCharacters(in: .whitespacesAndNewlines)

        // Clean up any orphaned closing parentheses or brackets at the end
        var trimmedFinalCode = finalCode.trimmingCharacters(in: .whitespacesAndNewlines)
        while trimmedFinalCode.hasSuffix(")") || trimmedFinalCode.hasSuffix("]") || trimmedFinalCode.hasSuffix("}") {
            let lastChar = trimmedFinalCode.last!

            // Count opening and closing brackets to see if this is orphaned
            let openCount = trimmedFinalCode.filter { $0 == Character(String(lastChar).replacingOccurrences(of: ")", with: "(").replacingOccurrences(of: "]", with: "[").replacingOccurrences(of: "}", with: "{")) }.count
            let closeCount = trimmedFinalCode.filter { $0 == lastChar }.count

            if closeCount > openCount {
                // Orphaned closing bracket - remove it
                trimmedFinalCode = String(trimmedFinalCode.dropLast()).trimmingCharacters(in: .whitespacesAndNewlines)
                print("  🧹 Removed orphaned closing bracket: \(lastChar)")
            } else {
                break
            }
        }

        finalCode = trimmedFinalCode

        // Ensure we export default App
        if !finalCode.contains("export default") {
            // ALWAYS export App for Reactylon scenes
            // The App component must contain the Engine, so we can't export inner components
            if finalCode.contains("function App()") {
                finalCode += "\n\nexport default App;"
                print("➕ Added default export: App")
            } else {
                // If no App function, try to find any Engine-containing component
                if let funcMatch = finalCode.range(of: #"function\s+([A-Z][a-zA-Z0-9]*)\(\)[^{]*\{[^}]*<Engine"#, options: .regularExpression) {
                    let funcName = String(finalCode[funcMatch])
                        .replacingOccurrences(of: #"function\s+"#, with: "", options: .regularExpression)
                        .replacingOccurrences(of: #"\(\).*"#, with: "", options: .regularExpression)
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    finalCode += "\n\nexport default \(funcName);"
                    print("➕ Added default export: \(funcName) (contains Engine)")
                } else {
                    // Fallback: export App
                    finalCode += "\n\nexport default App;"
                    print("➕ Added default export: App (fallback)")
                }
            }
        }

        print("✅ Code cleaning complete (final length: \(finalCode.count))")
        print("📝 First 500 chars of cleaned code:")
        print(String(finalCode.prefix(500)))
        print("...")

        // Log the entire cleaned code for debugging
        print("================================================================================")
        print("COMPLETE CLEANED CODE (src/App.js):")
        print("================================================================================")
        print(finalCode)
        print("================================================================================")

        return finalCode
    }

    private func generateReactylonFiles(code: String) -> [String: CodeSandboxAPIFile] {
        // Clean the AI-generated code with Reactylon-specific cleaning
        let cleanedCode = cleanReactylonCode(code)

        let packageJson = """
        {
          "name": "reactylon-xraiassistant-scene",
          "version": "1.0.0",
          "description": "Reactylon scene generated by XRAiAssistant",
          "keywords": ["react", "babylonjs", "3d", "reactylon", "react-babylonjs"],
          "main": "src/index.js",
          "dependencies": {
            "react": "^18.3.1",
            "react-dom": "^18.3.1",
            "react-scripts": "5.0.1",
            "react-babylonjs": "^3.2.0",
            "@babylonjs/core": "^7.42.1",
            "@babylonjs/loaders": "^7.42.1",
            "@babylonjs/gui": "^7.42.1",
            "@babylonjs/materials": "^7.42.1"
          },
          "scripts": {
            "start": "react-scripts start",
            "build": "react-scripts build",
            "test": "react-scripts test",
            "eject": "react-scripts eject"
          },
          "eslintConfig": {
            "extends": ["react-app"]
          },
          "browserslist": {
            "production": [">0.2%", "not dead", "not op_mini all"],
            "development": ["last 1 chrome version", "last 1 firefox version", "last 1 safari version"]
          }
        }
        """

        let indexHtml = """
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="utf-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
            <meta name="theme-color" content="#000000" />
            <title>XRAiAssistant - Reactylon</title>
          </head>
          <body>
            <noscript>You need to enable JavaScript to run this app.</noscript>
            <div id="root"></div>
          </body>
        </html>
        """

        let indexJs = """
        import React, { StrictMode } from 'react';
        import { createRoot } from 'react-dom/client';
        import './index.css';
        import App from './App';

        const rootElement = document.getElementById('root');
        if (!rootElement) throw new Error('Root element not found');

        const root = createRoot(rootElement);
        root.render(
          <StrictMode>
            <App />
          </StrictMode>
        );
        """

        let gitignore = """
        # dependencies
        /node_modules
        /.pnp
        .pnp.js

        # testing
        /coverage

        # production
        /build

        # misc
        .DS_Store
        .env.local
        .env.development.local
        .env.test.local
        .env.production.local

        npm-debug.log*
        yarn-debug.log*
        yarn-error.log*
        """

        let css = """
        * {
          margin: 0;
          padding: 0;
          box-sizing: border-box;
        }

        html,
        body,
        #root {
          width: 100%;
          height: 100%;
          overflow: hidden;
        }

        body {
          background: #000;
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
            'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
            sans-serif;
          -webkit-font-smoothing: antialiased;
          -moz-osx-font-smoothing: grayscale;
        }

        canvas {
          display: block;
          touch-action: none;
        }
        """

        return [
            "package.json": CodeSandboxAPIFile(content: packageJson),
            "public/index.html": CodeSandboxAPIFile(content: indexHtml),
            "src/index.js": CodeSandboxAPIFile(content: indexJs),
            "src/App.js": CodeSandboxAPIFile(content: cleanedCode),
            "src/index.css": CodeSandboxAPIFile(content: css),
            ".gitignore": CodeSandboxAPIFile(content: gitignore)
        ]
    }
}

// MARK: - Supporting Types

struct CodeSandboxAPIFile {
    let content: String
    let isBinary: Bool
    
    init(content: String, isBinary: Bool = false) {
        self.content = content
        self.isBinary = isBinary
    }
}

enum CodeSandboxAPIError: LocalizedError {
    case invalidResponse
    case apiError(statusCode: Int, message: String)
    case jsonSerializationFailed
    case noAPIKey
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from CodeSandbox API"
        case .apiError(let statusCode, let message):
            return "CodeSandbox API error (\(statusCode)): \(message)"
        case .jsonSerializationFailed:
            return "Failed to serialize JSON parameters"
        case .noAPIKey:
            return "CodeSandbox API key not configured"
        }
    }
}
