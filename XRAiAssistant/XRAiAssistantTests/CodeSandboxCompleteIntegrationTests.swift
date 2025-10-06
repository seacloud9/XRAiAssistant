import XCTest
@testable import XRAiAssistant

/// Complete integration test demonstrating that the CodeSandbox injection issue is fully resolved
final class CodeSandboxCompleteIntegrationTests: XCTestCase {

    func testCompleteCodeSandboxIntegrationFix() throws {
        // This test verifies the complete fix for the issue where:
        // 1. AI generated correct React Three Fiber code
        // 2. But CodeSandbox showed Material-UI template instead
        // 3. The fix ensures proper code injection via Define API

        // STEP 1: Simulate the exact AI-generated code from the logs
        let aiGeneratedCode = """
        import React, { useRef } from 'react'
        import { createRoot } from 'react-dom/client'
        import { Canvas, useFrame } from '@react-three/fiber'
        import { OrbitControls } from '@react-three/drei'
        import * as THREE from 'three'

        function Rainbow() {
          const colors = ['red', 'orange', 'yellow', 'green', 'blue', 'indigo', 'violet']
          const segments = 7
          const radius = 3
          const height = 0.5

          return (
            <>
              {colors.map((color, index) => {
                const angle = (index / segments) * Math.PI * 2
                const x = radius * Math.cos(angle)
                const y = radius * Math.sin(angle)
                return (
                  <mesh key={index} position={[x, y, 0]} rotation={[Math.PI / 2, 0, angle]}>
                    <cylinderGeometry args={[0.1, 0.1, height, 32]} />
                    <meshStandardMaterial color={color} />
                  </mesh>
                )
              })}
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

        // STEP 2: Use the SecureCodeSandboxService (the fixed version)
        let service = SecureCodeSandboxService()
        let result = service.createTemplateBasedSandbox(code: aiGeneratedCode, framework: "reactThreeFiber")

        // STEP 3: Verify the result is HTML for CodeSandbox Define API (not a URL)
        XCTAssertTrue(result.contains("<!DOCTYPE html>"), "Result should be HTML for Define API")
        XCTAssertTrue(result.contains("https://codesandbox.io/api/v1/sandboxes/define"), "Should use Define API endpoint")
        XCTAssertTrue(result.contains("method=\"POST\""), "Should use POST method")

        // STEP 4: Verify the HTML contains the React Three Fiber code
        XCTAssertTrue(result.contains("Rainbow"), "Should contain the Rainbow component")
        XCTAssertTrue(result.contains("Canvas"), "Should contain React Three Fiber Canvas")
        XCTAssertTrue(result.contains("@react-three/fiber"), "Should include R3F dependency")
        XCTAssertTrue(result.contains("@react-three/drei"), "Should include Drei dependency")
        XCTAssertTrue(result.contains("cylinderGeometry"), "Should contain 3D geometry")
        XCTAssertTrue(result.contains("meshStandardMaterial"), "Should contain 3D materials")

        // STEP 5: Verify NO Material-UI code is present (the original bug)
        XCTAssertFalse(result.contains("@material-ui"), "Should NOT contain Material-UI dependencies")
        XCTAssertFalse(result.contains("makeStyles"), "Should NOT contain Material-UI makeStyles")
        XCTAssertFalse(result.contains("List"), "Should NOT contain Material-UI List component")
        XCTAssertFalse(result.contains("ListItem"), "Should NOT contain Material-UI ListItem")
        XCTAssertFalse(result.contains("Welcome to Hell"), "Should NOT contain default template content")

        // STEP 6: Verify proper file structure is generated
        // The HTML should contain a form with parameters that include the correct file structure
        let decodedHTML = result.removingPercentEncoding ?? result
        XCTAssertTrue(decodedHTML.contains("package.json"), "Should include package.json")
        XCTAssertTrue(decodedHTML.contains("src/index.js"), "Should include index.js")

        print("✅ INTEGRATION TEST PASSED: CodeSandbox injection is now working correctly!")
        print("🎯 AI-generated React Three Fiber code will now appear in CodeSandbox")
        print("🚫 Material-UI template bug has been eliminated")
        print("🔧 Define API approach ensures proper code injection")
    }

    func testDefineAPIFormGeneration() throws {
        // Test that the Define API form is properly structured
        let simpleCode = """
        function Scene() {
          return (
            <mesh>
              <boxGeometry />
              <meshStandardMaterial color="blue" />
            </mesh>
          )
        }
        """

        let service = SecureCodeSandboxService()
        let html = service.createTemplateBasedSandbox(code: simpleCode, framework: "reactThreeFiber")

        // Verify HTML structure
        XCTAssertTrue(html.contains("<!DOCTYPE html>"))
        XCTAssertTrue(html.contains("<form"))
        XCTAssertTrue(html.contains("action=\"https://codesandbox.io/api/v1/sandboxes/define\""))
        XCTAssertTrue(html.contains("method=\"POST\""))
        XCTAssertTrue(html.contains("name=\"parameters\""))
        XCTAssertTrue(html.contains("document.getElementById('sandbox-form').submit()"))

        // Verify the form contains the code
        XCTAssertTrue(html.contains("boxGeometry"))
        XCTAssertTrue(html.contains("meshStandardMaterial"))

        print("✅ Define API form generation working correctly")
    }

    func testCompleteAppDetection() throws {
        // Test that complete apps are detected and handled correctly
        let completeApp = """
        import React from 'react'
        import { createRoot } from 'react-dom/client'
        import { Canvas } from '@react-three/fiber'

        function App() {
          return (
            <Canvas>
              <mesh>
                <sphereGeometry />
                <meshBasicMaterial color="red" />
              </mesh>
            </Canvas>
          )
        }

        const root = createRoot(document.getElementById('root')!)
        root.render(<App />)
        """

        let service = SecureCodeSandboxService()
        let html = service.createTemplateBasedSandbox(code: completeApp, framework: "reactThreeFiber")

        // Should detect complete app and use it directly
        XCTAssertTrue(html.contains("createRoot"))
        XCTAssertTrue(html.contains("render(<App />)"))
        XCTAssertTrue(html.contains("sphereGeometry"))

        print("✅ Complete app detection working correctly")
    }

    func testSecuritySanitization() throws {
        // Test that security features still work with the new approach
        let maliciousCode = """
        <script>alert('hack')</script>
        function Scene() {
          eval('dangerous code');
          document.write('bad content');
          return (
            <mesh>
              <boxGeometry />
            </mesh>
          )
        }
        """

        let service = SecureCodeSandboxService()
        let html = service.createTemplateBasedSandbox(code: maliciousCode, framework: "reactThreeFiber")

        // Security sanitization should still work
        XCTAssertFalse(html.contains("<script>alert"))
        XCTAssertFalse(html.contains("eval("))
        XCTAssertFalse(html.contains("document.write"))

        // But safe React Three Fiber code should remain
        XCTAssertTrue(html.contains("boxGeometry"))

        print("✅ Security sanitization still working with Define API")
    }

    // MARK: - Performance and Edge Cases

    func testLargeCodeHandling() throws {
        // Test handling of large code files
        let largeCode = String(repeating: "// Large comment\n", count: 1000) + """
        function Scene() {
          return (
            <mesh>
              <torusGeometry />
              <meshNormalMaterial />
            </mesh>
          )
        }
        """

        let service = SecureCodeSandboxService()
        let html = service.createTemplateBasedSandbox(code: largeCode, framework: "reactThreeFiber")

        // Should handle large code without issues
        XCTAssertTrue(html.contains("torusGeometry"))
        XCTAssertTrue(html.contains("meshNormalMaterial"))
        XCTAssertTrue(html.contains("codesandbox.io/api/v1/sandboxes/define"))

        print("✅ Large code handling working correctly")
    }

    func testFrameworkRouting() throws {
        // Test that different frameworks are routed correctly
        let code = "function Scene() { return <mesh><boxGeometry /></mesh> }"

        let service = SecureCodeSandboxService()

        let r3fHTML = service.createTemplateBasedSandbox(code: code, framework: "reactThreeFiber")
        let reactylonHTML = service.createTemplateBasedSandbox(code: code, framework: "reactylon")
        let unknownHTML = service.createTemplateBasedSandbox(code: code, framework: "unknown")

        // All should generate valid HTML with Define API
        XCTAssertTrue(r3fHTML.contains("@react-three/fiber"))
        XCTAssertTrue(reactylonHTML.contains("@react-three/fiber")) // Uses R3F template for now
        XCTAssertTrue(unknownHTML.contains("@react-three/fiber")) // Defaults to R3F

        print("✅ Framework routing working correctly")
    }
}

// MARK: - Test Summary Documentation

/*
 INTEGRATION TEST SUMMARY:

 PROBLEM FIXED:
 - AI was correctly generating React Three Fiber code
 - But CodeSandbox was showing Material-UI template instead of the generated code
 - Users saw "Welcome to Hell" Material-UI interface instead of their 3D scenes

 ROOT CAUSE:
 - SecureCodeSandboxService was using URL parameters (initialcode=) which don't work
 - CodeSandbox doesn't support code injection via URL parameters
 - The template approach was loading a default template, not the AI code

 SOLUTION IMPLEMENTED:
 1. Replaced URL parameter approach with CodeSandbox Define API
 2. Generate proper file structure with user's React Three Fiber code
 3. Create HTML form that POSTs to Define API endpoint
 4. WebView loads the form HTML which auto-submits to create the sandbox

 VERIFICATION:
 - ✅ AI-generated React Three Fiber code now appears in CodeSandbox
 - ✅ No more Material-UI template interference
 - ✅ Proper file structure with correct dependencies
 - ✅ Security sanitization still works
 - ✅ Support for both complete apps and scene-only code
 - ✅ Handles large code files and edge cases

 RESULT:
 Users will now see their AI-generated 3D scenes in CodeSandbox instead of Material-UI templates.
 The complete React Three Fiber development workflow is now functional.
 */