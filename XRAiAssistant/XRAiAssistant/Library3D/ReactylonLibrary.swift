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
        
        import React, { useRef, useState } from 'react'
        import { createRoot } from 'react-dom/client'
        import {
          Engine, Scene, ArcRotateCamera, HemisphericLight,
          Box, Sphere, Ground, StandardMaterial, PBRMaterial,
          XRExperience, WebXRCamera
        } from 'reactylon'
        
        function XRScene() {
          // Component logic here
          return (
            <Engine antialias adaptToDeviceRatio canvasId="canvas">
              <Scene clearColor="#2c2c54">
                <ArcRotateCamera 
                  target={[0, 0, 0]} 
                  alpha={Math.PI / 4} 
                  beta={Math.PI / 3} 
                  radius={10} 
                />
                <HemisphericLight direction={[0, 1, 0]} intensity={0.9} />
                
                {/* Your XR components here */}
                
                <XRExperience 
                  baseExperience={true}
                  floorMeshes={["ground"]}
                />
              </Scene>
            </Engine>
          )
        }
        
        function App() {
          return <XRScene />
        }
        
        const root = createRoot(document.getElementById('root')!)
        root.render(<App />)
        
        CRITICAL RULES:
        - ALWAYS use TypeScript syntax with proper type annotations
        - Import React components and hooks from 'react'
        - Import Reactylon components from 'reactylon'
        - Use functional components with hooks (useRef, useState, useEffect, etc.)
        - Mount to the existing #root div element
        - Always include XRExperience for WebXR capabilities
        - Use canvasId="canvas" for the Engine component
        
        IMPORTANT REACTYLON PATTERNS:
        - Use <Engine> as the root component with canvas configuration
        - Use <Scene> to define the 3D world with lighting and camera
        - Use declarative mesh components: <Box>, <Sphere>, <Ground>
        - Use material components: <StandardMaterial>, <PBRMaterial>
        - Use camera components: <ArcRotateCamera>, <WebXRCamera>
        - Use light components: <HemisphericLight>, <DirectionalLight>
        - Use <XRExperience> for WebXR/AR/VR functionality
        - Position objects with position={[x, y, z]} props
        - Apply materials with material references or inline props
        
        XR-SPECIFIC GUIDELINES:
        - Always include XRExperience for immersive capabilities
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

        import React, { useRef, useState } from 'react'
        import { createRoot } from 'react-dom/client'
        import {
          Engine, Scene, ArcRotateCamera, HemisphericLight,
          Box, Sphere, Ground, StandardMaterial,
          XRExperience
        } from 'reactylon'

        function InteractiveXRScene() {
          const [cubeColor, setCubeColor] = useState("#ff6b6b")
          const [cubePosition, setCubePosition] = useState([0, 1, 0])
          
          const handleCubeClick = () => {
            const colors = ["#ff6b6b", "#4ecdc4", "#45b7d1", "#96ceb4", "#ffeaa7"]
            const randomColor = colors[Math.floor(Math.random() * colors.length)]
            setCubeColor(randomColor)
            
            // Add a little bounce animation
            const randomY = 1 + Math.random() * 2
            setCubePosition([0, randomY, 0])
            
            setTimeout(() => setCubePosition([0, 1, 0]), 500)
          }
          
          return (
            <Engine antialias adaptToDeviceRatio canvasId="canvas">
              <Scene clearColor="#2c2c54">
                <ArcRotateCamera 
                  target={[0, 0, 0]} 
                  alpha={Math.PI / 4} 
                  beta={Math.PI / 3} 
                  radius={8} 
                />
                <HemisphericLight direction={[0, 1, 0]} intensity={0.9} />
                
                {/* Interactive cube */}
                <Box 
                  name="interactiveCube"
                  size={1.5}
                  position={cubePosition}
                  onClick={handleCubeClick}
                >
                  <StandardMaterial 
                    diffuseColor={cubeColor}
                    specularColor="#ffffff"
                    specularPower={64}
                  />
                </Box>
                
                {/* Floating spheres */}
                <Sphere 
                  name="sphere1"
                  diameter={0.8}
                  position={[-3, 2, 0]}
                >
                  <StandardMaterial diffuseColor="#4ecdc4" />
                </Sphere>
                
                <Sphere 
                  name="sphere2"
                  diameter={0.6}
                  position={[3, 1.5, -1]}
                >
                  <StandardMaterial diffuseColor="#45b7d1" />
                </Sphere>
                
                {/* Ground plane */}
                <Ground 
                  name="ground"
                  width={10}
                  height={10}
                  subdivisions={20}
                >
                  <StandardMaterial 
                    diffuseColor="#34495e"
                    specularColor="#2c3e50"
                  />
                </Ground>
                
                {/* WebXR Experience */}
                <XRExperience 
                  baseExperience={true}
                  floorMeshes={["ground"]}
                />
              </Scene>
            </Engine>
          )
        }

        function App() {
          return <InteractiveXRScene />
        }

        const root = createRoot(document.getElementById('root')!)
        root.render(<App />)
        """
    }
}