import Foundation

class CodeSandboxService {
    static let shared = CodeSandboxService()
    private let defineAPIURL = "https://codesandbox.io/api/v1/sandboxes/define"

    private init() {}

    // MARK: - Main API Functions

    func createReactThreeFiberSandbox(code: String) async throws -> String {
        let files = generateReactThreeFiberFiles(userCode: code)
        return try await createSandbox(files: files)
    }

    func createReactylonSandbox(code: String) async throws -> String {
        let files = generateReactylonFiles(userCode: code)
        return try await createSandbox(files: files)
    }

    // MARK: - Core API Implementation

    private func createSandbox(files: [String: CodeSandboxFile]) async throws -> String {
        var request = URLRequest(url: URL(string: defineAPIURL)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody = [
            "files": files.mapValues { file in
                ["content": file.content, "isBinary": file.isBinary] as [String: Any]
            }
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        print("🚀 CodeSandbox API - Creating sandbox...")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CodeSandboxError.invalidResponse
        }

        print("📡 CodeSandbox API - Response status: \(httpResponse.statusCode)")

        guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            print("❌ CodeSandbox API - Error response: \(String(data: data, encoding: .utf8) ?? "unknown")")
            throw CodeSandboxError.apiError(httpResponse.statusCode)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let sandboxId = json["sandbox_id"] as? String else {
            print("❌ CodeSandbox API - Invalid JSON response: \(String(data: data, encoding: .utf8) ?? "unknown")")
            throw CodeSandboxError.invalidJSON
        }

        let embedUrl = "https://codesandbox.io/embed/\(sandboxId)"
        print("✅ CodeSandbox API - Sandbox created: \(embedUrl)")

        return embedUrl
    }

    // MARK: - React Three Fiber Template

    private func generateReactThreeFiberFiles(userCode: String) -> [String: CodeSandboxFile] {
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
            "build": "react-scripts build",
            "test": "react-scripts test --env=jsdom",
            "eject": "react-scripts eject"
          },
          "browserslist": [">0.2%", "not dead", "not ie <= 11", "not op_mini all"]
        }
        """

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

        let indexHtml = """
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
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
                  'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue', sans-serif;
                -webkit-font-smoothing: antialiased;
                -moz-osx-font-smoothing: grayscale;
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

        return [
            "package.json": CodeSandboxFile(content: packageJson),
            "src/index.js": CodeSandboxFile(content: indexJs),
            "src/App.js": CodeSandboxFile(content: appJs),
            "src/Scene.js": CodeSandboxFile(content: sceneJs),
            "public/index.html": CodeSandboxFile(content: indexHtml)
        ]
    }

    // MARK: - Reactylon Template

    private func generateReactylonFiles(userCode: String) -> [String: CodeSandboxFile] {
        let packageJson = """
        {
          "name": "xraiassistant-reactylon-scene",
          "version": "1.0.0",
          "description": "XRAiAssistant generated Reactylon scene",
          "keywords": ["react", "babylon", "reactylon", "3d", "xr"],
          "main": "src/index.js",
          "dependencies": {
            "@babylonjs/core": "^6.0.0",
            "@babylonjs/loaders": "^6.0.0",
            "@babylonjs/materials": "^6.0.0",
            "react": "^18.2.0",
            "react-dom": "^18.2.0",
            "reactylon": "^1.0.0"
          },
          "devDependencies": {
            "@types/react": "^18.2.0",
            "@types/react-dom": "^18.2.0",
            "typescript": "^5.0.0"
          },
          "scripts": {
            "start": "react-scripts start",
            "build": "react-scripts build",
            "test": "react-scripts test --env=jsdom",
            "eject": "react-scripts eject"
          },
          "browserslist": [">0.2%", "not dead", "not ie <= 11", "not op_mini all"]
        }
        """

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
        import { Engine, Scene, Camera, HemisphericLight, DirectionalLight } from 'reactylon';
        import SceneContent from './Scene';

        export default function App() {
          return (
            <div style={{ width: '100vw', height: '100vh' }}>
              <Engine antialias adaptToDeviceRatio>
                <Scene>
                  <Camera
                    name="camera"
                    position={[0, 0, 5]}
                    setTarget={[0, 0, 0]}
                  />
                  <HemisphericLight
                    name="hemiLight"
                    direction={[0, 1, 0]}
                    intensity={0.5}
                  />
                  <DirectionalLight
                    name="dirLight"
                    direction={[0, -1, 0]}
                    position={[10, 10, 10]}
                    intensity={1}
                  />
                  <SceneContent />
                </Scene>
              </Engine>
            </div>
          );
        }
        """

        let sceneJs = """
        import React from 'react';
        import { Box, Sphere } from 'reactylon';

        \(userCode)

        export default SceneContent;
        """

        let indexHtml = """
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="utf-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
            <meta name="theme-color" content="#000000" />
            <title>XRAiAssistant - Reactylon Scene</title>
            <style>
              body {
                margin: 0;
                padding: 0;
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
                  'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue', sans-serif;
                -webkit-font-smoothing: antialiased;
                -moz-osx-font-smoothing: grayscale;
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

        return [
            "package.json": CodeSandboxFile(content: packageJson),
            "src/index.js": CodeSandboxFile(content: indexJs),
            "src/App.js": CodeSandboxFile(content: appJs),
            "src/Scene.js": CodeSandboxFile(content: sceneJs),
            "public/index.html": CodeSandboxFile(content: indexHtml)
        ]
    }

    // MARK: - Helper Functions

    private func createParameters(files: [String: CodeSandboxFile]) -> String {
        // This would normally use LZ-string compression, but for simplicity
        // we'll use the direct POST API which doesn't require compression
        return ""
    }
}

// MARK: - Supporting Types

struct CodeSandboxFile {
    let content: String
    let isBinary: Bool

    init(content: String, isBinary: Bool = false) {
        self.content = content
        self.isBinary = isBinary
    }
}

enum CodeSandboxError: Error, LocalizedError {
    case invalidResponse
    case apiError(Int)
    case invalidJSON
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from CodeSandbox API"
        case .apiError(let code):
            return "CodeSandbox API error: \(code)"
        case .invalidJSON:
            return "Invalid JSON response from CodeSandbox API"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}