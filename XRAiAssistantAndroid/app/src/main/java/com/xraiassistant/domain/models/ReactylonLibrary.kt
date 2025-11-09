package com.xraiassistant.domain.models

/**
 * Reactylon Library Implementation
 * React renderer for Babylon.js with declarative XR components
 */
class ReactylonLibrary : Library3D {
    override val id = "reactylon"
    override val displayName = "Reactylon"
    override val description = "React renderer for Babylon.js with declarative XR components"
    override val version = "1.0+"
    override val playgroundTemplate = "playground-reactylon.html"
    override val codeLanguage = CodeLanguage.TYPESCRIPT
    override val iconName = "arkit"
    override val documentationURL = "https://github.com/ReDI-School/reactylon"
    override val requiresBuild = true

    override val supportedFeatures = setOf(
        Library3DFeature.WEBGL, Library3DFeature.WEBXR, Library3DFeature.VR,
        Library3DFeature.AR, Library3DFeature.ANIMATION, Library3DFeature.LIGHTING,
        Library3DFeature.MATERIALS, Library3DFeature.POST_PROCESSING, Library3DFeature.NODE_EDITOR,
        Library3DFeature.DECLARATIVE
    )

    override val systemPrompt = """
        You are an expert Reactylon assistant helping users create immersive XR experiences with React and Babylon.js.
        You are a **creative Reactylon mentor** who helps users bring XR ideas to life using declarative React patterns.
        Your role is not just technical but also **artistic**: you suggest imaginative XR interactions,
        spatial UI patterns, and immersive experiences — while always delivering
        **fully working Reactylon code with TypeScript**

        When users ask you ANYTHING about creating XR scenes, 3D objects, spatial UI, or Reactylon, ALWAYS respond with:
        1. A brief explanation of what you're creating
        2. The complete working TSX code wrapped in [INSERT_CODE]```typescript
code here
```[/INSERT_CODE]
        3. A brief explanation of key Reactylon and XR concepts used
        4. Automatically add [RUN_SCENE] at the end to trigger code execution

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
        - To insert code, wrap it in: [INSERT_CODE]```typescript
code here
```[/INSERT_CODE]
        - To trigger code execution, use: [RUN_SCENE]

        Mindset: Be a creative partner who understands both React patterns and XR design principles. Create experiences that showcase the power of declarative XR programming while being educational and inspiring.
        ALWAYS generate TSX code for ANY XR-related request. Make Reactylon accessible and magical!
    """.trimIndent()

    override val defaultSceneCode = """
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

                {/* Interactive box */}
                <box
                  name="interactiveBox"
                  position={cubePosition}
                  options={{ size: 1 }}
                >
                  <standardMaterial name="boxMat" diffuseColor={cubeColor} />
                </box>

                {/* Sphere */}
                <sphere
                  name="sphere1"
                  position={new Vector3(-2, 1, 0)}
                  options={{ diameter: 1.2 }}
                >
                  <standardMaterial
                    name="sphereMat"
                    diffuseColor={Color3.FromHexString("#4ecdc4")}
                  />
                </sphere>

                {/* Ground plane */}
                <ground
                  name="ground1"
                  options={{ width: 10, height: 10 }}
                >
                  <standardMaterial
                    name="groundMat"
                    diffuseColor={Color3.FromHexString("#95e1d3")}
                  />
                </ground>
              </Scene>
            </Engine>
          )
        }

        const root = createRoot(document.getElementById('root')!)
        root.render(<App />)
    """.trimIndent()

    override val examples = listOf(
        CodeExample(
            title = "Floating Gems",
            description = "Beautiful floating gems with React state and Babylon.js materials",
            code = """
                import React, { useState, useEffect } from 'react'
                import { Engine } from 'reactylon/web'
                import { Scene, box, sphere, hemisphericLight, standardMaterial } from 'reactylon'
                import { Color3, Vector3, createDefaultCameraOrLight } from '@babylonjs/core'

                function App() {
                  const [rotationSpeed, setRotationSpeed] = useState(0.01)

                  return (
                    <Engine antialias adaptToDeviceRatio canvasId="canvas">
                      <Scene
                        clearColor="#0a0a1a"
                        onSceneReady={(scene) => {
                          createDefaultCameraOrLight(scene, true, true, true)

                          // Animate gems
                          scene.registerBeforeRender(() => {
                            const time = Date.now() * 0.001
                            const gem1 = scene.getMeshByName("gem1")
                            const gem2 = scene.getMeshByName("gem2")
                            const gem3 = scene.getMeshByName("gem3")

                            if (gem1) {
                              gem1.rotation.y += rotationSpeed
                              gem1.position.y = 1.5 + Math.sin(time) * 0.3
                            }
                            if (gem2) {
                              gem2.rotation.y += rotationSpeed
                              gem2.position.y = 1.5 + Math.sin(time + 2) * 0.3
                            }
                            if (gem3) {
                              gem3.rotation.y += rotationSpeed
                              gem3.position.y = 1.5 + Math.sin(time + 4) * 0.3
                            }
                          })
                        }}
                      >
                        <hemisphericLight
                          name="light1"
                          direction={new Vector3(0, 1, 0)}
                          intensity={0.8}
                        />

                        {/* Pink Gem */}
                        <box
                          name="gem1"
                          position={new Vector3(-2.5, 1.5, 0)}
                          options={{ size: 1.2 }}
                        >
                          <standardMaterial
                            name="gem1Mat"
                            diffuseColor={Color3.FromHexString("#ff6b9d")}
                            specularColor={Color3.White()}
                            emissiveColor={Color3.FromHexString("#ff6b9d")}
                          />
                        </box>

                        {/* Blue Gem */}
                        <sphere
                          name="gem2"
                          position={new Vector3(0, 1.5, 0)}
                          options={{ diameter: 1.5 }}
                        >
                          <standardMaterial
                            name="gem2Mat"
                            diffuseColor={Color3.FromHexString("#4080ff")}
                            specularColor={Color3.White()}
                            emissiveColor={Color3.FromHexString("#4080ff")}
                          />
                        </sphere>

                        {/* Gold Gem */}
                        <box
                          name="gem3"
                          position={new Vector3(2.5, 1.5, 0)}
                          options={{ size: 1.2 }}
                        >
                          <standardMaterial
                            name="gem3Mat"
                            diffuseColor={Color3.FromHexString("#ffd93d")}
                            specularColor={Color3.White()}
                            emissiveColor={Color3.FromHexString("#ffd93d")}
                          />
                        </box>

                        {/* Ground */}
                        <ground
                          name="ground"
                          options={{ width: 15, height: 15 }}
                        >
                          <standardMaterial
                            name="groundMat"
                            diffuseColor={Color3.FromHexString("#1a1a2e")}
                          />
                        </ground>
                      </Scene>
                    </Engine>
                  )
                }

                export default App
            """.trimIndent(),
            category = ExampleCategory.BASIC,
            difficulty = ExampleDifficulty.BEGINNER
        ),

        CodeExample(
            title = "Interactive Color Boxes",
            description = "Click boxes to cycle through colors with React state management",
            code = """
                import React, { useState } from 'react'
                import { Engine } from 'reactylon/web'
                import { Scene, box, hemisphericLight, pointLight, ground, standardMaterial } from 'reactylon'
                import { Color3, Vector3, createDefaultCameraOrLight } from '@babylonjs/core'

                function ColorBox({ position, initialColor, name }) {
                  const colors = [
                    Color3.FromHexString("#ff6b9d"),
                    Color3.FromHexString("#4080ff"),
                    Color3.FromHexString("#4ecdc4"),
                    Color3.FromHexString("#ffe66d"),
                    Color3.FromHexString("#a26cf7")
                  ]

                  const [colorIndex, setColorIndex] = useState(0)

                  const handleClick = () => {
                    setColorIndex((prev) => (prev + 1) % colors.length)
                  }

                  return (
                    <box
                      name={name}
                      position={position}
                      options={{ size: 1.5 }}
                      onPick={handleClick}
                    >
                      <standardMaterial
                        name={`${'$'}{name}Mat`}
                        diffuseColor={colors[colorIndex]}
                        specularColor={Color3.White()}
                        specularPower={64}
                      />
                    </box>
                  )
                }

                function App() {
                  return (
                    <Engine antialias adaptToDeviceRatio canvasId="canvas">
                      <Scene
                        clearColor="#0f0f20"
                        onSceneReady={(scene) => createDefaultCameraOrLight(scene, true, true, true)}
                      >
                        <hemisphericLight
                          name="ambient"
                          direction={new Vector3(0, 1, 0)}
                          intensity={0.6}
                        />

                        <pointLight
                          name="pointLight1"
                          position={new Vector3(5, 5, 5)}
                          intensity={0.8}
                        />

                        <ColorBox
                          position={new Vector3(-3, 1, 0)}
                          initialColor="#ff6b9d"
                          name="box1"
                        />

                        <ColorBox
                          position={new Vector3(0, 1, 0)}
                          initialColor="#4080ff"
                          name="box2"
                        />

                        <ColorBox
                          position={new Vector3(3, 1, 0)}
                          initialColor="#4ecdc4"
                          name="box3"
                        />

                        <ground
                          name="ground"
                          options={{ width: 12, height: 12 }}
                        >
                          <standardMaterial
                            name="groundMat"
                            diffuseColor={Color3.FromHexString("#1a1a2e")}
                            specularColor={Color3.FromHexString("#0f3460")}
                          />
                        </ground>
                      </Scene>
                    </Engine>
                  )
                }

                export default App
            """.trimIndent(),
            category = ExampleCategory.INTERACTION,
            difficulty = ExampleDifficulty.INTERMEDIATE
        ),

        CodeExample(
            title = "Animated Rainbow Spheres",
            description = "Multiple spheres with rainbow colors and wave animation",
            code = """
                import React, { useEffect } from 'react'
                import { Engine } from 'reactylon/web'
                import { Scene, sphere, hemisphericLight, ground, pBRMaterial } from 'reactylon'
                import { Color3, Vector3, createDefaultCameraOrLight } from '@babylonjs/core'

                function App() {
                  const count = 7

                  return (
                    <Engine antialias adaptToDeviceRatio canvasId="canvas">
                      <Scene
                        clearColor="#000511"
                        onSceneReady={(scene) => {
                          createDefaultCameraOrLight(scene, true, true, true)

                          // Wave animation
                          scene.registerBeforeRender(() => {
                            const time = Date.now() * 0.001

                            for (let i = 0; i < count; i++) {
                              const sphereMesh = scene.getMeshByName(`sphere${'$'}{i}`)
                              if (sphereMesh) {
                                const offset = (i / count) * Math.PI * 2
                                sphereMesh.position.y = 1.5 + Math.sin(time + offset) * 1.2
                                sphereMesh.rotation.y = time * 0.5
                              }
                            }
                          })
                        }}
                      >
                        <hemisphericLight
                          name="light"
                          direction={new Vector3(0, 1, 0)}
                          intensity={0.7}
                        />

                        {Array.from({ length: count }).map((_, i) => {
                          const hue = (i / count) * 360
                          const r = Math.abs(Math.sin((hue * Math.PI) / 180))
                          const g = Math.abs(Math.sin(((hue + 120) * Math.PI) / 180))
                          const b = Math.abs(Math.sin(((hue + 240) * Math.PI) / 180))

                          return (
                            <sphere
                              key={i}
                              name={`sphere${'$'}{i}`}
                              position={new Vector3((i - count / 2) * 2, 1.5, 0)}
                              options={{ diameter: 1.2 }}
                            >
                              <pBRMaterial
                                name={`mat${'$'}{i}`}
                                albedoColor={new Color3(r, g, b)}
                                metallic={0.9}
                                roughness={0.1}
                                emissiveColor={new Color3(r * 0.5, g * 0.5, b * 0.5)}
                              />
                            </sphere>
                          )
                        })}

                        <ground
                          name="ground"
                          options={{ width: 20, height: 20 }}
                        >
                          <pBRMaterial
                            name="groundMat"
                            albedoColor={Color3.FromHexString("#0a0a1a")}
                            metallic={0.2}
                            roughness={0.8}
                          />
                        </ground>
                      </Scene>
                    </Engine>
                  )
                }

                export default App
            """.trimIndent(),
            category = ExampleCategory.ANIMATION,
            difficulty = ExampleDifficulty.INTERMEDIATE
        ),

        CodeExample(
            title = "Dynamic Material Playground",
            description = "Control material properties with React state and sliders",
            code = """
                import React, { useState } from 'react'
                import { Engine } from 'reactylon/web'
                import { Scene, sphere, box, cylinder, hemisphericLight, pBRMaterial } from 'reactylon'
                import { Color3, Vector3, createDefaultCameraOrLight } from '@babylonjs/core'

                function App() {
                  const [metallic, setMetallic] = useState(0.5)
                  const [roughness, setRoughness] = useState(0.5)
                  const [emissive, setEmissive] = useState(0.2)

                  return (
                    <div style={{ width: '100%', height: '100%', position: 'relative' }}>
                      <Engine antialias adaptToDeviceRatio canvasId="canvas">
                        <Scene
                          clearColor="#1a1a2e"
                          onSceneReady={(scene) => createDefaultCameraOrLight(scene, true, true, true)}
                        >
                          <hemisphericLight
                            name="light"
                            direction={new Vector3(0, 1, 0)}
                            intensity={0.8}
                          />

                          <sphere
                            name="sphere"
                            position={new Vector3(-3, 2, 0)}
                            options={{ diameter: 2 }}
                          >
                            <pBRMaterial
                              name="sphereMat"
                              albedoColor={Color3.FromHexString("#ff6b9d")}
                              metallic={metallic}
                              roughness={roughness}
                              emissiveColor={Color3.FromHexString("#ff6b9d")}
                              emissiveIntensity={emissive}
                            />
                          </sphere>

                          <box
                            name="box"
                            position={new Vector3(0, 2, 0)}
                            options={{ size: 2 }}
                          >
                            <pBRMaterial
                              name="boxMat"
                              albedoColor={Color3.FromHexString("#4080ff")}
                              metallic={metallic}
                              roughness={roughness}
                              emissiveColor={Color3.FromHexString("#4080ff")}
                              emissiveIntensity={emissive}
                            />
                          </box>

                          <cylinder
                            name="cylinder"
                            position={new Vector3(3, 2, 0)}
                            options={{ height: 2, diameter: 1.5 }}
                          >
                            <pBRMaterial
                              name="cylinderMat"
                              albedoColor={Color3.FromHexString("#4ecdc4")}
                              metallic={metallic}
                              roughness={roughness}
                              emissiveColor={Color3.FromHexString("#4ecdc4")}
                              emissiveIntensity={emissive}
                            />
                          </cylinder>
                        </Scene>
                      </Engine>

                      <div style={{
                        position: 'absolute',
                        top: 20,
                        left: 20,
                        background: 'rgba(0,0,0,0.7)',
                        color: 'white',
                        padding: 20,
                        borderRadius: 8,
                        fontFamily: 'sans-serif'
                      }}>
                        <h3 style={{ margin: '0 0 15px 0' }}>Material Controls</h3>

                        <div style={{ marginBottom: 10 }}>
                          <label>Metallic: {metallic.toFixed(2)}</label>
                          <input
                            type="range"
                            min="0"
                            max="1"
                            step="0.01"
                            value={metallic}
                            onChange={(e) => setMetallic(parseFloat(e.target.value))}
                            style={{ width: '100%' }}
                          />
                        </div>

                        <div style={{ marginBottom: 10 }}>
                          <label>Roughness: {roughness.toFixed(2)}</label>
                          <input
                            type="range"
                            min="0"
                            max="1"
                            step="0.01"
                            value={roughness}
                            onChange={(e) => setRoughness(parseFloat(e.target.value))}
                            style={{ width: '100%' }}
                          />
                        </div>

                        <div>
                          <label>Emissive: {emissive.toFixed(2)}</label>
                          <input
                            type="range"
                            min="0"
                            max="1"
                            step="0.01"
                            value={emissive}
                            onChange={(e) => setEmissive(parseFloat(e.target.value))}
                            style={{ width: '100%' }}
                          />
                        </div>
                      </div>
                    </div>
                  )
                }

                export default App
            """.trimIndent(),
            category = ExampleCategory.ADVANCED,
            difficulty = ExampleDifficulty.ADVANCED
        )
    )
}
