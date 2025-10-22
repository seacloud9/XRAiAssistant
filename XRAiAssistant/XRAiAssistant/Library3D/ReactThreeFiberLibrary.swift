import Foundation

struct ReactThreeFiberLibrary: Library3D {
    let id = "reactThreeFiber"
    let displayName = "React Three Fiber"
    let description = "React renderer for Three.js with declarative components"
    let version = "8.17.10"
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
        - Always provide COMPLETE working code for a React Three Fiber app
        - Your code must follow this exact structure:

        import React, { useRef } from 'react'
        import { Canvas, useFrame } from '@react-three/fiber'
        import { OrbitControls } from '@react-three/drei'

        function RotatingBox() {
          const meshRef = useRef(null)

          useFrame((state, delta) => {
            if (meshRef.current) {
              meshRef.current.rotation.x += delta
            }
          })

          return (
            <mesh ref={meshRef}>
              <boxGeometry args={[1, 1, 1]} />
              <meshStandardMaterial color="orange" />
            </mesh>
          )
        }

        function App() {
          return (
            <Canvas
              style={{ width: '100%', height: '100%' }}
              camera={{ position: [0, 0, 5], fov: 75 }}
              gl={{ antialias: true }}
            >
              <ambientLight intensity={0.5} />
              <directionalLight position={[2, 2, 2]} intensity={1} />
              <RotatingBox />
              <OrbitControls />
            </Canvas>
          )
        }

        export default App

        CRITICAL RULES:
        - DO NOT include createRoot or root.render - the build system handles mounting
        - DO NOT import from 'react-dom/client' - not needed in App.js
        - ALWAYS export default App at the end
        - Import React and hooks from 'react'
        - Import Canvas and hooks from '@react-three/fiber'
        - Import helper components from '@react-three/drei'
        - Use functional components with hooks (useRef, useFrame, useThree, etc.)
        - Canvas should have style={{ width: '100%', height: '100%' }}
        - Use null checks when accessing refs: if (meshRef.current) { ... }
        
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
        import { Canvas, useFrame } from '@react-three/fiber'
        import { OrbitControls } from '@react-three/drei'

        function RotatingCube() {
          const meshRef = useRef(null)

          useFrame((state, delta) => {
            if (meshRef.current) {
              meshRef.current.rotation.x += delta * 0.5
              meshRef.current.rotation.y += delta * 0.2
            }
          })

          return (
            <mesh ref={meshRef} position={[0, 1, 0]}>
              <boxGeometry args={[1, 1, 1]} />
              <meshStandardMaterial color="hotpink" />
            </mesh>
          )
        }

        function App() {
          return (
            <Canvas
              style={{ width: '100%', height: '100%' }}
              camera={{ position: [3, 3, 3], fov: 75 }}
              gl={{ antialias: true }}
            >
              <ambientLight intensity={0.6} />
              <directionalLight position={[2, 2, 2]} intensity={1} />

              <RotatingCube />

              {/* Ground plane */}
              <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, -0.5, 0]}>
                <planeGeometry args={[10, 10]} />
                <meshStandardMaterial color="#888888" />
              </mesh>

              <OrbitControls />
            </Canvas>
          )
        }

        export default App
        """
    }

    var examples: [CodeExample] {
        return [
            // Basic Examples
            CodeExample(
                title: "Floating Crystals",
                description: "Beautiful rotating crystals with gradient materials and glow effects",
                code: """
import React, { useRef } from 'react'
import { Canvas, useFrame } from '@react-three/fiber'
import { OrbitControls, MeshTransmissionMaterial } from '@react-three/drei'

function Crystal({ position, color, scale = 1 }) {
  const meshRef = useRef(null)

  useFrame((state) => {
    if (meshRef.current) {
      meshRef.current.rotation.y = state.clock.elapsedTime * 0.5
      meshRef.current.position.y = position[1] + Math.sin(state.clock.elapsedTime + position[0]) * 0.2
    }
  })

  return (
    <mesh ref={meshRef} position={position} scale={scale}>
      <octahedronGeometry args={[1, 0]} />
      <meshStandardMaterial
        color={color}
        metalness={0.9}
        roughness={0.1}
        emissive={color}
        emissiveIntensity={0.3}
      />
    </mesh>
  )
}

function App() {
  return (
    <Canvas camera={{ position: [0, 0, 8], fov: 50 }}>
      <color attach="background" args={['#050510']} />
      <ambientLight intensity={0.3} />
      <pointLight position={[10, 10, 10]} intensity={1} />
      <pointLight position={[-10, -10, -10]} color="#4080ff" intensity={0.5} />

      <Crystal position={[-2, 0, 0]} color="#ff6b9d" scale={0.8} />
      <Crystal position={[0, 0, 0]} color="#4080ff" scale={1.2} />
      <Crystal position={[2, 0, 0]} color="#ffd93d" scale={0.9} />

      <OrbitControls enableDamping dampingFactor={0.05} />
    </Canvas>
  )
}

export default App
""",
                category: .basic,
                difficulty: .beginner
            ),

            CodeExample(
                title: "Animated Galaxy",
                description: "Stunning galaxy with thousands of particles in spiral formation",
                code: """
import React, { useRef, useMemo } from 'react'
import { Canvas, useFrame } from '@react-three/fiber'
import { OrbitControls } from '@react-three/drei'
import * as THREE from 'three'

function Galaxy() {
  const points = useRef(null)

  const particlesPosition = useMemo(() => {
    const positions = new Float32Array(5000 * 3)
    const colors = new Float32Array(5000 * 3)

    for (let i = 0; i < 5000; i++) {
      const radius = Math.random() * 6
      const spinAngle = radius * 2
      const branchAngle = (i % 3) * ((2 * Math.PI) / 3)

      const randomX = Math.pow(Math.random(), 3) * (Math.random() < 0.5 ? 1 : -1)
      const randomY = Math.pow(Math.random(), 3) * (Math.random() < 0.5 ? 1 : -1)
      const randomZ = Math.pow(Math.random(), 3) * (Math.random() < 0.5 ? 1 : -1)

      positions[i * 3] = Math.cos(branchAngle + spinAngle) * radius + randomX
      positions[i * 3 + 1] = randomY
      positions[i * 3 + 2] = Math.sin(branchAngle + spinAngle) * radius + randomZ

      const mixedColor = new THREE.Color('#ff6030').lerp(new THREE.Color('#1b3984'), radius / 6)
      colors[i * 3] = mixedColor.r
      colors[i * 3 + 1] = mixedColor.g
      colors[i * 3 + 2] = mixedColor.b
    }

    return { positions, colors }
  }, [])

  useFrame((state) => {
    if (points.current) {
      points.current.rotation.y = state.clock.elapsedTime * 0.05
    }
  })

  return (
    <points ref={points}>
      <bufferGeometry>
        <bufferAttribute
          attach="attributes-position"
          count={particlesPosition.positions.length / 3}
          array={particlesPosition.positions}
          itemSize={3}
        />
        <bufferAttribute
          attach="attributes-color"
          count={particlesPosition.colors.length / 3}
          array={particlesPosition.colors}
          itemSize={3}
        />
      </bufferGeometry>
      <pointsMaterial
        size={0.1}
        sizeAttenuation={true}
        depthWrite={false}
        vertexColors={true}
        blending={THREE.AdditiveBlending}
      />
    </points>
  )
}

function App() {
  return (
    <Canvas camera={{ position: [0, 3, 8] }}>
      <color attach="background" args={['#000000']} />
      <Galaxy />
      <OrbitControls enableDamping autoRotate autoRotateSpeed={0.5} />
    </Canvas>
  )
}

export default App
""",
                category: .effects,
                difficulty: .intermediate
            ),

            // Animation Examples
            CodeExample(
                title: "Bouncing Balls Physics",
                description: "Colorful balls with realistic bouncing physics and trails",
                code: """
import React, { useRef } from 'react'
import { Canvas, useFrame } from '@react-three/fiber'
import { OrbitControls, Trail } from '@react-three/drei'

function BouncingBall({ position, color, speed = 1 }) {
  const meshRef = useRef(null)
  const velocity = useRef(0)
  const posY = useRef(position[1])

  useFrame((state, delta) => {
    if (meshRef.current) {
      velocity.current -= 9.8 * delta * speed
      posY.current += velocity.current * delta

      if (posY.current < 0.5) {
        posY.current = 0.5
        velocity.current = Math.abs(velocity.current) * 0.8
      }

      meshRef.current.position.y = posY.current
      meshRef.current.rotation.x += delta * 2
      meshRef.current.rotation.z += delta * 3
    }
  })

  return (
    <Trail width={2} length={8} color={color} attenuation={(t) => t * t}>
      <mesh ref={meshRef} position={position} castShadow>
        <sphereGeometry args={[0.5, 32, 32]} />
        <meshStandardMaterial
          color={color}
          metalness={0.3}
          roughness={0.4}
          emissive={color}
          emissiveIntensity={0.2}
        />
      </mesh>
    </Trail>
  )
}

function App() {
  return (
    <Canvas shadows camera={{ position: [0, 3, 10], fov: 50 }}>
      <color attach="background" args={['#1a1a2e']} />
      <ambientLight intensity={0.4} />
      <directionalLight position={[5, 10, 5]} intensity={1} castShadow />
      <pointLight position={[-5, 5, -5]} color="#ff6b9d" intensity={0.5} />

      <BouncingBall position={[-2, 5, 0]} color="#ff6b9d" speed={1} />
      <BouncingBall position={[0, 8, 0]} color="#4ecdc4" speed={0.8} />
      <BouncingBall position={[2, 6, 0]} color="#ffe66d" speed={1.2} />

      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, 0, 0]} receiveShadow>
        <planeGeometry args={[20, 20]} />
        <meshStandardMaterial color="#0f3460" roughness={0.8} />
      </mesh>

      <OrbitControls />
    </Canvas>
  )
}

export default App
""",
                category: .animation,
                difficulty: .intermediate
            ),

            // Interaction Example
            CodeExample(
                title: "Interactive Color Spheres",
                description: "Click spheres to change colors with smooth transitions",
                code: """
import React, { useRef, useState } from 'react'
import { Canvas, useFrame } from '@react-three/fiber'
import { OrbitControls, Text } from '@react-three/drei'
import * as THREE from 'three'

function InteractiveSphere({ position }) {
  const meshRef = useRef(null)
  const [hovered, setHovered] = useState(false)
  const [active, setActive] = useState(false)
  const [color, setColor] = useState('#4080ff')

  const colors = ['#ff6b9d', '#4080ff', '#4ecdc4', '#ffe66d', '#a26cf7']

  useFrame((state) => {
    if (meshRef.current) {
      meshRef.current.scale.x = THREE.MathUtils.lerp(
        meshRef.current.scale.x,
        hovered ? 1.3 : active ? 1.15 : 1,
        0.1
      )
      meshRef.current.scale.y = meshRef.current.scale.x
      meshRef.current.scale.z = meshRef.current.scale.x

      meshRef.current.rotation.y += 0.01
    }
  })

  const handleClick = () => {
    setActive(!active)
    setColor(colors[Math.floor(Math.random() * colors.length)])
  }

  return (
    <mesh
      ref={meshRef}
      position={position}
      onClick={handleClick}
      onPointerOver={() => setHovered(true)}
      onPointerOut={() => setHovered(false)}
    >
      <sphereGeometry args={[0.8, 32, 32]} />
      <meshStandardMaterial
        color={color}
        metalness={0.5}
        roughness={0.2}
        emissive={color}
        emissiveIntensity={active ? 0.5 : 0.1}
      />
    </mesh>
  )
}

function App() {
  return (
    <Canvas camera={{ position: [0, 0, 8] }}>
      <color attach="background" args={['#0a0a1a']} />
      <ambientLight intensity={0.5} />
      <pointLight position={[10, 10, 10]} intensity={1} />

      <Text position={[0, 3, 0]} fontSize={0.5} color="#ffffff">
        Click the spheres!
      </Text>

      <InteractiveSphere position={[-2.5, 0, 0]} />
      <InteractiveSphere position={[0, 0, 0]} />
      <InteractiveSphere position={[2.5, 0, 0]} />

      <OrbitControls />
    </Canvas>
  )
}

export default App
""",
                category: .interaction,
                difficulty: .intermediate
            ),

            // Advanced Example
            CodeExample(
                title: "Holographic Torus Wave",
                description: "Mesmerizing wave of torus rings with holographic shader effect",
                code: """
import React, { useRef } from 'react'
import { Canvas, useFrame } from '@react-three/fiber'
import { OrbitControls, MeshDistortMaterial } from '@react-three/drei'

function TorusWave({ index, total }) {
  const meshRef = useRef(null)
  const offset = (index / total) * Math.PI * 2

  useFrame((state) => {
    if (meshRef.current) {
      const time = state.clock.elapsedTime
      meshRef.current.position.y = Math.sin(time + offset) * 2
      meshRef.current.rotation.x = time * 0.3
      meshRef.current.rotation.z = time * 0.2

      const scale = 1 + Math.sin(time + offset) * 0.2
      meshRef.current.scale.setScalar(scale)
    }
  })

  const hue = (index / total) * 360
  const color = `hsl(${hue}, 80%, 60%)`

  return (
    <mesh ref={meshRef} position={[0, 0, index * 1.5 - (total * 1.5) / 2]}>
      <torusGeometry args={[1, 0.3, 16, 100]} />
      <MeshDistortMaterial
        color={color}
        metalness={0.8}
        roughness={0.2}
        distort={0.4}
        speed={2}
        emissive={color}
        emissiveIntensity={0.3}
      />
    </mesh>
  )
}

function App() {
  const count = 8

  return (
    <Canvas camera={{ position: [0, 0, 15], fov: 60 }}>
      <color attach="background" args={['#000511']} />
      <ambientLight intensity={0.3} />
      <pointLight position={[10, 10, 10]} intensity={1} color="#ffffff" />
      <pointLight position={[-10, -10, -10]} intensity={0.5} color="#ff00ff" />

      {Array.from({ length: count }).map((_, i) => (
        <TorusWave key={i} index={i} total={count} />
      ))}

      <OrbitControls
        enableDamping
        dampingFactor={0.05}
        autoRotate
        autoRotateSpeed={0.5}
      />
    </Canvas>
  )
}

export default App
""",
                category: .advanced,
                difficulty: .advanced
            )
        ]
    }
}