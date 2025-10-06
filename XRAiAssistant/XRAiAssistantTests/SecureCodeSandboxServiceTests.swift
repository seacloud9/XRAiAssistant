import XCTest
@testable import XRAiAssistant

final class SecureCodeSandboxServiceTests: XCTestCase {

    var service: SecureCodeSandboxService!

    override func setUpWithError() throws {
        service = SecureCodeSandboxService()
    }

    override func tearDownWithError() throws {
        service = nil
    }

    // MARK: - Complete App Tests

    func testCompleteReactThreeFiberApp() throws {
        let completeAppCode = """
        import React, { useRef } from 'react'
        import { createRoot } from 'react-dom/client'
        import { Canvas, useFrame } from '@react-three/fiber'
        import { OrbitControls } from '@react-three/drei'
        import * as THREE from 'three'

        const Rainbow = () => {
          const colors = ['red', 'orange', 'yellow', 'green', 'blue', 'indigo', 'violet']
          return (
            <>
              {colors.map((color, index) => (
                <mesh key={index} position={[index - 3, 0, 0]}>
                  <boxGeometry args={[0.5, 0.5, 0.5]} />
                  <meshStandardMaterial color={color} />
                </mesh>
              ))}
            </>
          )
        }

        function Scene() {
          return (
            <>
              <ambientLight intensity={0.8} />
              <directionalLight position={[2, 2, 2]} intensity={1} />
              <Rainbow />
              <OrbitControls />
            </>
          )
        }

        function App() {
          return (
            <Canvas
              style={{ width: '100%', height: '100%' }}
              camera={{ position: [0, 0, 5], fov: 75 }}
              gl={{ antialias: true }}
            >
              <Scene />
            </Canvas>
          )
        }

        const root = createRoot(document.getElementById('root')!)
        root.render(<App />)
        """

        let url = service.createTemplateBasedSandbox(code: completeAppCode, framework: "reactThreeFiber")

        // Should detect complete app and create minimal file structure
        XCTAssertTrue(url.contains("codesandbox.io"))
        XCTAssertTrue(url.contains("react-three-fiber"))

        // Should contain the complete code
        let decodedURL = url.removingPercentEncoding ?? url
        XCTAssertTrue(decodedURL.contains("Rainbow"))
        XCTAssertTrue(decodedURL.contains("createRoot"))
        XCTAssertTrue(decodedURL.contains("Canvas"))
    }

    func testSceneOnlyCode() throws {
        let sceneOnlyCode = """
        const RotatingCube = () => {
          const meshRef = useRef()

          useFrame((state, delta) => {
            meshRef.current.rotation.x += delta * 0.5
            meshRef.current.rotation.y += delta * 0.2
          })

          return (
            <mesh ref={meshRef} position={[0, 1, 0]}>
              <boxGeometry args={[1, 1, 1]} />
              <meshStandardMaterial color="hotpink" />
            </mesh>
          )
        }

        function Scene() {
          return (
            <>
              <RotatingCube />
            </>
          )
        }
        """

        let url = service.createTemplateBasedSandbox(code: sceneOnlyCode, framework: "reactThreeFiber")

        // Should wrap scene-only code in App structure
        XCTAssertTrue(url.contains("codesandbox.io"))
        XCTAssertTrue(url.contains("react-three-fiber"))

        let decodedURL = url.removingPercentEncoding ?? url
        XCTAssertTrue(decodedURL.contains("RotatingCube"))
        XCTAssertTrue(decodedURL.contains("meshStandardMaterial"))
    }

    // MARK: - Security Tests

    func testXSSPrevention() throws {
        let maliciousCode = """
        <script>alert('XSS')</script>
        function Scene() {
          eval('dangerous code');
          return (
            <mesh onClick={() => document.write('<script>alert("hack")</script>')}>
              <boxGeometry />
              <meshStandardMaterial color="red" />
            </mesh>
          )
        }
        """

        let url = service.createTemplateBasedSandbox(code: maliciousCode, framework: "reactThreeFiber")
        let decodedURL = url.removingPercentEncoding ?? url

        // Should remove dangerous patterns
        XCTAssertFalse(decodedURL.contains("<script>"))
        XCTAssertFalse(decodedURL.contains("eval"))
        XCTAssertFalse(decodedURL.contains("document.write"))
        XCTAssertTrue(decodedURL.contains("/* eval removed for security */"))
    }

    func testDangerousFunctionRemoval() throws {
        let codeWithDangerousFunctions = """
        function Scene() {
          const handleClick = () => {
            eval('some code');
            element.innerHTML = '<script>bad</script>';
            element.outerHTML = '<div>bad</div>';
            document.write('bad content');
          }

          return (
            <mesh onClick={handleClick}>
              <boxGeometry />
              <meshStandardMaterial color="blue" />
            </mesh>
          )
        }
        """

        let url = service.createTemplateBasedSandbox(code: codeWithDangerousFunctions, framework: "reactThreeFiber")
        let decodedURL = url.removingPercentEncoding ?? url

        // All dangerous functions should be commented out
        XCTAssertTrue(decodedURL.contains("/* eval removed for security */"))
        XCTAssertTrue(decodedURL.contains("/* innerHTML removed for security */"))
        XCTAssertTrue(decodedURL.contains("/* outerHTML removed for security */"))
        XCTAssertTrue(decodedURL.contains("/* document.write removed for security */"))

        // Safe React Three Fiber code should remain
        XCTAssertTrue(decodedURL.contains("meshStandardMaterial"))
        XCTAssertTrue(decodedURL.contains("boxGeometry"))
    }

    // MARK: - Framework Detection Tests

    func testReactThreeFiberFrameworkDetection() throws {
        let r3fCode = """
        function Scene() {
          return (
            <mesh>
              <sphereGeometry />
              <meshStandardMaterial color="orange" />
            </mesh>
          )
        }
        """

        let url = service.createTemplateBasedSandbox(code: r3fCode, framework: "reactThreeFiber")

        XCTAssertTrue(url.contains("react-three-fiber"))

        let decodedURL = url.removingPercentEncoding ?? url
        XCTAssertTrue(decodedURL.contains("@react-three/fiber"))
        XCTAssertTrue(decodedURL.contains("@react-three/drei"))
        XCTAssertTrue(decodedURL.contains("three"))
    }

    func testReactylonFrameworkDetection() throws {
        let reactylonCode = """
        function Scene() {
          return (
            <babylonMesh>
              <babylonSphereGeometry />
              <babylonStandardMaterial />
            </babylonMesh>
          )
        }
        """

        let url = service.createTemplateBasedSandbox(code: reactylonCode, framework: "reactylon")

        XCTAssertTrue(url.contains("react-three-fiber")) // Uses R3F template for now
    }

    func testUnknownFrameworkDefaultsToR3F() throws {
        let genericCode = """
        function Scene() {
          return <div>Hello World</div>
        }
        """

        let url = service.createTemplateBasedSandbox(code: genericCode, framework: "unknown")

        XCTAssertTrue(url.contains("react-three-fiber"))
    }

    // MARK: - URL Generation Tests

    func testURLStructure() throws {
        let simpleCode = "function Scene() { return <mesh><boxGeometry /></mesh> }"
        let url = service.createTemplateBasedSandbox(code: simpleCode, framework: "reactThreeFiber")

        // Should be a valid CodeSandbox URL
        XCTAssertTrue(url.hasPrefix("https://codesandbox.io/s/"))
        XCTAssertTrue(url.contains("react-three-fiber"))
        XCTAssertTrue(url.contains("file=/src/"))
        XCTAssertTrue(url.contains("initialcode="))
    }

    func testURLEncoding() throws {
        let codeWithSpecialChars = """
        function Scene() {
          const message = "Hello & welcome to React Three Fiber!"
          return (
            <Text position={[0, 0, 0]} fontSize={1}>
              {message}
            </Text>
          )
        }
        """

        let url = service.createTemplateBasedSandbox(code: codeWithSpecialChars, framework: "reactThreeFiber")

        // Should properly encode special characters
        XCTAssertTrue(url.contains("%20")) // Space encoding
        XCTAssertTrue(url.contains("%26")) // & encoding
        XCTAssertTrue(url.contains("%22")) // Quote encoding
    }

    // MARK: - Package.json Tests

    func testPackageJsonDependencies() throws {
        let simpleCode = "function Scene() { return null }"
        let url = service.createTemplateBasedSandbox(code: simpleCode, framework: "reactThreeFiber")
        let decodedURL = url.removingPercentEncoding ?? url

        // Should include all required React Three Fiber dependencies
        XCTAssertTrue(decodedURL.contains("@react-three/fiber"))
        XCTAssertTrue(decodedURL.contains("@react-three/drei"))
        XCTAssertTrue(decodedURL.contains("react"))
        XCTAssertTrue(decodedURL.contains("react-dom"))
        XCTAssertTrue(decodedURL.contains("three"))

        // Should include TypeScript dev dependencies
        XCTAssertTrue(decodedURL.contains("@types/react"))
        XCTAssertTrue(decodedURL.contains("typescript"))
    }

    // MARK: - Edge Cases

    func testEmptyCode() throws {
        let url = service.createTemplateBasedSandbox(code: "", framework: "reactThreeFiber")

        // Should still create valid URL with empty scene
        XCTAssertTrue(url.contains("codesandbox.io"))
        XCTAssertTrue(url.contains("react-three-fiber"))
    }

    func testVeryLongCode() throws {
        let longCode = String(repeating: "// This is a very long comment that should be handled properly\n", count: 100) +
        """
        function Scene() {
          return (
            <mesh>
              <boxGeometry />
              <meshStandardMaterial color="red" />
            </mesh>
          )
        }
        """

        let url = service.createTemplateBasedSandbox(code: longCode, framework: "reactThreeFiber")

        // Should handle long code without issues
        XCTAssertTrue(url.contains("codesandbox.io"))
        XCTAssertTrue(url.contains("boxGeometry"))
    }

    func testUnicodeCharacters() throws {
        let unicodeCode = """
        function Scene() {
          const emoji = "🌈✨🎨"
          return (
            <Text position={[0, 0, 0]}>
              {emoji} Unicode Rainbow {emoji}
            </Text>
          )
        }
        """

        let url = service.createTemplateBasedSandbox(code: unicodeCode, framework: "reactThreeFiber")

        // Should handle Unicode characters properly
        XCTAssertTrue(url.contains("codesandbox.io"))
        let decodedURL = url.removingPercentEncoding ?? url
        XCTAssertTrue(decodedURL.contains("Unicode Rainbow"))
    }

    // MARK: - Performance Tests

    func testPerformanceWithMultipleCalls() throws {
        let simpleCode = "function Scene() { return <mesh><boxGeometry /></mesh> }"

        measure {
            for _ in 0..<100 {
                let _ = service.createTemplateBasedSandbox(code: simpleCode, framework: "reactThreeFiber")
            }
        }
    }
}

// MARK: - Test Extensions

extension SecureCodeSandboxServiceTests {

    /// Test helper to verify that generated URLs are valid CodeSandbox URLs
    private func assertValidCodeSandboxURL(_ url: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(url.hasPrefix("https://codesandbox.io/s/"), "URL should start with CodeSandbox base", file: file, line: line)
        XCTAssertTrue(url.contains("file=/src/"), "URL should specify a file to open", file: file, line: line)
        XCTAssertTrue(url.contains("initialcode="), "URL should contain initial code parameter", file: file, line: line)
    }

    /// Test helper to verify security sanitization
    private func assertCodeSanitized(_ url: String, originalCode: String, file: StaticString = #file, line: UInt = #line) {
        let decodedURL = url.removingPercentEncoding ?? url

        // Check that dangerous patterns are removed
        let dangerousPatterns = ["<script", "eval(", "innerHTML", "outerHTML", "document.write"]
        for pattern in dangerousPatterns {
            if originalCode.contains(pattern) {
                XCTAssertFalse(decodedURL.contains(pattern), "Dangerous pattern '\(pattern)' should be removed", file: file, line: line)
            }
        }
    }
}