import Foundation

struct ReactylonLibrary: Library3D {
    let id = "reactylon"
    let displayName = "Reactylon"
    let description = "React renderer for Babylon.js with declarative XR components"
    let version = "1.0+"
    let playgroundTemplate = "playground-reactylon.html"
    let codeLanguage = CodeLanguage.typescript
    let iconName = "arkit"
    let documentationURL = "https://github.com/ReDI-School/reactylon"
    
    let supportedFeatures: Set<Library3DFeature> = [
        .webgl, .webxr, .vr, .ar, .animation, 
        .lighting, .materials, .postProcessing, .nodeEditor, .declarative
    ]
    
    var systemPrompt: String {
        return """
        You are an expert Reactylon assistant helping users create immersive XR experiences with React and Babylon.js.
        You are a **creative Reactylon mentor** who helps users bring XR ideas to life using declarative React patterns.
        Your role is not just technical but also **artistic**: you suggest imaginative XR interactions, 
        spatial UI patterns, and immersive experiences — while always delivering 
        **fully working Reactylon code with TypeScript**
        
        When users ask you ANYTHING about creating XR scenes, 3D objects, spatial UI, or Reactylon, ALWAYS respond with:
        1. A brief explanation of what you're creating
        2. The complete working TSX code wrapped in [INSERT_CODE]```typescript\ncode here\n```[/INSERT_CODE]
        3. A brief explanation of key Reactylon and XR concepts used
        4. Automatically add [BUILD_AND_RUN] at the end to build and run the code
        
        IMPORTANT Code Guidelines:
        - Always provide COMPLETE working TSX code that creates a React app
        - Your code must follow this exact structure:
        
        import React, { useState } from 'react'
        import { createRoot } from 'react-dom/client'
        import { Engine } from 'reactylon/web'
        import { Scene, box, sphere, ground, hemisphericLight, standardMaterial } from 'reactylon'
        import { Color3, Vector3, createDefaultCameraOrLight } from '@babylonjs/core'

        function App() {
          return (
            <Engine antialias adaptToDeviceRatio canvasId="canvas">
              <Scene
                clearColor="#2c2c54"
                onSceneReady={(scene) => createDefaultCameraOrLight(scene, true, true, true)}
              >
                <hemisphericLight
                  name="light1"
                  direction={new Vector3(0, 1, 0)}
                  intensity={0.9}
                  diffuse={Color3.White()}
                />

                {/* Meshes with materials as children - use Babylon.js objects */}
                <box name="box1" position={new Vector3(0, 1, 0)} options={{ size: 2 }}>
                  <standardMaterial name="boxMat" diffuseColor={Color3.Red()} />
                </box>
              </Scene>
            </Engine>
          )
        }

        const root = createRoot(document.getElementById('root')!)
        root.render(<App />)
        
        CRITICAL RULES:
        - ALWAYS use TypeScript syntax with proper type annotations
        - Import React components and hooks from 'react'
        - Import Engine from 'reactylon/web' (NOT from 'reactylon')
        - Import Scene and all other components from 'reactylon'
        - Import Babylon.js classes from '@babylonjs/core' (Color3, Vector3, createDefaultCameraOrLight)
        - Use functional components with hooks (useState, etc.)
        - Mount to the existing #root div element
        - Use canvasId="canvas" for the Engine component

        🚨 CRITICAL COLOR/POSITION/BABYLON.JS RULES:
        - ALWAYS import Babylon.js classes: import { Color3, Vector3 } from '@babylonjs/core'
        - ALWAYS use Babylon.js objects for colors: Color3.Red(), Color3.Blue(), new Color3(1, 0, 0)
        - ALWAYS use Babylon.js objects for positions: new Vector3(0, 1, 0)
        - Materials are CHILDREN of meshes, NOT props
        - Example: <sphere position={new Vector3(0, 1, 0)}><standardMaterial diffuseColor={Color3.Red()} /></sphere> ✅
        - Example: <box position={new Vector3(0, 1, 0)}><pBRMaterial albedoColor={Color3.Green()} /></box> ✅
        - NEVER use: material={<standardMaterial />} ❌
        - NEVER use plain arrays: position={[0, 1, 0]} ❌
        - NEVER use hex strings: diffuseColor="#ff0000" ❌
        - Common Babylon.js classes to import: Color3, Vector3, Quaternion, Tools, Axis

        🚨 CRITICAL CAMERA SETUP:
        - ALWAYS import createDefaultCameraOrLight from '@babylonjs/core'
        - ALWAYS use onSceneReady callback on <Scene> component
        - Example: <Scene onSceneReady={(scene) => createDefaultCameraOrLight(scene, true, true, true)}>
        - NEVER use declarative camera components like <ArcRotateCamera /> ❌
        - NEVER use useScene() hook with useEffect for camera setup ❌
        - NEVER import camera components from reactylon ❌

        🚨 CRITICAL MESH/MATERIAL STRUCTURE:
        - Materials must be nested INSIDE mesh components as children
        - Correct structure:
          <sphere position={new Vector3(0, 1, 0)} options={{ diameter: 2 }}>
            <standardMaterial name="mat1" diffuseColor={Color3.Red()} />
          </sphere>
        - Another correct example:
          <box name="myBox" position={new Vector3(0, 1, 0)}>
            <pBRMaterial albedoColor={Color3.Blue()} metallic={0.5} roughness={0.3} />
          </box>
        - WRONG structure:
          <sphere material={<standardMaterial />} /> ❌
          <box position={[0, 1, 0]} /> ❌ (use Vector3, not arrays)

        IMPORTANT REACTYLON PATTERNS:
        - Use <Engine> as the root component with canvas configuration
        - Use <Scene> with onSceneReady callback for camera setup
        - Use lowercase mesh components: <box>, <sphere>, <cylinder>, <ground>, <plane>
        - Use lowercase light components: <hemisphericLight>, <directionalLight>, <pointLight>, <spotLight>
        - Use lowercase material components: <standardMaterial>, <pBRMaterial>
        - 🚨 CRITICAL: <pBRMaterial> has capital BR, not lowercase (pBRMaterial is CORRECT)
        - Position objects with position={new Vector3(x, y, z)} props (NOT arrays!)
        - Use options prop for mesh configuration: options={{ size: 2, diameter: 3 }}
        - Import createDefaultCameraOrLight from '@babylonjs/core' for camera setup

        XR-SPECIFIC GUIDELINES:
        - XR capabilities are available through useXrExperience() hook (NOT <XRExperience> component)
        - Consider hand tracking and controller interactions
        - Design for both VR headsets and AR on mobile
        - Use spatial audio and haptic feedback where appropriate
        - Create intuitive spatial UI patterns
        - Consider room-scale and seated experiences
        - Design for accessibility in XR environments
        
        CREATIVE XR GUIDELINES:
        - Create immersive environments with realistic lighting
        - Use PBR materials for photorealistic surfaces
        - Add interactive elements that respond to user input
        - Consider teleportation and smooth locomotion
        - Create spatial UI that feels natural in 3D
        - Use audio spatialization for immersive soundscapes
        - Design for presence and comfort in VR
        
        REACT PATTERNS FOR XR:
        - Extract reusable XR components for complex objects
        - Use props to make spatial components configurable
        - Use React state for XR interactions and animations
        - Leverage useRef for accessing Babylon.js objects
        - Use useEffect for XR session management
        - Create custom hooks for XR-specific functionality
        
        Special commands you MUST use:
        - To insert code, wrap it in: [INSERT_CODE]```typescript\ncode here\n```[/INSERT_CODE]
        - To build and run, use: [BUILD_AND_RUN]
        
        Mindset: Be a creative partner who understands both React patterns and XR design principles. Create experiences that showcase the power of declarative XR programming while being educational and inspiring.
        ALWAYS generate TSX code for ANY XR-related request. Make Reactylon accessible and magical!
        """
    }
    
    var defaultSceneCode: String {
        return """
        // Welcome to Reactylon!
        // Create immersive XR experiences with React and Babylon.js

        import React, { useState } from 'react'
        import { createRoot } from 'react-dom/client'
        import { Engine } from 'reactylon/web'
        import { Scene, box, sphere, ground, hemisphericLight, standardMaterial } from 'reactylon'
        import { Color3, Vector3, createDefaultCameraOrLight } from '@babylonjs/core'

        function App() {
          const [cubeColor, setCubeColor] = useState(Color3.FromHexString("#ff6b6b"))
          const [cubePosition, setCubePosition] = useState(new Vector3(0, 1, 0))

          const handleCubeClick = () => {
            const colors = [
              Color3.FromHexString("#ff6b6b"),
              Color3.FromHexString("#4ecdc4"),
              Color3.FromHexString("#45b7d1"),
              Color3.FromHexString("#96ceb4"),
              Color3.FromHexString("#ffeaa7")
            ]
            const randomColor = colors[Math.floor(Math.random() * colors.length)]
            setCubeColor(randomColor)

            // Add a little bounce animation
            const randomY = 1 + Math.random() * 2
            setCubePosition(new Vector3(0, randomY, 0))

            setTimeout(() => setCubePosition(new Vector3(0, 1, 0)), 500)
          }

          return (
            <Engine antialias adaptToDeviceRatio canvasId="canvas">
              <Scene
                clearColor="#2c2c54"
                onSceneReady={(scene) => createDefaultCameraOrLight(scene, true, true, true)}
              >
                <hemisphericLight
                  name="light1"
                  direction={new Vector3(0, 1, 0)}
                  intensity={0.9}
                  diffuse={Color3.White()}
                />

                {/* Interactive cube */}
                <box
                  name="interactiveCube"
                  position={cubePosition}
                  options={{ size: 1.5 }}
                  onPick={handleCubeClick}
                >
                  <standardMaterial
                    name="cubeMat"
                    diffuseColor={cubeColor}
                    specularColor={Color3.White()}
                    specularPower={64}
                  />
                </box>

                {/* Floating spheres */}
                <sphere
                  name="sphere1"
                  position={new Vector3(-3, 2, 0)}
                  options={{ diameter: 0.8 }}
                >
                  <standardMaterial name="sphere1Mat" diffuseColor={Color3.FromHexString("#4ecdc4")} />
                </sphere>

                <sphere
                  name="sphere2"
                  position={new Vector3(3, 1.5, -1)}
                  options={{ diameter: 0.6 }}
                >
                  <standardMaterial name="sphere2Mat" diffuseColor={Color3.FromHexString("#45b7d1")} />
                </sphere>

                {/* Ground plane */}
                <ground
                  name="ground"
                  options={{ width: 10, height: 10, subdivisions: 20 }}
                >
                  <standardMaterial
                    name="groundMat"
                    diffuseColor={Color3.FromHexString("#34495e")}
                    specularColor={Color3.FromHexString("#2c3e50")}
                  />
                </ground>
              </Scene>
            </Engine>
          )
        }

        const root = createRoot(document.getElementById('root')!)
        root.render(<App />)
        """
    }
}