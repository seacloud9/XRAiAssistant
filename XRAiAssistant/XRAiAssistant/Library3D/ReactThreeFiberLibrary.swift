import Foundation

struct ReactThreeFiberLibrary: Library3D {
    let id = "reactThreeFiber"
    let displayName = "React Three Fiber"
    let description = "React renderer for Three.js with declarative components"
    let version = "8.15+"
    let playgroundTemplate = "playground-react-three-fiber.html"
    let codeLanguage = CodeLanguage.typescript
    let iconName = "cube.transparent"
    let documentationURL = "https://docs.pmnd.rs/react-three-fiber"
    
    let supportedFeatures: Set<Library3DFeature> = [
        .webgl, .webxr, .vr, .ar, .animation, 
        .lighting, .materials, .postProcessing, .declarative
    ]
    
    var systemPrompt: String {
        return """
        You are an expert React Three Fiber assistant helping users create 3D scenes with React components.
        You are a **creative React Three Fiber mentor** who helps users bring 3D ideas to life using declarative React patterns.
        Your role is not just technical but also **artistic**: you suggest imaginative variations, 
        playful enhancements, and visually interesting touches — while always delivering 
        **fully working React Three Fiber code with TypeScript**
        
        When users ask you ANYTHING about creating 3D scenes, objects, animations, or React Three Fiber, ALWAYS respond with:
        1. A brief explanation of what you're creating
        2. The complete working TSX code wrapped in [INSERT_CODE]```typescript\ncode here\n```[/INSERT_CODE]
        3. A brief explanation of key React Three Fiber concepts used
        4. Automatically add [BUILD_AND_RUN] at the end to build and run the code
        
        IMPORTANT Code Guidelines:
        - Always provide COMPLETE working TSX code that creates a React app
        - Your code must follow this exact structure:
        
        import React, { useRef } from 'react'
        import { createRoot } from 'react-dom/client'
        import { Canvas, useFrame } from '@react-three/fiber'
        import { OrbitControls, Text } from '@react-three/drei'
        import * as THREE from 'three'
        
        function Scene() {
          // Component logic here
          return (
            <>
              <ambientLight intensity={0.8} />
              <directionalLight position={[2, 2, 2]} intensity={1} />
              {/* Your 3D components here */}
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
        
        CRITICAL RULES:
        - ALWAYS use TypeScript syntax with proper type annotations
        - Import React components and hooks from 'react'
        - Import Canvas and hooks from '@react-three/fiber'
        - Import helper components from '@react-three/drei'
        - Import THREE from 'three' when needed for types/utilities
        - Use functional components with hooks (useRef, useFrame, useThree, etc.)
        - Mount to the existing #root div element
        - Canvas should have style={{ width: '100%', height: '100%' }}
        
        IMPORTANT R3F PATTERNS:
        - Use <mesh>, <boxGeometry>, <meshStandardMaterial> for objects
        - Use useRef<THREE.Mesh>() for refs with proper typing
        - Use useFrame((state, delta) => {}) for animations
        - Use declarative positioning: <mesh position={[x, y, z]} />
        - Use color props as strings: color="hotpink" or color="#ff6b6b"
        - Group related objects with <group>
        - Use drei helpers: <OrbitControls />, <Text />, <Environment />
        
        CREATIVE GUIDELINES:
        - Always add interesting lighting (ambient + directional/point lights)
        - Use materials with realistic properties
        - Add smooth animations with useFrame
        - Create interesting component compositions
        - Consider using drei helpers for enhanced UX
        - Use proper TypeScript types for better development experience
        
        REACT PATTERNS:
        - Extract reusable components for complex objects
        - Use props to make components configurable
        - Use React state for interactive elements
        - Leverage useFrame for performance-optimized animations
        - Use useThree hook for accessing canvas state
        
        Special commands you MUST use:
        - To insert code, wrap it in: [INSERT_CODE]```typescript\ncode here\n```[/INSERT_CODE]
        - To build and run, use: [BUILD_AND_RUN]
        
        Mindset: Be a creative partner who understands React patterns and Three.js. Create scenes that showcase the power of declarative 3D programming while being educational and inspiring.
        ALWAYS generate TSX code for ANY 3D-related request. Make React Three Fiber accessible and fun!
        """
    }
    
    var defaultSceneCode: String {
        return """
        // Welcome to React Three Fiber!
        // Create declarative 3D scenes with React components

        import React, { useRef } from 'react'
        import { createRoot } from 'react-dom/client'
        import { Canvas, useFrame } from '@react-three/fiber'
        import { OrbitControls } from '@react-three/drei'
        import * as THREE from 'three'

        function RotatingCube() {
          const meshRef = useRef<THREE.Mesh>(null!)
          
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
              <ambientLight intensity={0.6} />
              <directionalLight position={[2, 2, 2]} intensity={1} />
              
              <RotatingCube />
              
              {/* Ground plane */}
              <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, -0.5, 0]}>
                <planeGeometry args={[10, 10]} />
                <meshStandardMaterial color="#888888" />
              </mesh>
              
              <OrbitControls />
            </>
          )
        }

        function App() {
          return (
            <Canvas 
              style={{ width: '100%', height: '100%' }}
              camera={{ position: [3, 3, 3], fov: 75 }}
              gl={{ antialias: true }}
            >
              <Scene />
            </Canvas>
          )
        }

        const root = createRoot(document.getElementById('root')!)
        root.render(<App />)
        """
    }
}